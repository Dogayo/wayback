import 'package:flutter_test/flutter_test.dart';

import 'screen_rules.dart';
import 'source_file.dart';

const _screen = 'lib/features/points/view/screens/home_screen.dart';

SourceFile _file(String content, {String path = _screen}) =>
    (path: path, content: content);

List<String> _rules(List<Violation> violations) => [
  for (final v in violations) v.rule,
];

void main() {
  group('l10n-only', () {
    test('flags any user text literal, even a dash or a format', () {
      expect(_rules(noHardcodedText(_file("Text('Сохранить')"))), [
        'l10n-only',
      ]);
      expect(_rules(noHardcodedText(_file("distance: cond ? '—' : d"))), [
        'l10n-only',
      ]);
      expect(_rules(noHardcodedText(_file(r"Text('$lat, $lon')"))), [
        'l10n-only',
      ]);
    });

    test('allows l10n, directives, keys and empty strings', () {
      expect(
        noHardcodedText(
          _file(
            "import 'package:a/b.dart';\n"
            "part 'x.dart';\n"
            'Text(context.l10n.homeTitle)\n'
            "Key('save') ValueKey<String>('row') ''",
          ),
        ),
        isEmpty,
      );
    });
  });

  group('design-tokens', () {
    test('flags raw colors, styles, numbers in spacing and sizes', () {
      final rules = _rules(
        designTokens(
          _file(
            'Color(0xFF000000) Colors.red TextStyle() '
            'EdgeInsets.all(16) SizedBox(width: 6) Icon(i, size: 24) '
            'Radius.circular(8)',
          ),
        ),
      );
      expect(rules, everyElement('design-tokens'));
      expect(rules, hasLength(7));
    });

    test('allows tokens, zero and transparent', () {
      expect(
        designTokens(
          _file(
            'EdgeInsets.all(WbSpacing.md) SizedBox(width: WbSpacing.xs) '
            'SizedBox(height: 0) Colors.transparent context.wbColors.brand600',
          ),
        ),
        isEmpty,
      );
    });
  });

  test('design-system: Material widgets with a Wb counterpart', () {
    expect(
      _rules(
        designSystemComponents(_file('ElevatedButton( AlertDialog( SnackBar(')),
      ),
      ['design-system', 'design-system', 'design-system'],
    );
    expect(
      designSystemComponents(
        _file('WbButton( WbDialogs.confirm( WbSnackbar.show( TextButtonTheme('),
      ),
      isEmpty,
    );
  });

  group('action-result-listener', () {
    test('flags a plain listener on an action', () {
      expect(
        _rules(
          actionListeners(
            _file('BlocListener<SaveBloc, ActionState<void>>(listener: f)'),
          ),
        ),
        ['action-result-listener'],
      );
    });

    test('allows ActionResultListener and listeners on other states', () {
      expect(
        actionListeners(
          _file(
            'ActionResultListener<SaveBloc, void>(successHaptic: null); '
            'BlocListener<HomeBloc, DataState<Home>>(listener: f)',
          ),
        ),
        isEmpty,
      );
    });
  });

  group('thin-screens', () {
    test('no DI, repositories, data, bloc creation or calculations', () {
      final rules = _rules(
        thinScreens(
          _file(
            'context.di<X>() PointsRepository '
            "import 'package:wayback/features/points/data/x.dart';\n"
            'BlocProvider( distanceMeters(a, b)',
          ),
        ),
      );
      expect(rules, hasLength(5));
    });

    test('error codes and reading blocs are fine', () {
      expect(
        thinScreens(
          _file(
            'LocationErrorCodes.serviceDisabled '
            'context.read<HomeBloc>().fetch() BlocBuilder<A, B>(',
          ),
        ),
        isEmpty,
      );
    });
  });

  test('screen-size: screens only, up to the limit', () {
    final long = '//\n' * (maxScreenLines + 1);
    expect(_rules(screenSize(_file(long))), ['screen-size']);
    expect(screenSize(_file('a\nb')), isEmpty);
    expect(
      screenSize(
        _file(long, path: 'lib/features/points/view/widgets/big_view.dart'),
      ),
      isEmpty,
    );
  });

  test('screen-test: a mirrored test file', () {
    expect(_rules(screenHasTest(_file('x'), (_) => false)), ['screen-test']);
    expect(
      screenHasTest(_file('x'), (path) {
        expect(path, 'test/features/points/view/screens/home_screen_test.dart');
        return true;
      }),
      isEmpty,
    );
  });

  test('only view files are checked', () {
    expect(isViewFile(_screen), isTrue);
    expect(isViewFile('lib/core/widgets/stub_screen.dart'), isTrue);
    expect(isViewFile('lib/features/points/view/bloc/home_bloc.dart'), isFalse);
    expect(isViewFile('lib/app/navigation/app_router.dart'), isFalse);
  });
}
