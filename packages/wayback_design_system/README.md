<p align="right"><b>English</b> · <a href="README.ru.md">Русский</a></p>

# wayback_design_system

The Wayback design system as a Flutter package: semantic tokens, light and dark themes,
platform-adaptive components and an interactive catalog.

```dart
import 'package:wayback_design_system/wayback_design_system.dart';

MaterialApp(
  theme: WbTheme.light,
  darkTheme: WbTheme.dark,
  home: const MyScreen(),
);
```

Components read colors through `ThemeExtension<WbColors>`; screens must not use
color primitives directly. Inside a widget, `context.wbColors` and
`context.wbText` are available.

## Component catalog

```shell
cd example
flutter run
```

Or open it in the browser: [dogayo.github.io/wayback](https://dogayo.github.io/wayback/).

The demo is adaptive: a side panel appears on a wide screen. Theme and
platform switches let you check both color schemes and the platform mechanics.
