import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/src/utils/qr_encoder.dart';

// ISO/IEC 18004 values written out by hand, not shared with the encoder.
const _eccPerBlock = [
  10, 16, 26, 18, 24, 16, 18, 22, 22, 26, //
  30, 22, 22, 24, 24, 28, 28, 26, 26, 26,
];
const _blocks = [
  1, 1, 1, 2, 2, 4, 4, 4, 5, 5, //
  5, 8, 9, 9, 10, 10, 11, 13, 14, 16,
];

/// The published byte capacity of each version at level M.
const _capacities = [
  14, 26, 42, 62, 84, 106, 122, 152, 180, 213, //
  251, 287, 331, 362, 412, 450, 504, 560, 624, 666,
];

const _formatStrings = [
  '101010000010010',
  '101000100100101',
  '101111001111100',
  '101101101001011',
  '100010111111001',
  '100000011001110',
  '100111110010111',
  '100101010100000',
];

int _version(QrMatrix qr) => (qr.size - 17) ~/ 4;

int _gf(int a, int b) {
  var result = 0;
  var x = a;
  for (var y = b; y > 0; y >>= 1) {
    if (y.isOdd) result ^= x;
    x <<= 1;
    if (x & 0x100 != 0) x ^= 0x11D;
  }
  return result;
}

String _format(QrMatrix qr) => [
  for (final (x, y) in [
    (0, 8), (1, 8), (2, 8), (3, 8), (4, 8), (5, 8), (7, 8), (8, 8), //
    (8, 7), (8, 5), (8, 4), (8, 3), (8, 2), (8, 1), (8, 0),
  ])
    qr.modules[y][x] ? '1' : '0',
].join();

String _formatCopy(QrMatrix qr) {
  final n = qr.size;
  return [
    for (var y = n - 1; y >= n - 7; y--) qr.modules[y][8] ? '1' : '0',
    for (var x = n - 8; x < n; x++) qr.modules[8][x] ? '1' : '0',
  ].join();
}

List<List<bool>> _functionMap(int version, int size) {
  final map = List.generate(size, (_) => List.filled(size, false));
  void fill(int x0, int y0, int w, int h) {
    for (var y = y0; y < y0 + h; y++) {
      for (var x = x0; x < x0 + w; x++) {
        map[y][x] = true;
      }
    }
  }

  fill(0, 0, 9, 9);
  fill(size - 8, 0, 8, 9);
  fill(0, size - 8, 9, 8);
  fill(6, 0, 1, size);
  fill(0, 6, size, 1);
  if (version >= 7) {
    fill(size - 11, 0, 3, 6);
    fill(0, size - 11, 6, 3);
  }
  if (version >= 2) {
    final count = version ~/ 7 + 2;
    final step = (version * 8 + count * 3 + 5) ~/ (count * 4 - 4) * 2;
    final centers = List.filled(count, 6);
    for (var i = 1; i < count; i++) {
      centers[count - i] = size - 7 - (i - 1) * step;
    }
    for (final y in centers) {
      for (final x in centers) {
        final finder =
            (x == 6 && y == 6) ||
            (x == 6 && y == size - 7) ||
            (x == size - 7 && y == 6);
        if (!finder) fill(x - 2, y - 2, 5, 5);
      }
    }
  }
  return map;
}

bool _mask(int mask, int x, int y) => switch (mask) {
  0 => (y + x) % 2 == 0,
  1 => y % 2 == 0,
  2 => x % 3 == 0,
  3 => (y + x) % 3 == 0,
  4 => (y ~/ 2 + x ~/ 3) % 2 == 0,
  5 => (y * x) % 2 + (y * x) % 3 == 0,
  6 => ((y * x) % 2 + (y * x) % 3) % 2 == 0,
  _ => ((y + x) % 2 + (y * x) % 3) % 2 == 0,
};

/// An independent reader: walks the symbol the way a scanner does, checks
/// every block's error correction and returns the text.
String _decode(QrMatrix qr) {
  final version = _version(qr);
  final size = qr.size;
  final format = int.parse(_format(qr), radix: 2) ^ 0x5412;
  expect(format >> 13, 0, reason: 'level M');
  final mask = format >> 10 & 7;
  final functions = _functionMap(version, size);

  final bits = <int>[];
  var upward = true;
  for (var right = size - 1; right > 0; right -= 2) {
    if (right == 6) right--;
    for (var i = 0; i < size; i++) {
      final y = upward ? size - 1 - i : i;
      for (final x in [right, right - 1]) {
        if (!functions[y][x]) {
          bits.add(qr.modules[y][x] != _mask(mask, x, y) ? 1 : 0);
        }
      }
    }
    upward = !upward;
  }

  final codewords = [
    for (var i = 0; i + 8 <= bits.length; i += 8)
      bits.sublist(i, i + 8).fold<int>(0, (a, b) => a << 1 | b),
  ];
  final blockCount = _blocks[version - 1];
  final ecc = _eccPerBlock[version - 1];
  final shortCount = blockCount - codewords.length % blockCount;
  final shortData = codewords.length ~/ blockCount - ecc;
  final blocks = List.generate(blockCount, (_) => <int>[]);
  var at = 0;
  for (var i = 0; i < shortData + 1; i++) {
    for (var j = 0; j < blockCount; j++) {
      if (i < shortData || j >= shortCount) blocks[j].add(codewords[at++]);
    }
  }
  for (var i = 0; i < ecc; i++) {
    for (final block in blocks) {
      block.add(codewords[at++]);
    }
  }
  for (final block in blocks) {
    var root = 1;
    for (var i = 0; i < ecc; i++) {
      var syndrome = 0;
      for (final byte in block) {
        syndrome = _gf(syndrome, root) ^ byte;
      }
      expect(syndrome, 0, reason: 'error correction of a block');
      root = _gf(root, 2);
    }
  }

  final dataBits = <int>[
    for (final block in blocks)
      for (final byte in block.sublist(0, block.length - ecc))
        for (var b = 7; b >= 0; b--) byte >> b & 1,
  ];
  int read(int from, int count) =>
      dataBits.sublist(from, from + count).fold(0, (a, b) => a << 1 | b);
  expect(read(0, 4), 4, reason: 'byte mode');
  final countBits = version <= 9 ? 8 : 16;
  final length = read(4, countBits);
  return utf8.decode([
    for (var i = 0; i < length; i++) read(4 + countBits + i * 8, 8),
  ]);
}

void main() {
  test('a symbol has the size of its version and its finders', () {
    final qr = encodeQr('wayback');
    expect(qr.size, 21);
    for (final row in [0, 6]) {
      expect(qr.modules[row].sublist(0, 7), everyElement(isTrue));
    }
    expect(qr.modules[1].sublist(0, 7), [
      true,
      false,
      false,
      false,
      false,
      false,
      true,
    ]);
  });

  test('capacity of each version matches the standard', () {
    for (var i = 0; i < _capacities.length; i++) {
      final fits = encodeQr('a' * _capacities[i]);
      expect(_version(fits), i + 1, reason: 'fits version ${i + 1}');
      if (i + 1 < _capacities.length) {
        final over = encodeQr('a' * (_capacities[i] + 1));
        expect(_version(over), i + 2, reason: 'spills from version ${i + 1}');
      }
    }
  });

  test('format information matches the published strings', () {
    for (var mask = 0; mask < 8; mask++) {
      final qr = encodeQr('wayback', mask: mask);
      expect(_format(qr), _formatStrings[mask], reason: 'mask $mask');
      expect(_formatCopy(qr), _formatStrings[mask], reason: 'copy, mask $mask');
    }
  });

  test('version information matches the standard', () {
    final qr = encodeQr('a' * 130);
    expect(_version(qr), 8);
    final seven = encodeQr('a' * 110);
    expect(_version(seven), 7);
    final bits = [
      for (var i = 17; i >= 0; i--)
        seven.modules[i ~/ 3][seven.size - 11 + i % 3] ? '1' : '0',
    ].join();
    expect(bits, '000111110010010100');
  });

  group('reads back', () {
    for (var i = 0; i < _capacities.length; i++) {
      final length = _capacities[i];
      test('version ${i + 1}', () {
        final text = List.generate(
          length,
          (n) => String.fromCharCode(33 + n % 90),
        ).join();
        expect(_decode(encodeQr(text)), text);
      });
    }

    for (var mask = 0; mask < 8; mask++) {
      test('mask $mask', () {
        const text = 'wayback://app/import?v=1&lat=56.50353&lon=85.03131&t=car';
        expect(_decode(encodeQr(text, mask: mask)), text);
      });
    }

    test('a link with a long Cyrillic name', () {
      final name = Uri.encodeQueryComponent('Парковка у ТЦ на Ленина, 3 этаж');
      final text =
          'wayback://app/import?v=1&lat=56.50353&lon=85.03131&t=car&n=$name';
      expect(_decode(encodeQr(text)), text);
    });
  });

  test('the chosen mask is one of the eight', () {
    expect(_formatStrings, contains(_format(encodeQr('wayback'))));
  });

  test('text too long is refused', () {
    expect(() => encodeQr('a' * (qrMaxBytes + 1)), throwsArgumentError);
  });
}
