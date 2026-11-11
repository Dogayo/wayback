<p align="right"><b>English</b> · <a href="README.ru.md">Русский</a></p>

# app_logger

Wayback's diagnostic log. It writes JSONL files on the device, limits their size and age, and strips private fields on export.

```dart
final logger = FileLogger(directory: logsDirectory);
logger.info('navigation', 'tick', fields: {'accuracy': 8}, private: {'lat': 55.75});
final file = await logger.exportShareable(); // without `private`
```

One entry is one line:

```json
{"t":"2026-11-06T09:00:00.000Z","l":"info","tag":"navigation","msg":"tick","f":{"accuracy":8},"p":{"lat":55.75}}
```

The logger never throws: a write failure must not break the app.
