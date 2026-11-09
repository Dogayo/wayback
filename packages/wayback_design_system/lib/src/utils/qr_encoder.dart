import 'dart:convert';
import 'dart:math' as math;

/// A QR symbol: `true` is a dark module, indexed `[y][x]`.
///
/// Byte mode at error correction level M (ISO/IEC 18004), which is all a
/// short link needs: about 15% of the symbol can be unreadable.
final class QrMatrix {
  const QrMatrix._(this.modules);

  final List<List<bool>> modules;

  int get size => modules.length;
}

/// Longest text in bytes that [encodeQr] accepts: version 20.
const qrMaxBytes = 666;

const _maxVersion = 20;
const _maskCount = 8;
const _byteMode = 4;
const _formatLevelM = 0;

/// ISO/IEC 18004 table 9, level M, from version 1.
const _eccPerBlock = [
  10, 16, 26, 18, 24, 16, 18, 22, 22, 26, //
  30, 22, 22, 24, 24, 28, 28, 26, 26, 26,
];
const _blockCount = [
  1, 1, 1, 2, 2, 4, 4, 4, 5, 5, //
  5, 8, 9, 9, 10, 10, 11, 13, 14, 16,
];

/// Encodes [text] in the smallest symbol it fits. Without a [mask] the one
/// with the lowest penalty is used, as the standard asks.
///
/// Throws [ArgumentError] when [text] is longer than [qrMaxBytes].
QrMatrix encodeQr(String text, {int? mask}) {
  final bytes = utf8.encode(text);
  final version = _versionFor(bytes.length);
  final codewords = _withErrorCorrection(
    _dataCodewords(bytes, version),
    version,
  );
  final symbol = _Symbol(version)..drawFunctionPatterns();
  symbol.drawCodewords(codewords);
  final chosen = mask ?? symbol.bestMask();
  symbol
    ..applyMask(chosen)
    ..drawFormatBits(chosen);
  return QrMatrix._(symbol.modules);
}

int _versionFor(int length) {
  for (var version = 1; version <= _maxVersion; version++) {
    final bits = 4 + _countBits(version) + length * 8;
    if (bits <= _numDataCodewords(version) * 8) return version;
  }
  throw ArgumentError.value(length, 'text', 'longer than $qrMaxBytes bytes');
}

int _countBits(int version) => version <= 9 ? 8 : 16;

int _numRawModules(int version) {
  var result = (16 * version + 128) * version + 64;
  if (version >= 2) {
    final align = version ~/ 7 + 2;
    result -= (25 * align - 10) * align - 55;
    if (version >= 7) result -= 36;
  }
  return result;
}

int _numDataCodewords(int version) =>
    _numRawModules(version) ~/ 8 -
    _eccPerBlock[version - 1] * _blockCount[version - 1];

List<int> _dataCodewords(List<int> bytes, int version) {
  final capacity = _numDataCodewords(version) * 8;
  final bits = <int>[];
  void put(int value, int length) {
    for (var i = length - 1; i >= 0; i--) {
      bits.add((value >> i) & 1);
    }
  }

  put(_byteMode, 4);
  put(bytes.length, _countBits(version));
  for (final byte in bytes) {
    put(byte, 8);
  }
  put(0, math.min(4, capacity - bits.length));
  put(0, (8 - bits.length % 8) % 8);
  for (var pad = 0xEC; bits.length < capacity; pad ^= 0xEC ^ 0x11) {
    put(pad, 8);
  }
  return [
    for (var i = 0; i < bits.length; i += 8)
      bits.sublist(i, i + 8).fold(0, (byte, bit) => byte << 1 | bit),
  ];
}

List<int> _withErrorCorrection(List<int> data, int version) {
  final blocks = _blockCount[version - 1];
  final eccLength = _eccPerBlock[version - 1];
  final raw = _numRawModules(version) ~/ 8;
  final shortBlocks = blocks - raw % blocks;
  final shortLength = raw ~/ blocks;
  final divisor = _reedSolomonDivisor(eccLength);

  final parts = <List<int>>[];
  final eccs = <List<int>>[];
  var start = 0;
  for (var i = 0; i < blocks; i++) {
    final length = shortLength - eccLength + (i < shortBlocks ? 0 : 1);
    final part = data.sublist(start, start + length);
    start += length;
    parts.add(part);
    eccs.add(_reedSolomonRemainder(part, divisor));
  }

  return [
    for (var i = 0; i <= shortLength - eccLength; i++)
      for (var j = 0; j < blocks; j++)
        if (i < parts[j].length) parts[j][i],
    for (var i = 0; i < eccLength; i++)
      for (var j = 0; j < blocks; j++) eccs[j][i],
  ];
}

List<int> _reedSolomonDivisor(int degree) {
  final result = List.filled(degree, 0)..[degree - 1] = 1;
  var root = 1;
  for (var i = 0; i < degree; i++) {
    for (var j = 0; j < degree; j++) {
      result[j] = _gfMultiply(result[j], root);
      if (j + 1 < degree) result[j] ^= result[j + 1];
    }
    root = _gfMultiply(root, 2);
  }
  return result;
}

List<int> _reedSolomonRemainder(List<int> data, List<int> divisor) {
  final result = List.filled(divisor.length, 0, growable: true);
  for (final byte in data) {
    final factor = byte ^ result.first;
    result
      ..removeAt(0)
      ..add(0);
    for (var i = 0; i < result.length; i++) {
      result[i] ^= _gfMultiply(divisor[i], factor);
    }
  }
  return result;
}

int _gfMultiply(int x, int y) {
  var result = 0;
  for (var i = 7; i >= 0; i--) {
    result = (result << 1) ^ ((result >> 7) * 0x11D);
    result ^= ((y >> i) & 1) * x;
  }
  return result;
}

bool _masked(int mask, int x, int y) => switch (mask) {
  0 => (x + y).isEven,
  1 => y.isEven,
  2 => x % 3 == 0,
  3 => (x + y) % 3 == 0,
  4 => (x ~/ 3 + y ~/ 2).isEven,
  5 => x * y % 2 + x * y % 3 == 0,
  6 => (x * y % 2 + x * y % 3).isEven,
  _ => ((x + y) % 2 + x * y % 3).isEven,
};

class _Symbol {
  _Symbol(this.version) : size = version * 4 + 17 {
    modules = List.generate(size, (_) => List.filled(size, false));
    _isFunction = List.generate(size, (_) => List.filled(size, false));
  }

  final int version;
  final int size;
  late final List<List<bool>> modules;
  late final List<List<bool>> _isFunction;

  void _setFunction(int x, int y, {required bool dark}) {
    modules[y][x] = dark;
    _isFunction[y][x] = true;
  }

  void drawFunctionPatterns() {
    for (var i = 0; i < size; i++) {
      _setFunction(6, i, dark: i.isEven);
      _setFunction(i, 6, dark: i.isEven);
    }
    _drawFinder(3, 3);
    _drawFinder(size - 4, 3);
    _drawFinder(3, size - 4);
    final centers = _alignmentCenters();
    final last = centers.length - 1;
    for (var i = 0; i <= last; i++) {
      for (var j = 0; j <= last; j++) {
        final corner =
            (i == 0 && j == 0) ||
            (i == 0 && j == last) ||
            (i == last && j == 0);
        if (!corner) _drawAlignment(centers[i], centers[j]);
      }
    }
    drawFormatBits(0);
    _drawVersion();
  }

  void _drawFinder(int x, int y) {
    for (var dy = -4; dy <= 4; dy++) {
      for (var dx = -4; dx <= 4; dx++) {
        final distance = math.max(dx.abs(), dy.abs());
        final (column, row) = (x + dx, y + dy);
        if (column >= 0 && column < size && row >= 0 && row < size) {
          _setFunction(column, row, dark: distance != 2 && distance != 4);
        }
      }
    }
  }

  void _drawAlignment(int x, int y) {
    for (var dy = -2; dy <= 2; dy++) {
      for (var dx = -2; dx <= 2; dx++) {
        _setFunction(x + dx, y + dy, dark: math.max(dx.abs(), dy.abs()) != 1);
      }
    }
  }

  List<int> _alignmentCenters() {
    if (version == 1) return const [];
    final count = version ~/ 7 + 2;
    final step = (version * 8 + count * 3 + 5) ~/ (count * 4 - 4) * 2;
    final centers = List.filled(count, 6);
    for (var i = count - 1, position = size - 7; i >= 1; i--) {
      centers[i] = position;
      position -= step;
    }
    return centers;
  }

  void drawFormatBits(int mask) {
    final data = _formatLevelM << 3 | mask;
    var remainder = data;
    for (var i = 0; i < 10; i++) {
      remainder = (remainder << 1) ^ ((remainder >> 9) * 0x537);
    }
    final bits = (data << 10 | remainder) ^ 0x5412;
    bool bit(int i) => (bits >> i) & 1 == 1;

    for (var i = 0; i <= 5; i++) {
      _setFunction(8, i, dark: bit(i));
    }
    _setFunction(8, 7, dark: bit(6));
    _setFunction(8, 8, dark: bit(7));
    _setFunction(7, 8, dark: bit(8));
    for (var i = 9; i < 15; i++) {
      _setFunction(14 - i, 8, dark: bit(i));
    }
    for (var i = 0; i < 8; i++) {
      _setFunction(size - 1 - i, 8, dark: bit(i));
    }
    for (var i = 8; i < 15; i++) {
      _setFunction(8, size - 15 + i, dark: bit(i));
    }
    _setFunction(8, size - 8, dark: true);
  }

  void _drawVersion() {
    if (version < 7) return;
    var remainder = version;
    for (var i = 0; i < 12; i++) {
      remainder = (remainder << 1) ^ ((remainder >> 11) * 0x1F25);
    }
    final bits = version << 12 | remainder;
    for (var i = 0; i < 18; i++) {
      final dark = (bits >> i) & 1 == 1;
      final (a, b) = (size - 11 + i % 3, i ~/ 3);
      _setFunction(a, b, dark: dark);
      _setFunction(b, a, dark: dark);
    }
  }

  void drawCodewords(List<int> codewords) {
    var index = 0;
    for (var right = size - 1; right >= 1; right -= 2) {
      if (right == 6) right = 5;
      for (var step = 0; step < size; step++) {
        for (var j = 0; j < 2; j++) {
          final x = right - j;
          final upward = (right + 1) & 2 == 0;
          final y = upward ? size - 1 - step : step;
          if (!_isFunction[y][x] && index < codewords.length * 8) {
            modules[y][x] =
                (codewords[index >> 3] >> (7 - (index & 7))) & 1 == 1;
            index++;
          }
        }
      }
    }
  }

  void applyMask(int mask) {
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        if (!_isFunction[y][x] && _masked(mask, x, y)) {
          modules[y][x] = !modules[y][x];
        }
      }
    }
  }

  int bestMask() {
    var best = 0;
    var lowest = 1 << 62;
    for (var mask = 0; mask < _maskCount; mask++) {
      applyMask(mask);
      drawFormatBits(mask);
      final penalty = _penalty();
      if (penalty < lowest) {
        lowest = penalty;
        best = mask;
      }
      applyMask(mask);
    }
    return best;
  }

  int _penalty() {
    var score = 0;
    List<bool> column(int x) => [for (var y = 0; y < size; y++) modules[y][x]];
    for (var i = 0; i < size; i++) {
      score += _linePenalty(modules[i]) + _linePenalty(column(i));
    }
    var dark = 0;
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        if (modules[y][x]) dark++;
        if (y + 1 < size && x + 1 < size) {
          final color = modules[y][x];
          if (color == modules[y][x + 1] &&
              color == modules[y + 1][x] &&
              color == modules[y + 1][x + 1]) {
            score += 3;
          }
        }
      }
    }
    final total = size * size;
    return score +
        ((dark * 20 - total * 10).abs() + total - 1) ~/ total * 10 -
        10;
  }

  /// Runs of five or more, and anything that could be read as a finder.
  int _linePenalty(List<bool> line) {
    var score = 0;
    var run = 1;
    for (var i = 1; i <= line.length; i++) {
      if (i < line.length && line[i] == line[i - 1]) {
        run++;
      } else {
        if (run >= 5) score += run - 2;
        run = 1;
      }
    }
    final text = line.map((dark) => dark ? '1' : '0').join();
    score += 40 * RegExp('(?=10111010000)').allMatches(text).length;
    score += 40 * RegExp('(?=00001011101)').allMatches(text).length;
    return score;
  }
}
