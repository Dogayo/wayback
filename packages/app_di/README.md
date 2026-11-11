<p align="right"><b>English</b> · <a href="README.ru.md">Русский</a></p>

# app_di

Wayback's own DI package: a service locator without codegen, named
containers and registrations, declarative collections and a Flutter bridge.

## Rules of use in Wayback

- The graph is built only in `lib/app/dependencies/`; features and `core`
  register nothing themselves.
- `domain` does not touch the container: dependencies are passed to constructors.
- Bloc/Cubit are not registered in the container: `BlocProvider` creates them,
  and only their dependencies come from the container.
  Nested widgets use `context.read` / `context.watch`.
- Async dependencies are initialized in `bootstrap.dart` before registration and
  passed to the factory through a closure. The container needs no `getAsync`.

## Registration

A regular factory is lazy and creates a new object on every `get`. A singleton
is lazy too, but is cached after the first resolution.

```dart
final injector = Injector();

injector.reg<ApiClient>((_) => ApiClient(), isSingleton: true);
injector.reg<Repository>((i) => Repository(i.get<ApiClient>()));

final repository = injector.get<Repository>();
```

One type can be registered several times under different string keys.
`getAll<T>()` returns every registration of that type in registration order.

Runtime screen data is not passed into DI through an untyped map. For example,
a Bloc is created explicitly, and a required parameter stays part of its constructor:

```dart
BlocProvider(
  create: (context) => PointDetailsBloc(
    repository: context.di<PointsRepository>(),
    pointId: pointId,
  ),
  child: const PointDetailsScreen(),
);
```

If creation needs an abstraction of its own, use a typed factory class with a
method like `create({required String pointId})`.

## App modules

Each feature declares a module in `app/dependencies/`. Several modules can be
combined into a shared app collection.

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
  ];
}
```

Registering a collection is atomic: if one binding fails to be added, the
bindings of this collection already added are rolled back.

## Bootstrap and Flutter

The container is created before `runApp`, once async initialization is done. The scope
only publishes the ready container in the tree and disposes of it together with itself.

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

A Flutter extension shortens access to the scope:

```dart
final injector = context.injector;
final repository = context.di<PointsRepository>();
final handlers = context.diAll<ActionHandler>();
final hasLogger = context.hasDi<Logger>(key: 'diagnostics');
```

These methods are meant for a screen-level composition boundary, not for
reaching dependencies from `domain` or deep in the widget tree.

An optional user collection lives only within an active session:

```dart
context.initUserDependency(userDependencies);
context.disposeUserDependency();
```

After `dispose()` the factories and the singleton cache are removed, and the named container
is taken out of the global registry.
