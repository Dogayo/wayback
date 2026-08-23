# app_di

Собственный DI-пакет Wayback: service locator без codegen, именованные
контейнеры и регистрации, декларативные коллекции и Flutter-мост.

## Правила использования в Wayback

- Граф собирается только в `lib/app/dependencies/`; feature и `core` сами
  ничего не регистрируют.
- `domain` не обращается к контейнеру: зависимости передаются в конструкторы.
- Экран получает Bloc из контейнера один раз, при создании `BlocProvider`.
  Вложенные виджеты используют `context.read` / `context.watch`.
- Async-зависимости инициализируются в `bootstrap.dart` до регистрации и
  передаются фабрике через замыкание. `getAsync` контейнеру не нужен.

## Регистрация

Обычная фабрика ленивая и создаёт новый объект при каждом `get`. Singleton
также ленивый, но кэшируется после первого разрешения.

```dart
final injector = Injector();

injector.reg<ApiClient>((_) => ApiClient(), isSingleton: true);
injector.reg<Repository>((i) => Repository(i.get<ApiClient>()));

final repository = injector.get<Repository>();
```

Один тип можно зарегистрировать несколько раз с разными строковыми ключами.
`getAll<T>()` возвращает все регистрации этого типа в порядке регистрации.

Runtime-данные экрана не передаются в DI через нетипизированную map. Например,
Bloc создаётся явно, а обязательный параметр остаётся частью его конструктора:

```dart
BlocProvider(
  create: (context) => PointDetailsBloc(
    repository: context.di<PointsRepository>(),
    pointId: pointId,
  ),
  child: const PointDetailsScreen(),
);
```

Если создание требует отдельной абстракции, используется типизированный
factory-класс с методом вроде `create({required String pointId})`.

## Модули приложения

Каждая feature объявляет модуль в `app/dependencies/`. Несколько модулей можно
объединить в общую коллекцию приложения.

```dart
final class PointsDependencies extends DependencyCollection {
  const PointsDependencies();

  @override
  Iterable<RegType> get dependencies => [
    RegFactory<PointsLocalDatasource>(
      (_) => PointsLocalDatasourceImpl(),
      isSingleton: true,
    ),
    RegFactory<PointsRepository>(
      (i) => PointsRepositoryImpl(i.get<PointsLocalDatasource>()),
      isSingleton: true,
    ),
    RegFactory<PointsBloc>(
      (i) => PointsBloc(i.get<PointsRepository>()),
    ),
  ];
}
```

Регистрация коллекции атомарна: если один binding не удалось добавить, уже
добавленные bindings этой коллекции откатываются.

## Bootstrap и Flutter

Контейнер создаётся до `runApp`, после завершения async-инициализации. Scope
только публикует готовый контейнер в дереве и освобождает его вместе с собой.

```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = LocalStorage();
  await storage.initialize();

  final dependencies = DependencyContainer(
    commonDependencies: DependencyList([
      RegFactory<LocalStorage>((_) => storage, isSingleton: true),
      ...const PointsDependencies().dependencies,
    ]),
  );

  runApp(
    DependenciesScope(
      container: dependencies,
      child: const App(),
    ),
  );
}
```

Flutter-extension сокращает обращения к scope:

```dart
final injector = context.injector;
final repository = context.di<PointsRepository>();
final handlers = context.diAll<ActionHandler>();
final hasLogger = context.hasDi<Logger>(key: 'diagnostics');
```

Эти методы предназначены для composition boundary уровня экрана, а не для
доступа к зависимостям из `domain` или глубины widget tree.

Опциональная user-коллекция живёт только в рамках активной сессии:

```dart
context.initUserDependency(userDependencies);
context.disposeUserDependency();
```

После `dispose()` фабрики и singleton-кэш удаляются, а именованный контейнер
исключается из глобального реестра.
