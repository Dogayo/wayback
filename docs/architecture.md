# Architecture

Документ описывает архитектуру приложения Wayback. Он рассчитан в первую очередь на AI-агентов: правила сформулированы так, чтобы по ним можно было однозначно решить, **куда положить новый код** и **что запрещено**.

Продуктовый контекст — [README.md](../README.md), критерии готовности — [mvp-scope.md](mvp-scope.md).

---

## 1. Стек

| Область | Решение |
| --- | --- |
| Платформа | Flutter (Dart SDK `^3.12.2`, Flutter `>=3.44.0`) |
| State management | `Bloc` (`flutter_bloc` + `bloc_concurrency`) — только Bloc, один блок на действие или компонент (§3.4) |
| Навигация | `go_router` (на текущем этапе; слой изолирован, замена возможна) |
| Локализация | `l10n` (Flutter gen-l10n, ARB-файлы) |
| DI | собственный пакет `app_di` |
| Хранилище | локальное, offline-first, без backend |
| Сеть | отсутствует в MVP-критическом пути |

---

## 2. Слои верхнего уровня

```text
lib/
├── main.dart          # только bootstrap
├── app/               # композиция приложения
├── core/              # общий фундамент, не знает о features
└── features/          # вертикальные срезы предметной области
```

Правило зависимостей — стрелки идут только вниз:

```text
app  ──►  features  ──►  core
```

- `core` **не импортирует** ничего из `features` и `app`.
- `features` импортируют `core`.
- Одна feature **не импортирует** внутренности другой feature. Если нужен обмен — общий контракт выносится в `core` или в `domain` одной из features, и зависимость объявляется явно и в одну сторону.
- `app` знает про всё и связывает.

### 2.1 `app/`

```text
app/
├── app.dart              # корневой виджет (MaterialApp.router)
├── bootstrap.dart        # инициализация до runApp
├── dependencies/         # регистрация зависимостей в app_di, модули по features
├── navigation/           # конфигурация go_router, маршруты, guards
├── localization/         # ARB-файлы, генерация l10n, доступ к переводам
├── extensions/           # расширения уровня приложения (BuildContext и т.п.)
└── theme/                # ThemeData, цвета, типографика
```

Ответственность: собрать граф зависимостей, отдать роутер, тему и локализацию в `MaterialApp.router`. Бизнес-логики здесь нет.

Все четыре инфраструктурных механизма — DI, навигация, локализация, расширения — живут в `app/`, а не в `core/`. `core/` остаётся чистым фундаментом предметно-независимого кода.

### 2.2 `core/`

```text
core/
├── error/
│   ├── exceptions.dart   # RemoteException, LocalException + подтипы
│   └── failures.dart     # RemoteFailure, LocalFailure + подтипы
├── result/               # Result<T> / Either-подобный тип
├── utils/                # geo-расчёты, форматтеры
└── widgets/              # переиспользуемые виджеты без привязки к feature
```

`core` — это фундамент. Всё, что в нём лежит, должно быть применимо минимум в двух features или быть инфраструктурой.

### 2.3 `features/`

Каждая feature — вертикальный срез:

```text
features/
└── {area}/
    ├── data/
    │   ├── datasources/     # источники данных (local/remote)
    │   ├── models/          # DTO, сериализация
    │   ├── mappers/         # model <-> entity
    │   └── repositories/    # реализации репозиториев
    ├── domain/
    │   ├── entities/        # чистые модели предметной области
    │   └── repositories/    # абстрактные интерфейсы репозиториев
    └── view/
        ├── screens/         # экраны, привязанные к маршрутам
        ├── widgets/         # виджеты этой feature
        └── bloc/            # блоки: *_bloc.dart + part *_event.dart / *_state.dart
```

Планируемые areas для MVP:

- `location` — разрешения, текущая позиция, точность, поток обновлений;
- `points` — CRUD сохранённых точек, активная точка;
- `navigation` — компас, bearing, расстояние, состояние прибытия;
- `settings` — единицы измерения, язык, вибрация (минимально);
- `onboarding` — первый запуск: шаги онбординга и факт их прохождения.

Журнал диагностики — пакет `packages/app_logger` (чистый Dart, запись JSONL на диск). `AppLogger` создаётся в bootstrap и приходит из DI; приватные поля записи (`private`) остаются только в локальных файлах и вырезаются при экспорте.

---

## 3. Правила слоёв внутри feature

### 3.1 `domain`

- Чистый Dart. **Запрещены** импорты `flutter/*`, любых пакетов хранилища, HTTP, платформенных плагинов.
- Содержит entity и интерфейсы репозиториев. Слоя usecase нет: сценарии на текущем масштабе тривиальны и были бы обёрткой в один метод над репозиторием. Bloc обращается к репозиторию напрямую.
- Ничего не знает о `data` и `view`.
- Методы репозитория возвращают `Result<T>` с `Failure` в ветке ошибки, а не бросают исключения.
- Если сценарий однажды разрастётся (несколько репозиториев, нетривиальная координация), логика выносится в `domain/services/` — но не раньше, чем это действительно понадобится.

### 3.2 `data`

- Реализует интерфейсы из `domain`.
- Datasource бросает `Exception` (`LocalException` / `RemoteException`).
- Реализация репозитория ловит их и сама превращает в `Failure`, возвращая `Result<T>`. Маппинг ошибок живёт здесь, а не в общем хелпере.
- Модели (DTO) живут только здесь и **не протекают** в `domain` и `view` — на границе работают mappers.

### 3.3 `view`

- Работает только с `domain` (entity + интерфейсы репозиториев). Импорт `data` из `view` **запрещён**.
- Управление состоянием — **Bloc** (пакет `flutter_bloc`), правила — §3.4. Файлы лежат в `view/bloc/`.
- Экран не содержит бизнес-логики и вычислений — только отображение состояния и отправка событий в Bloc.
- Состояние Bloc явно моделирует loading / content / empty / error — sealed-класс с вариантами, а не набор булевых флагов. Экран читает его только через `map` / `mapOrElse` / `mapOrNull`.
- Все строки берутся из `l10n`. Хардкод пользовательского текста запрещён.

### 3.4 Блоки и quality gate

**Только Bloc, Cubit запрещён**: у Bloc есть события, поэтому каждое действие видно и трассируется.

**Один блок — одно действие или один компонент.** Экран деталей точки — это данные (`PointDetailsBloc`) и три действия (`EditPointBloc`, `SetPointActiveBloc`, `DeletePointBloc`), а не один блок «на экран».

**Базовые блоки** (`lib/core/bloc/`); блок фичи наследует один из них:

| Блок | Для чего | Что реализует фича | События | Конкурентность |
| --- | --- | --- | --- | --- |
| `DataBloc<T>` | получить данные и показать: fetch, refresh, retry | `Stream<Result<T>> watch()` (разовая загрузка — `load().asStream()`) | `fetch()`, `refresh()`, `stop()` | `restartable` — новый запрос отменяет старый, `stop()` только отменяет и оставляет состояние |
| `ActionBloc<P, T>` | одно действие пользователя | `Future<Result<T>> perform(P params)` | `run(params)`, `reset()` | `droppable` — повторный запуск во время выполнения игнорируется |
| `ListBloc<T>` | постраничный список: fetch, refresh, fetch more | `Future<Result<ListPage<T>>> fetchPage(Object? cursor)` | `fetch()`, `refresh()`, `fetchMore()` | перезагрузка — `restartable`, подгрузка — `droppable` |

Их состояния — `DataState<T>`, `ActionState<T>`, `ListState<T>`: sealed-классы с `map`, `mapOrElse`, `mapOrNull`. Исключение внутри `watch`/`perform`/`fetchPage` тоже становится `UnexpectedFailure` в состоянии, а не падением.

**Свой блок на `Bloc`** допустим, когда форма не ложится ни в один базовый (например, `PointFormBloc`). Тогда:

- три файла: `x_bloc.dart` — логика и импорты, `x_event.dart` и `x_state.dart` — `part of 'x_bloc.dart';`, без своих импортов;
- корень событий — `sealed class XEvent`;
- если корень состояния `sealed`, он объявляет `map`, `mapOrElse`, `mapOrNull`. Состояние с одной формой — `final class` без них.

**Ещё правила:** один блок на файл; имя класса оканчивается на `Bloc`, файл — на `_bloc.dart`, лежит в `view/bloc/` фичи; блок не импортирует `data/` и виджеты; блоки создаются в `BlocProvider` (§5), в DI их нет.

**Quality gate** — архитектурные тесты в `test/architecture/`: `bloc_rules.dart` (правила как функции над исходником), `bloc_rules_test.dart` (каждое правило на правильном и неправильном примере), `bloc_gate_test.dart` (все правила по `lib/`). Они идут в обычном `flutter test`, локально и в CI; нарушение валит тест с файлом и правилом. Новое правило добавляется туда же — функцией и тестом на неё.


### 3.5 Экраны и quality gate

Правила для `view/screens/`, `view/widgets/` фич и `core/widgets/`:

| Правило | Что значит | Чем заменить |
| --- | --- | --- |
| `l10n-only` | в экране нет строковых литералов, даже `'—'` или склейки `'$lat, $lon'` | ключи `context.l10n`, хелперы `l10n.distanceOrUnknown()` / `l10n.accuracy()`, форматтеры `core/utils` (`formatCoordinates`) |
| `design-tokens` | нет `Color(0x…)`, `Colors.*`, `TextStyle(`, чисел в `EdgeInsets`, `width`/`height`/`size`/`radius`/`spacing` (ноль можно) | `context.wbColors`, `context.wbText`, `WbSpacing`, `WbIconSize`, `WbRadius` |
| `design-system` | нет Material-виджетов, у которых есть аналог в DS (`ElevatedButton`, `AlertDialog`, `ListTile`, `SnackBar`, `TextField`…) | `WbButton`, `WbDialogs`, `WbListItem`, `WbSnackbar.show`, `WbTextField`… |
| `thin-screens` | нет `context.di`, репозиториев, импорта `data/`, `BlocProvider` и расчётов (`distanceMeters`…) | блоки создаёт роутер; расчёты — в блоке или `core/utils`; коды ошибок (`*ErrorCodes`) использовать можно |
| `screen-size` | файл экрана — не больше 250 строк | части экрана — в `view/widgets/` (как `PointDetailsView`) |
| `screen-test` | у каждого экрана есть widget-тест по зеркальному пути `test/…/view/screens/x_screen_test.dart` | хелпер `pumpScreen` поднимает экран в настоящем `GoRouter`; заглушки ждут своих фич (`screensAwaitingTests`) |

Чего нет в дизайн-системе — сначала туда (так появились `WbIconTile` и `WbSnackbar.show`).

Gate — `test/architecture/screen_rules.dart`, тесты на правила в `screen_rules_test.dart`, прогон по `lib/` в `screen_gate_test.dart`; идёт в обычном `flutter test`.

---

## 4. Ошибки: exceptions и failures

Две параллельные иерархии: `Exception` — язык слоя `data`, `Failure` — язык `domain` и `view`.

```text
Exception (data)                    Failure (domain/view)
├── LocalException          ──►     ├── LocalFailure
│   ├── StorageException            │   ├── StorageFailure
│   ├── PermissionException         │   ├── PermissionFailure
│   ├── SensorException             │   ├── SensorFailure
│   └── NotFoundException           │   └── NotFoundFailure
└── RemoteException         ──►     └── RemoteFailure
    ├── NetworkException                ├── NetworkFailure
    ├── TimeoutException                ├── TimeoutFailure
    └── ServerException                 └── ServerFailure
```

Отдельно от двух иерархий стоит `UnexpectedFailure` (коды `unexpected` и `timeout`): так `ResultHandler` возвращает всё, что не является `AppException` — ошибку программы, неизвестную ошибку плагина, истёкший таймаут. Пользователь видит общий текст, сама ошибка уходит в `onError`.

`RemoteException` / `RemoteFailure` в MVP не используются (приложение offline), но иерархия заводится сразу, чтобы post-MVP функции не ломали контракт.

### 4.1 Контракт

Каждый `Exception` и каждый `Failure` несёт:

- `code` — **обязательный** строковый код ошибки. Это ключ для локализации, а не текст для пользователя;
- `description` — **опциональное** техническое описание для логов и отладки. Пользователю не показывается;
- `cause` / `stackTrace` — опционально, для проброса исходной ошибки.

Пример формы:

```dart
abstract class LocalException implements Exception {
  const LocalException({required this.code, this.description, this.cause});

  final String code;
  final String? description;
  final Object? cause;
}

abstract class Failure {
  const Failure({required this.code, this.description});

  final String code;
  final String? description;
}
```

### 4.2 Коды ошибок

- Код — это обычное строковое поле внутри самой ошибки. Отдельного реестра кодов (`error_codes.dart`) нет: код задаётся там, где ошибка создаётся.
- Формат: `snake_case`, с префиксом области — `location_permission_denied`, `points_storage_write_failed`, `navigation_compass_unavailable`.
- Отсюда следует дисциплина: код пишется осмысленно и стабильно, потому что компилятор его не проверяет. Ключ в ARB — единственная связка, и она проверяется глазами и тестом на полноту переводов.
- Коды, которые может вернуть репозиторий или data-сервис, объявляются константами **рядом с его интерфейсом** — в том же файле `features/{area}/domain/repositories/…`, например `LocationErrorCodes` возле `LocationRepository`. Datasource бросает исключения с этими кодами, view сравнивает с ними `failure.code`. В `core` специфичные коды не выносятся.
- Для каждого кода существует ключ в ARB-файлах локализации: `error_location_permission_denied` (заголовок) и `error_location_permission_denied_body` (пояснение) — тексты в [copy.md](copy.md) §11.2.
- Если для кода нет перевода — показывается общее сообщение об ошибке, а сам код логируется. Приложение не показывает пользователю сырой код или технический `description`.

### 4.3 Поток обработки

```text
datasource  →  бросает Exception (с code)
repository  →  оборачивает вызов в handle()/handleStream() из ResultHandler
bloc        →  переводит Failure в состояние экрана
view        →  показывает локализованный текст по failure.code
```

Единый механизм для всех репозиториев — mixin `ResultHandler` из `core/result/result_handler.dart`. Реализация репозитория подмешивает его и оборачивает **каждый** вызов datasource:

- `handle(() => …)` — одиночный вызов → `Result<T>`;
- `handleStream(stream)` — поток → поток `Result<T>`.

Гарантия: из `handle`/`handleStream` не выходит ни одно исключение — ни `AppException`, ни ошибка программы, ни исключение внутри хука или маппера. Всё становится `Failure`. Поэтому **каждый** метод интерфейса репозитория возвращает `Result` (в том числе действия без значения — `Future<Result<void>>`).

Поведение настраивается объектом `ResultHandlerOptions`. Общий экземпляр регистрируется в `app/dependencies/core_module.dart` и передаётся в конструктор репозитория (`resultOptions:`); для одного вызова его можно заменить параметром `options:` или `copyWith`.

| Настройка | Что делает |
| --- | --- |
| `onError` | видит каждую пойманную ошибку со стеком — логирование, crash-репортер |
| `onFailure` | видит каждый `Failure`, который вернул обработчик |
| `mapException` | свой маппинг `AppException → Failure`; `null` — маппинг по умолчанию |
| `mapUnexpected` | свой маппинг остальных ошибок; `null` — `UnexpectedFailure` |
| `timeout` | лимит одной попытки `handle`; по истечении — код `timeout` |
| `maxAttempts`, `retryIf`, `retryDelay` | повтор вызова, пока `retryIf` разрешает и попытки не кончились |
| `cancelStreamOnFailure` | закрыть поток после первого `Failure` вместо продолжения |

Маппинг по умолчанию (методы `mapException` / `mapUnexpected` миксина) сохраняет `code` и `description` и выбирает `Failure` того же вида; репозиторий может переопределить их целиком.

Типичная форма:

```dart
final class PointsRepositoryImpl with ResultHandler implements PointsRepository {
  @override
  Future<Result<List<SavedPoint>>> getAll() =>
      handle(() async => (await _local.readAll()).map(_mapper.toEntity).toList());
}
```

Ключевое правило: **исключения не пересекают границу `data`**. Выше репозитория живут только `Failure`.

---

## 5. Dependency Injection (`app_di`)

- Единственный механизм получения зависимостей — собственный пакет `app_di`.
- Регистрация — в `app/dependencies/`, разбитая по модулям на каждую feature (`location_module`, `points_module`, ...).
- Инфраструктурные регистрации (storage, logger, форматтеры) — тоже в `app/dependencies/`; `core` только предоставляет реализации, но сам ничего не регистрирует.
- Запрещено: глобальные синглтоны, статические фабрики, обращение к контейнеру из `domain`. Домен получает зависимости через конструктор.
- Блоки **не регистрируются в DI**. Их создаёт `BlocProvider` на уровне экрана, а зависимости (репозитории) берёт из контейнера: `BlocProvider(create: (context) => PointsBloc(context.di<PointsRepository>()))`. Виджеты глубже получают Bloc через `context.read` / `context.watch` или данные через параметры.

Порядок инициализации в `bootstrap.dart`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. инициализация локального хранилища и других async-зависимостей
3. регистрация модулей в `app_di`
4. `runApp(App())`

---

## 6. Навигация (`go_router`)

- Вся конфигурация — в `app/navigation/`. Маршруты внутри features не объявляются.
- Имена и пути маршрутов — константы в одном файле (`app/navigation/routes.dart`), без строковых литералов по месту вызова.
- Навигация вызывается из `view`. Из `domain` и `data` навигация **запрещена**.
- Deep links должны работать на экран конкретной точки (`/points/:id`).
- `wayback://app/import?...` открывает экран приёма точки; данные ссылки проверяются, сохранение всегда с подтверждением. Координаты — только в параметрах запроса: журнал пишет путь маршрута без них.
- Слой изолирован: смена роутера в будущем не должна затрагивать features.

Ориентировочная карта маршрутов MVP:

```text
/                    главный экран (сохранить / активная точка)
/points/new          создание точки по текущей позиции
/points              список сохранённых точек
/points/:id          детали точки
/navigate/:id        экран навигации на точку
/settings            настройки
/onboarding          онбординг первого запуска (вне стека `/`)
```

Пока онбординг не пройден, `redirect` роутера ведёт любой маршрут на `/onboarding`; после прохождения `/onboarding` недоступен и ведёт на `/`.

---

## 7. Локализация (`l10n`)

- ARB-файлы в `app/localization/`, генерация через `flutter gen-l10n`.
- Языки MVP: `ru`, `en`.
- Все пользовательские строки, включая тексты ошибок, только через сгенерированные классы.
- Ключи ошибок формируются как `error_<code>` (см. 4.2).
- Форматирование чисел, расстояний и дат — через локаль-зависимые форматтеры в `core/utils`, а не конкатенацией строк.

---

## 8. Геовычисления

Живут в `core/utils` как чистые функции — они не привязаны к feature и должны быть покрыты тестами:

```text
distance(current, target)          // haversine, метры
bearing(current, target)           // градусы, 0..360, от севера
arrowRotation = bearing - heading  // нормализуется в 0..360
```

Правила:

- функции чистые, без обращения к плагинам и времени;
- вращение стрелки интерполируется по кратчайшей дуге (переход 359° → 1° не должен давать оборот на 358°);
- пороги (радиус прибытия, минимальная приемлемая точность) — именованные константы, не магические числа.

Где лежат пороги:

| Порог | Константа | Значение |
| --- | --- | --- |
| радиус прибытия | `arrivalRadiusMeters` (`core/utils/geo/arrival.dart`) | 20 м |
| сколько точность GPS может расширить радиус | `arrivalAccuracyAllowanceMeters` | до 10 м: `hasArrived` = расстояние ≤ 20 + min(точность, 10) |
| запас на выход из радиуса | `arrivalExitMarginMeters` | 15 м: прибывший считается ушедшим только дальше порога входа + 15 м |
| слабый сигнал GPS | `weakSignalAccuracyMeters` (`location/domain`) | точность хуже 30 м |
| ненадёжный компас | `unreliableCompassAccuracyDegrees` (`navigation/domain`) | погрешность больше 30° или неизвестна |

Угол стрелки считает `NavigationGuidanceBloc` через `continuousRotationDegrees`: значение не сворачивается в 0..360, поэтому `WbDirectionDial` анимирует поворот по кратчайшей дуге.

---

## 9. Правила для AI-агентов

При добавлении кода:

1. Определи area. Новый функционал почти всегда идёт в существующую или новую `features/{area}/`, а не в `core`.
2. Начни с `domain`: entity → интерфейс репозитория.
3. Затем `data`: datasource → model → mapper → реализация репозитория.
4. Затем `view`: выбрать базовый блок (`DataBloc` / `ActionBloc` / `ListBloc`, §3.4) на каждые данные и каждое действие → экран → виджеты.
5. Зарегистрируй новое в соответствующем модуле в `app/dependencies/`.
6. Маршрут — только в `app/navigation/`.
7. Любая новая ошибка — строковый `code` в месте её создания **и** ключ `error_<code>` в ARB. Забыл ключ — пользователь увидит общее сообщение вместо внятного.

Запреты (нарушение = ошибка ревью):

- импорт `flutter/*` в `domain`;
- импорт `data` из `view`;
- импорт одной feature из другой напрямую;
- импорт `features` из `core`;
- хардкод пользовательских строк, цветов и размеров в экранах, Material-виджеты в обход дизайн-системы (§3.5);
- `throw` выше слоя `data`;
- сетевые вызовы в MVP-критическом пути;
- глобальные синглтоны в обход `app_di`;
- Cubit вместо Bloc и один блок «на весь экран» вместо блока на действие или компонент;
- регистрация блоков в `app_di` вместо создания в `BlocProvider`;
- `is`/`switch` по конкретным состояниям базовых блоков в экране вместо `map` / `mapOrElse` / `mapOrNull`;
- `try/catch` с ручным маппингом в репозитории вместо `ResultHandler`;
- метод репозитория, который возвращает не `Result` или вызывает datasource мимо `handle`/`handleStream`;
- магические числа в геовычислениях и порогах;
- бизнес-логика и вычисления внутри `build()` виджета вместо Bloc;
- состояние экрана набором отдельных булевых флагов вместо sealed-состояния.

Проверка перед завершением задачи:

```bash
flutter analyze && dart format --set-exit-if-changed . && flutter test
```

---

## 10. Тестирование

| Слой | Что тестируем | Тип |
| --- | --- | --- |
| `core/utils` | distance, bearing, rotation, форматтеры | unit |
| `core/error` | контракт ошибок, полнота ключей ARB для используемых кодов | unit |
| `view/bloc` | переходы состояний на фейковых репозиториях | unit |
| `test/architecture` | правила блоков и экранов (quality gate, §3.4, §3.5) | unit по исходникам |
| `view/screens` | каждый экран: состояния и навигация (`pumpScreen`) | widget |
| `data` | репозиторий: успех, ошибка, маппинг Exception → Failure, маппинг DTO | unit + фейковые datasource |
| `view` | отрисовка состояний, реакция на Failure | widget |

Структура `test/` зеркалит `lib/`.

---

## 11. Открытые вопросы

- Конкретная реализация локального хранилища точек (не зафиксирована; выбор изолирован в `features/points/data/datasources`).
