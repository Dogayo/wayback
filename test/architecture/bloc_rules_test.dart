import 'package:flutter_test/flutter_test.dart';

import 'bloc_rules.dart';
import 'source_file.dart';

SourceFile _file(String path, String content) => (path: path, content: content);

List<String> _rules(List<Violation> violations) => [
  for (final v in violations) v.rule,
];

const _bloc = 'lib/features/points/view/bloc/save_point_bloc.dart';

void main() {
  group('no-cubit', () {
    test('flags a Cubit and a class named like one', () {
      expect(
        _rules(noCubit(_file('lib/a.dart', 'class A extends Cubit<int> {}'))),
        ['no-cubit'],
      );
      expect(
        _rules(noCubit(_file('lib/a.dart', 'class HomeCubit extends Base {}'))),
        ['no-cubit'],
      );
    });

    test('ignores comments and blocs', () {
      expect(
        noCubit(_file('lib/a.dart', '// not a Cubit\nclass A {}')),
        isEmpty,
      );
      expect(
        noCubit(
          _file(_bloc, 'class SavePointBloc extends ActionBloc<A, B> {}'),
        ),
        isEmpty,
      );
    });
  });

  group('bloc layout', () {
    test('a base bloc in view/bloc/*_bloc.dart passes', () {
      expect(
        blocFileLayout(
          _file(_bloc, 'final class SavePointBloc extends ActionBloc<A, B> {}'),
        ),
        isEmpty,
      );
    });

    test('wrong file name, place, class name and two blocs in one file', () {
      final violations = blocFileLayout(
        _file(
          'lib/features/points/view/screens/thing.dart',
          'class Saver extends ActionBloc<A, B> {}\n'
              'class OtherBloc extends DataBloc<C> {}',
        ),
      );
      expect(
        _rules(violations),
        containsAll([
          'one-bloc-per-file',
          'bloc-file-name',
          'bloc-location',
          'bloc-name',
        ]),
      );
    });
  });

  group('bloc-parts', () {
    const direct = 'class SavePointBloc extends Bloc<SavePointEvent, S> {}';

    test('a Bloc without event and state parts fails', () {
      expect(_rules(blocParts(_file(_bloc, direct))), [
        'bloc-parts',
        'bloc-parts',
      ]);
    });

    test('with both parts it passes; base blocs need none', () {
      expect(
        blocParts(
          _file(
            _bloc,
            "part 'save_point_event.dart';\npart 'save_point_state.dart';\n"
            '$direct',
          ),
        ),
        isEmpty,
      );
      expect(
        blocParts(
          _file(_bloc, 'class SavePointBloc extends ActionBloc<A, B> {}'),
        ),
        isEmpty,
      );
    });
  });

  group('part-of', () {
    const path = 'lib/features/points/view/bloc/point_form_state.dart';

    test('a state file must be a part of its bloc and import nothing', () {
      expect(_rules(partFiles(_file(path, "import 'x.dart';\nclass S {}"))), [
        'part-of',
        'part-of',
      ]);
      expect(
        partFiles(_file(path, "part of 'point_form_bloc.dart';\nclass S {}")),
        isEmpty,
      );
    });
  });

  group('state-map-methods', () {
    const path = 'lib/features/points/view/bloc/point_form_state.dart';

    test('a sealed state without map methods fails', () {
      expect(
        _rules(stateMapMethods(_file(path, 'sealed class FormState {}'))),
        ['state-map-methods', 'state-map-methods', 'state-map-methods'],
      );
    });

    test('with all three it passes; a plain final state needs none', () {
      expect(
        stateMapMethods(
          _file(
            path,
            'sealed class FormState { R map<R>() {} R mapOrElse<R>() {} '
            'R? mapOrNull<R>() {} }',
          ),
        ),
        isEmpty,
      );
      expect(stateMapMethods(_file(path, 'final class FormState {}')), isEmpty);
    });
  });

  test('sealed-events', () {
    const path = 'lib/features/points/view/bloc/point_form_event.dart';
    expect(
      _rules(sealedEvents(_file(path, 'abstract class PointFormEvent {}'))),
      ['sealed-events'],
    );
    expect(
      sealedEvents(_file(path, 'sealed class PointFormEvent {}')),
      isEmpty,
    );
  });

  test('bloc-imports: no data layer, no widgets', () {
    expect(
      _rules(
        blocImports(
          _file(
            _bloc,
            "import 'package:wayback/features/points/data/x.dart';\n"
            "import 'package:flutter/material.dart';",
          ),
        ),
      ),
      ['bloc-imports', 'bloc-imports'],
    );
    expect(
      blocImports(
        _file(_bloc, "import 'package:wayback/features/points/domain/x.dart';"),
      ),
      isEmpty,
    );
  });

  test('no-bloc-in-di', () {
    const path = 'lib/app/dependencies/points_module.dart';
    expect(
      _rules(
        noBlocInDi(_file(path, 'RegFactory<HomeBloc>((_) => HomeBloc())')),
      ),
      ['no-bloc-in-di'],
    );
    expect(noBlocInDi(_file(path, 'RegFactory<PointsRepository>(f)')), isEmpty);
  });

  test('view-map-methods: no concrete base states in screens', () {
    const path = 'lib/features/points/view/screens/home_screen.dart';
    expect(
      _rules(viewUsesMapMethods(_file(path, 'if (s is DataSuccess) {}'))),
      ['view-map-methods'],
    );
    expect(
      viewUsesMapMethods(
        _file(path, 's.mapOrElse(success: (s) => a, orElse: (_) => b)'),
      ),
      isEmpty,
    );
  });
}
