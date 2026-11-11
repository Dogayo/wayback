<p align="right"><a href="README.md">English</a> · <b>Русский</b></p>

# app_logger

Журнал диагностики Wayback. Пишет JSONL-файлы на устройство, ограничивает их размер и возраст, а при экспорте убирает приватные поля.

```dart
final logger = FileLogger(directory: logsDirectory);
logger.info('navigation', 'tick', fields: {'accuracy': 8}, private: {'lat': 55.75});
final file = await logger.exportShareable(); // без `private`
```

Одна запись — одна строка:

```json
{"t":"2026-11-06T09:00:00.000Z","l":"info","tag":"navigation","msg":"tick","f":{"accuracy":8},"p":{"lat":55.75}}
```

Логгер никогда не бросает исключений: сбой записи не должен ломать приложение.
