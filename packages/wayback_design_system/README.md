# wayback_design_system

Flutter-пакет дизайн-системы Wayback: семантические токены, светлая и тёмная темы,
платформо-адаптивные компоненты и интерактивный каталог.

```dart
import 'package:wayback_design_system/wayback_design_system.dart';

MaterialApp(
  theme: WbTheme.light,
  darkTheme: WbTheme.dark,
  home: const MyScreen(),
);
```

Компоненты читают цвета через `ThemeExtension<WbColors>`; экраны не должны использовать
цветовые примитивы напрямую. Внутри виджета доступны `context.wbColors` и
`context.wbText`.

## Каталог компонентов

```shell
cd example
flutter run
```

Демо адаптивно: на широком экране появляется боковая панель. Переключатели темы и
платформы позволяют проверить обе цветовые схемы и платформенную механику.

## Голден-тесты

Снимки основных компонентов лежат в `test/goldens/`: светлая и тёмная темы, а для
платформо-зависимых сцен (поля и контролы, навигация, диалог) — ещё Android и iOS.
Шрифты Roboto и Material Icons подгружаются из кэша Flutter SDK
(`test/flutter_test_config.dart`), поэтому на снимках настоящий текст, а не квадраты Ahem.

```shell
flutter test                              # сверка со снимками
flutter test --update-goldens test/goldens # после намеренного визуального изменения
flutter test --exclude-tags golden        # только логические тесты
```

Рендеринг текста немного отличается между ОС, поэтому снимки сравниваются на той же
платформе, на которой сгенерированы (сейчас — Windows).
