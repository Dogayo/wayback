<p align="right"><b>English</b> · <a href="architecture.ru.md">Русский</a></p>

# Architecture

This document describes the architecture of the Wayback app. It is written mainly for AI agents: the rules are phrased so that they settle unambiguously **where new code goes** and **what is forbidden**.

Product context — [product.md](product.md), done criteria — [mvp-scope.md](mvp-scope.md).

---

## 1. Stack

| Area | Choice |
| --- | --- |
| Platform | Flutter (Dart SDK `^3.12.2`, Flutter `>=3.44.0`) |
| State management | `Bloc` (`flutter_bloc` + `bloc_concurrency`) — Bloc only, one bloc per action or component (§3.4) |
| Navigation | `go_router` (for now; the layer is isolated and can be replaced) |
| Localization | `l10n` (Flutter gen-l10n, ARB files) |
| DI | own package `app_di` |
| Storage | local, offline-first, no backend |
| Network | not on the MVP-critical path |

---

## 2. Top-level layers

```text
lib/
├── main.dart          # bootstrap only
├── app/               # app composition
├── core/              # shared foundation, knows nothing about features
└── features/          # vertical slices of the domain
```

Dependency rule — arrows only point down:

```text
app  ──►  features  ──►  core
```

- `core` **does not import** anything from `features` or `app`.
- `features` import `core`.
- One feature **does not import** the internals of another. If they need to exchange something, the shared contract moves to `core` or to the `domain` of one of the features, and the dependency is declared explicitly and one way.
- `app` knows about everything and wires it together.

### 2.1 `app/`

```text
app/
├── app.dart              # root widget (MaterialApp.router)
├── bootstrap.dart        # initialization before runApp
├── dependencies/         # registration in app_di, one module per feature
├── navigation/           # go_router configuration, routes, guards
├── localization/         # ARB files, l10n generation, access to translations
├── extensions/           # app-level extensions (BuildContext and so on)
└── theme/                # ThemeData, colors, typography
```

Responsibility: build the dependency graph and hand the router, theme and localization to `MaterialApp.router`. There is no business logic here.

All four infrastructure mechanisms — DI, navigation, localization, extensions — live in `app/`, not in `core/`. `core/` stays a clean foundation of domain-independent code.

### 2.2 `core/`

```text
core/
├── error/
│   ├── exceptions.dart   # RemoteException, LocalException + subtypes
│   └── failures.dart     # RemoteFailure, LocalFailure + subtypes
├── result/               # Result<T> / an Either-like type
├── utils/                # geo calculations, formatters
└── widgets/              # reusable widgets not tied to a feature
```

`core` is the foundation. Everything in it has to apply to at least two features or be infrastructure.

### 2.3 `features/`

Each feature is a vertical slice:

```text
features/
└── {area}/
    ├── data/
    │   ├── datasources/     # data sources (local/remote)
    │   ├── models/          # DTOs, serialization
    │   ├── mappers/         # model <-> entity
    │   └── repositories/    # repository implementations
    ├── domain/
    │   ├── entities/        # pure domain models
    │   └── repositories/    # abstract repository interfaces
    └── view/
        ├── screens/         # screens bound to routes
        ├── widgets/         # this feature's widgets
        └── bloc/            # blocs: *_bloc.dart + part *_event.dart / *_state.dart
```

Planned areas for the MVP:

- `location` — permissions, current position, accuracy, update stream;
- `points` — CRUD of saved points, the active point;
- `navigation` — compass, bearing, distance, arrival state;
- `settings` — units, language, vibration (minimal);
- `onboarding` — first launch: the onboarding steps and the fact they were completed.

The diagnostic log is the `packages/app_logger` package (plain Dart, JSONL on disk). `AppLogger` is created in bootstrap and comes from DI; the private fields of an entry (`private`) stay only in local files and are stripped on export.

---

## 3. Layer rules inside a feature

### 3.1 `domain`

- Plain Dart. Imports of `flutter/*`, any storage packages, HTTP and platform plugins are **forbidden**.
- Holds entities and repository interfaces. There is no use-case layer: at the current scale scenarios are trivial and would be a one-method wrapper over a repository. The bloc calls the repository directly.
- Knows nothing about `data` and `view`.
- Repository methods return `Result<T>` with a `Failure` on the error branch instead of throwing.
- If a scenario ever grows (several repositories, non-trivial coordination), the logic moves to `domain/services/` — but not before it is really needed.

### 3.2 `data`

- Implements the interfaces from `domain`.
- A datasource throws an `Exception` (`LocalException` / `RemoteException`).
- The repository implementation catches them and turns them into a `Failure` itself, returning `Result<T>`. Error mapping lives here, not in a shared helper.
- Models (DTOs) live only here and **do not leak** into `domain` and `view` — mappers work at the boundary.

### 3.3 `view`

- Works only with `domain` (entities + repository interfaces). Importing `data` from `view` is **forbidden**.
- State management is **Bloc** (the `flutter_bloc` package), rules in §3.4. The files live in `view/bloc/`.
- A screen holds no business logic and no calculations — it only shows state and sends events to the bloc.
- A bloc state explicitly models loading / content / empty / error — a sealed class with variants, not a set of boolean flags. The screen reads it only through `map` / `mapOrElse` / `mapOrNull`.
- Every string comes from `l10n`. Hard-coded user-facing text is forbidden.

### 3.4 Blocs and the quality gate

**Bloc only, Cubit is forbidden**: a Bloc has events, so every action is visible and traceable.

**One bloc — one action or one component.** The point details screen is data (`PointDetailsBloc`) and three actions (`EditPointBloc`, `SetPointActiveBloc`, `DeletePointBloc`), not one bloc "per screen".

**Base blocs** (`lib/core/bloc/`); a feature's bloc extends one of them:

| Bloc | What for | What the feature implements | Events | Concurrency |
| --- | --- | --- | --- | --- |
| `DataBloc<T>` | get data and show it: fetch, refresh, retry | `Stream<Result<T>> watch()` (one-off load — `load().asStream()`) | `fetch()`, `refresh()`, `stop()` | `restartable` — a new request cancels the old one, `stop()` only cancels and keeps the state |
| `ActionBloc<P, T>` | one user action | `Future<Result<T>> perform(P params)` | `run(params)`, `reset()` | `droppable` — a repeated run while one is in progress is ignored |
| `ListBloc<T>` | a paged list: fetch, refresh, fetch more | `Future<Result<ListPage<T>>> fetchPage(Object? cursor)` | `fetch()`, `refresh()`, `fetchMore()` | reload — `restartable`, load more — `droppable` |

Their states — `DataState<T>`, `ActionState<T>`, `ListState<T>` — are sealed classes with `map`, `mapOrElse`, `mapOrNull`. An exception inside `watch`/`perform`/`fetchPage` also becomes an `UnexpectedFailure` in the state, not a crash.

**A custom bloc on `Bloc`** is allowed when the shape fits none of the base ones (for example, `PointFormBloc`). Then:

- three files: `x_bloc.dart` — logic and imports, `x_event.dart` and `x_state.dart` — `part of 'x_bloc.dart';`, without imports of their own;
- the event root is `sealed class XEvent`;
- if the state root is `sealed`, it declares `map`, `mapOrElse`, `mapOrNull`. A state with a single shape is a `final class` without them.

**More rules:** one bloc per file; the class name ends with `Bloc`, the file with `_bloc.dart`, and it lives in the feature's `view/bloc/`; a bloc imports neither `data/` nor widgets; blocs are created in `BlocProvider` (§5) and are not in DI.

**Quality gate** — architecture tests in `test/architecture/`: `bloc_rules.dart` (the rules as functions over source code), `bloc_rules_test.dart` (each rule on a correct and a wrong example), `bloc_gate_test.dart` (all rules over `lib/`). They run in the regular `flutter test`, locally and in CI; a violation fails the test with the file and the rule. A new rule goes there too — a function and a test for it.


### 3.5 Screens and the quality gate

Rules for `view/screens/`, feature `view/widgets/` and `core/widgets/`:

| Rule | What it means | Use instead |
| --- | --- | --- |
| `l10n-only` | no string literals in a screen, not even `'—'` or a join like `'$lat, $lon'` | `context.l10n` keys, the helpers `l10n.distanceOrUnknown()` / `l10n.accuracy()`, the `core/utils` formatters (`formatCoordinates`) |
| `design-tokens` | no `Color(0x…)`, `Colors.*`, `TextStyle(`, numbers in `EdgeInsets`, `width`/`height`/`size`/`radius`/`spacing` (zero is fine) | `context.wbColors`, `context.wbText`, `WbSpacing`, `WbIconSize`, `WbRadius` |
| `design-system` | no Material widgets that have a counterpart in the DS (`ElevatedButton`, `AlertDialog`, `ListTile`, `SnackBar`, `TextField`…) | `WbButton`, `WbDialogs`, `WbListItem`, `WbSnackbar.show`, `WbTextField`… |
| `thin-screens` | no `context.di`, repositories, `data/` imports, `BlocProvider` or calculations (`distanceMeters`…) | the router creates blocs; calculations go to the bloc or `core/utils`; error codes (`*ErrorCodes`) are fine to use |
| `screen-size` | a screen file is at most 250 lines | parts of the screen go to `view/widgets/` (like `PointDetailsView`) |
| `screen-test` | every screen has a widget test at the mirrored path `test/…/view/screens/x_screen_test.dart` | the `pumpScreen` helper puts the screen into a real `GoRouter`; stubs wait for their features (`screensAwaitingTests`) |

Whatever the design system lacks goes there first (that is how `WbIconTile` and `WbSnackbar.show` appeared).

The gate is `test/architecture/screen_rules.dart`, the rule tests are in `screen_rules_test.dart`, the run over `lib/` is in `screen_gate_test.dart`; it runs in the regular `flutter test`.

---

## 4. Errors: exceptions and failures

Two parallel hierarchies: `Exception` is the language of the `data` layer, `Failure` the language of `domain` and `view`.

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

Apart from the two hierarchies stands `UnexpectedFailure` (codes `unexpected` and `timeout`): this is what `ResultHandler` returns for anything that is not an `AppException` — a programming error, an unknown plugin error, an expired timeout. The user sees a generic text, and the error itself goes to `onError`.

`RemoteException` / `RemoteFailure` are not used in the MVP (the app is offline), but the hierarchy is set up right away so that post-MVP features do not break the contract.

### 4.1 Contract

Every `Exception` and every `Failure` carries:

- `code` — a **required** string error code. It is a key for localization, not text for the user;
- `description` — an **optional** technical description for logs and debugging. Never shown to the user;
- `cause` / `stackTrace` — optional, to pass on the original error.

Example shape:

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

### 4.2 Error codes

- A code is a plain string field inside the error itself. There is no separate registry of codes (`error_codes.dart`): the code is set where the error is created.
- Format: `snake_case` with an area prefix — `location_permission_denied`, `points_storage_write_failed`, `navigation_compass_unavailable`.
- This calls for discipline: a code is written meaningfully and kept stable, because the compiler does not check it. The ARB key is the only link, and it is checked by eye and by a translation-completeness test.
- Codes a repository or a data service may return are declared as constants **next to its interface** — in the same `features/{area}/domain/repositories/…` file, for example `LocationErrorCodes` next to `LocationRepository`. The datasource throws exceptions with these codes, the view compares `failure.code` with them. Specific codes do not move to `core`.
- Every code has a key in the ARB localization files: `error_location_permission_denied` (title) and `error_location_permission_denied_body` (explanation) — the texts are in [copy.md](copy.md) §11.2.
- If a code has no translation, a generic error message is shown and the code itself is logged. The app never shows the user a raw code or the technical `description`.

### 4.3 Handling flow

```text
datasource  →  throws an Exception (with a code)
repository  →  wraps the call in handle()/handleStream() from ResultHandler
bloc        →  turns the Failure into a screen state
view        →  shows localized text by failure.code
```

One mechanism for every repository — the `ResultHandler` mixin from `core/result/result_handler.dart`. A repository implementation mixes it in and wraps **every** datasource call:

- `handle(() => …)` — a single call → `Result<T>`;
- `handleStream(stream)` — a stream → a stream of `Result<T>`.

Guarantee: no exception leaves `handle`/`handleStream` — not an `AppException`, not a programming error, not an exception inside a hook or a mapper. Everything becomes a `Failure`. That is why **every** repository interface method returns a `Result` (actions without a value too — `Future<Result<void>>`).

Behaviour is configured with a `ResultHandlerOptions` object. A shared instance is registered in `app/dependencies/core_module.dart` and passed to the repository constructor (`resultOptions:`); for a single call it can be replaced with the `options:` parameter or `copyWith`.

| Option | What it does |
| --- | --- |
| `onError` | sees every caught error with its stack — logging, a crash reporter |
| `onFailure` | sees every `Failure` the handler returned |
| `mapException` | custom `AppException → Failure` mapping; `null` — the default mapping |
| `mapUnexpected` | custom mapping of other errors; `null` — `UnexpectedFailure` |
| `timeout` | limit for one `handle` attempt; on expiry — code `timeout` |
| `maxAttempts`, `retryIf`, `retryDelay` | retry the call while `retryIf` allows it and attempts remain |
| `cancelStreamOnFailure` | close the stream after the first `Failure` instead of going on |

The default mapping (the mixin's `mapException` / `mapUnexpected` methods) keeps `code` and `description` and picks a `Failure` of the same kind; a repository can override them entirely.

Typical shape:

```dart
final class PointsRepositoryImpl with ResultHandler implements PointsRepository {
  @override
  Future<Result<List<SavedPoint>>> getAll() =>
      handle(() async => (await _local.readAll()).map(_mapper.toEntity).toList());
}
```

The key rule: **exceptions do not cross the `data` boundary**. Above the repository there are only `Failure`s.

---

## 5. Dependency Injection (`app_di`)

- The only way to get dependencies is the own `app_di` package.
- Registration is in `app/dependencies/`, split into one module per feature (`location_module`, `points_module`, ...).
- Infrastructure registrations (storage, logger, formatters) are in `app/dependencies/` too; `core` only provides implementations and registers nothing itself.
- Forbidden: global singletons, static factories, access to the container from `domain`. The domain gets its dependencies through constructors.
- Blocs are **not registered in DI**. `BlocProvider` creates them at the screen level and takes their dependencies (repositories) from the container: `BlocProvider(create: (context) => PointsBloc(context.di<PointsRepository>()))`. Deeper widgets get the bloc through `context.read` / `context.watch` or the data through parameters.

Initialization order in `bootstrap.dart`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. initialize local storage and other async dependencies
3. register the modules in `app_di`
4. `runApp(App())`

---

## 6. Navigation (`go_router`)

- All configuration is in `app/navigation/`. Routes are not declared inside features.
- Route names and paths are constants in one file (`app/navigation/routes.dart`), with no string literals at the call site.
- Navigation is called from `view`. Navigation from `domain` and `data` is **forbidden**.
- Deep links have to work for a specific point screen (`/points/:id`).
- `wayback://app/import?...` opens the screen for receiving a point; the link data is validated, and saving always asks for confirmation. Coordinates go only in query parameters: the log records the route path without them.
- The layer is isolated: replacing the router later must not touch features.

Rough MVP route map:

```text
/                    home screen (save / active point)
/points/new          create a point from the current position
/points              list of saved points
/points/:id          point details
/navigate/:id        navigation to the point
/settings            settings
/onboarding          first-launch onboarding (outside the `/` stack)
```

Until onboarding is completed, the router `redirect` sends any route to `/onboarding`; afterwards `/onboarding` is unavailable and leads to `/`.

---

## 7. Localization (`l10n`)

- ARB files in `app/localization/`, generated with `flutter gen-l10n`.
- MVP languages: `ru`, `en`.
- Every user-facing string, error texts included, goes only through the generated classes.
- Error keys are built as `error_<code>` (see 4.2).
- Numbers, distances and dates are formatted through locale-aware formatters in `core/utils`, not by joining strings.

---

## 8. Geo calculations

They live in `core/utils` as pure functions — they are not tied to a feature and have to be covered by tests:

```text
distance(current, target)          // haversine, metres
bearing(current, target)           // degrees, 0..360, from north
arrowRotation = bearing - heading  // normalized to 0..360
```

Rules:

- the functions are pure, with no access to plugins or the clock;
- the arrow rotation is interpolated along the shortest arc (going from 359° to 1° must not make a 358° turn);
- thresholds (arrival radius, minimum acceptable accuracy) are named constants, not magic numbers.

Where the thresholds live:

| Threshold | Constant | Value |
| --- | --- | --- |
| arrival radius | `arrivalRadiusMeters` (`core/utils/geo/arrival.dart`) | 20 m |
| how much GPS accuracy may widen the radius | `arrivalAccuracyAllowanceMeters` | up to 10 m: `hasArrived` = distance ≤ 20 + min(accuracy, 10) |
| margin for leaving the radius | `arrivalExitMarginMeters` | 15 m: someone who arrived counts as gone only beyond the entry threshold + 15 m |
| weak GPS signal | `weakSignalAccuracyMeters` (`location/domain`) | accuracy worse than 30 m |
| unreliable compass | `unreliableCompassAccuracyDegrees` (`navigation/domain`) | error above 30° or unknown |

`NavigationGuidanceBloc` computes the arrow angle through `continuousRotationDegrees`: the value is not wrapped into 0..360, so `WbDirectionDial` animates the turn along the shortest arc.

---

## 9. Rules for AI agents

When adding code:

1. Pick the area. New functionality almost always goes into an existing or new `features/{area}/`, not into `core`.
2. Start with `domain`: entity → repository interface.
3. Then `data`: datasource → model → mapper → repository implementation.
4. Then `view`: pick a base bloc (`DataBloc` / `ActionBloc` / `ListBloc`, §3.4) for each piece of data and each action → screen → widgets.
5. Register the new parts in the matching module in `app/dependencies/`.
6. Routes go only in `app/navigation/`.
7. Any new error is a string `code` where it is created **and** an `error_<code>` key in the ARB. Forget the key and the user sees a generic message instead of a clear one.

Forbidden (a violation is a review error):

- importing `flutter/*` in `domain`;
- importing `data` from `view`;
- importing one feature from another directly;
- importing `features` from `core`;
- hard-coded user-facing strings, colors and sizes in screens, Material widgets that bypass the design system (§3.5);
- `throw` above the `data` layer;
- network calls on the MVP-critical path;
- global singletons that bypass `app_di`;
- Cubit instead of Bloc, and one bloc "for the whole screen" instead of a bloc per action or component;
- registering blocs in `app_di` instead of creating them in `BlocProvider`;
- `is`/`switch` over concrete base-bloc states in a screen instead of `map` / `mapOrElse` / `mapOrNull`;
- `try/catch` with hand-written mapping in a repository instead of `ResultHandler`;
- a repository method that returns something other than `Result` or calls the datasource outside `handle`/`handleStream`;
- magic numbers in geo calculations and thresholds;
- business logic and calculations inside a widget's `build()` instead of the bloc;
- a screen state as a set of separate boolean flags instead of a sealed state.

Check before finishing a task:

```bash
flutter analyze && dart format --set-exit-if-changed . && flutter test
```

---

## 10. Testing

| Layer | What is tested | Type |
| --- | --- | --- |
| `core/utils` | distance, bearing, rotation, formatters | unit |
| `core/error` | the error contract, ARB key completeness for the codes in use | unit |
| `view/bloc` | state transitions on fake repositories | unit |
| `test/architecture` | bloc and screen rules (quality gate, §3.4, §3.5) | unit over source code |
| `view/screens` | every screen: states and navigation (`pumpScreen`) | widget |
| `data` | the repository: success, error, Exception → Failure mapping, DTO mapping | unit + fake datasources |
| `view` | rendering states, reacting to a Failure | widget |

The `test/` structure mirrors `lib/`.

---

## 11. Open questions

- The exact local storage implementation for points (not fixed; the choice is isolated in `features/points/data/datasources`).
