<p align="right"><a href="README.md">English</a> · <b>Русский</b></p>

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

Или в браузере: [dogayo.github.io/wayback](https://dogayo.github.io/wayback/).

Демо адаптивно: на широком экране появляется боковая панель. Переключатели темы и
платформы позволяют проверить обе цветовые схемы и платформенную механику.
