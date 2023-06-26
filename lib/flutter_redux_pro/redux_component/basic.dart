import 'dart:async';
import 'package:flutter/material.dart' hide Action;
import 'package:collection/collection.dart';
import '../redux/index.dart';
import 'log.dart';

/////////////////////////////////////////////////////////
/// basic
/// Predicate if a component should be updated when the store is changed.
typedef ShouldUpdate<T> = bool Function(T old, T now);

abstract class ComponentBase<T> {}

abstract class Dependent<T> {
  bool isComponent();

  bool isAdapter();

  Widget buildComponent(
      Store<Object> store,
      Get<T> getter, {
        DispatchBus? bus,
      });

  List<Widget> buildComponents(
      Store<Object> store,
      Get<T> getter, {
        DispatchBus? bus,
      });

  SubReducer<T> createSubReducer();

  ComponentBase<Object> get component;
}

class Dependencies<T> {
  final Map<String, Dependent<T>> slots;
  final Dependent<T> adapter;

  /// Use [adapter: NoneConn<T>() + Adapter<T>()] instead of [adapter: Adapter<T>()],
  /// Which is better reusability and consistency.
  Dependencies({
    required this.slots,
    required this.adapter,
  }) : assert(adapter == null || adapter.isAdapter(),
  'The dependent must contains adapter.');

  Dependent<T>? slot(String type) => slots[type];

  Dependencies<T>? trim() =>
      adapter != null || slots?.isNotEmpty == true ? this : null;

  Reducer<T> createReducer() {
    final List<SubReducer<T>> subs = <SubReducer<T>>[];
    if (slots != null && slots.isNotEmpty) {
      subs.addAll(slots.entries.map<SubReducer<T>>(
            (MapEntry<String, Dependent<T>> entry) =>
            entry.value.createSubReducer(),
      ));
    }

    if (adapter != null) {
      subs.add(adapter.createSubReducer());
    }

    return combineReducers(<Reducer<T>>[
      combineSubReducers(subs) ?? (T state, Action action) => state
    ]) ??
            (T state, _) => state;
  }
}

enum Lifecycle {
  /// component(page) or adapter receives the following events
  initState,
  didChangeDependencies,
  build,
  reassemble,
  didUpdateWidget,
  deactivate,
  dispose,
  // didDisposed,

  /// Only a adapter mixin VisibleChangeMixin will receive appear & disappear events.
  /// class MyAdapter extends Adapter<T> with VisibleChangeMixin<T> {
  ///   MyAdapter():super(
  ///     ///
  ///   );
  /// }
  appear,
  disappear,

  /// Only a component(page) or adapter mixin WidgetsBindingObserverMixin will receive didChangeAppLifecycleState event.
  /// class MyComponent extends Component<T> with WidgetsBindingObserverMixin<T> {
  ///   MyComponent():super(
  ///     ///
  ///   );
  /// }
  didChangeAppLifecycleState,
}

class LifecycleCreator {
  static Action initState() => const Action(Lifecycle.initState);

  static Action build(String name) => Action(Lifecycle.build, payload: name);

  static Action reassemble() => const Action(Lifecycle.reassemble);

  static Action dispose() => const Action(Lifecycle.dispose);

  // static Action didDisposed() => const Action(Lifecycle.didDisposed);

  static Action didUpdateWidget() => const Action(Lifecycle.didUpdateWidget);

  static Action didChangeDependencies() =>
      const Action(Lifecycle.didChangeDependencies);

  static Action deactivate() => const Action(Lifecycle.deactivate);

  static Action appear(int index) => Action(Lifecycle.appear, payload: index);

  static Action disappear(int index) =>
      Action(Lifecycle.disappear, payload: index);
}

/// A little different with Dispatch (with if it is interrupted).
/// bool for sync-functions, interrupted if true
/// Future<void> for async-functions, should always be interrupted.
// typedef OnAction = Dispatch;

/////////////////////////////////////////////////////////
/// context
class ComponentContext<T> {
  ComponentContext({
    Dependencies<T>? dependencies,
    DispatchBus? bus,
    this.markNeedsBuild,
    required this.store,
    required this.getState,
    this.view,
    this.effect,
    this.buildContext,
    ShouldUpdate<T>? shouldUpdate,
  })  : _dependencies = dependencies,
        _bus = bus,
        _shouldUpdate = shouldUpdate ?? _updateByDefault<T>() {
    _init();
  }

  final ViewBuilder<T>? view;
  final Dependencies<T>? _dependencies;
  final DispatchBus? _bus;
  final Effect<T>? effect;
  final Store<Object> store;
  final Get<T> getState;
  final Function()? markNeedsBuild;
  final ShouldUpdate<T> _shouldUpdate;
  final BuildContext? buildContext;
  late Dispatch _dispatch;
  late Dispatch _effectDispatch;

  T get state => getState();
  Widget? _widgetCache;
  late T _latestState;

  Widget buildView() {
    Widget? result = _widgetCache;
    if (result == null) {
      dispatch(LifecycleCreator.build(''));
    }
    result ??= _widgetCache = view!.call(getState(), dispatch, this);
    return result;
  }

  FutureOr<void> dispatch(Action action) => _dispatch.call(action);

  void broadcastEffect(Action action, {bool? excluded}) => _bus
      ?.dispatch(action, excluded: excluded == true ? _effectDispatch : null);

  Widget buildComponent(String type) {
    final Dependent<T>? dependent = _dependencies?.slots[type];
    assert(dependent != null);
    return dependent!.buildComponent(
      store,
      getState,
      bus: _bus!,
    );
  }

  List<Widget> buildComponents() {
    final Dependent<T> dependent = _dependencies!.adapter;
    assert(dependent != null);
    return dependent.buildComponents(
      store,
      getState,
      bus: _bus!,
    );
  }

  Function()? _dispatchDispose;

  Dispatch _createNextDispatch<T>(ComponentContext<T> ctx) => (Action action) {
    ctx.store.dispatch(action);
  };

  void _init() {
    _effectDispatch = _createEffectDispatch(effect, this);
    _dispatch =
        _createDispatch(_effectDispatch, _createNextDispatch(this), this);
    _dispatchDispose = _bus!.registerReceiver(_effectDispatch);
    _latestState = getState();
  }

  void dispose() {
    _dispatchDispose?.call();
    _dispatchDispose = null;
  }

  void onNotify() {
    final T now = state;
    if (_shouldUpdate(_latestState, now)) {
      _widgetCache = null;
      markNeedsBuild?.call();
      _latestState = now;
    }
  }

  void didUpdateWidget() {
    final T now = state;
    if (_shouldUpdate(_latestState, now)) {
      _widgetCache = null;
      _latestState = now;
    }
  }

  // public method
  //
  void onLifecycle(Action action) {
    effect?.call(action, this);
  }

  void clearCache() {
    _widgetCache = null;
  }

  /// return [EffectDispatch]
  Dispatch _createEffectDispatch<T>(
      Effect<T>? userEffect, ComponentContext<T> ctx) {
    return (Action action) {
      final Object? result = userEffect?.call(action, ctx);

      //skip-lifecycle-actions
      if (action.type is Lifecycle && (result == null || result == false)) {
        return Object();
      }

      return result;
    };
  }

  Dispatch _createDispatch<T>(
      Dispatch onEffect, Dispatch next, ComponentContext<T> ctx) =>
          (Action action) {
        final Object? result = onEffect?.call(action);
        if (result == null || result == false) {
          next(action);
        }

        return result == Object() ? null : result;
      };

  static ShouldUpdate<K> _updateByDefault<K>() =>
          (K _, K __) => !identical(_, __);
}

/// Component's view part
/// 1.State is used to decide how to render
/// 2.Dispatch is used to send actions
/// 3.ViewService is used to build sub-components or adapter.
typedef ViewBuilder<T> = Widget Function(
    T state,
    Dispatch dispatch,
    ComponentContext<T> context,
    );

/// [Effect] is the definition of the side effect function.
/// According to the return value, determine whether the Action event is consumed.
typedef Effect<T> = FutureOr<void> Function(
    Action action, ComponentContext<T> ctx);

typedef SubEffect<T> = FutureOr<void> Function(
    Action action, ComponentContext<T> ctx);

// ignore: constant_identifier_names
const Object _SUB_EFFECT_RETURN_NULL = Object();

/// for action.type which override it's == operator
/// return [UserEffect]
Effect<T>? combineEffects<T>(Map<Object, SubEffect<T>> map) {
  return (map == null || map.isEmpty)
      ? null
      : (Action action, ComponentContext<T> ctx) {
    final SubEffect<T>? subEffect = map.entries
        .firstWhereOrNull((MapEntry<Object, SubEffect<T>> entry) =>
    action.type == entry.key)
        ?.value;

    if (subEffect != null) {
      return (subEffect.call(action, ctx) ?? _SUB_EFFECT_RETURN_NULL) ==
          null;
    }

    /// no subEffect
    return null;
  };
}


/////////////////////////////////////////////////////////
/// BasicComponent
abstract class BasicComponent<T> extends ComponentBase<T> {
  BasicComponent({
    this.effect,
    required this.reducer,
    this.dependencies,
    this.view,
    this.shouldUpdate,
  });

  final Dependencies<T>? dependencies;
  final Reducer<T> reducer;
  final Effect<T>? effect;
  final ViewBuilder<T>? view;
  final ShouldUpdate<T>? shouldUpdate;

  Reducer<T> createReducer() {
    return combineReducers<T>(<Reducer<T>>[
      reducer,
      dependencies?.createReducer() ?? (T state, Action action) => state
    ]) ??
            (T state, Action action) {
          return state;
        };
  }

  ComponentContext<T> createContext(
      Store<Object> store,
      Get<T> getter, {
        DispatchBus? bus,
        Function()? markNeedsBuild,
        BuildContext? buildContext,
      }) {
    return ComponentContext<T>(
      store: store,
      bus: bus,
      getState: getter,
      markNeedsBuild: markNeedsBuild,
      dependencies: dependencies,
      view: view,
      effect: effect,
      buildContext: buildContext,
      shouldUpdate: shouldUpdate,
    );
  }

  Widget buildComponent(
      Store<Object> store,
      Get<T> getter, {
        DispatchBus? dispatchBus,
      });

  List<Widget> buildComponents(
      Store<Object> store,
      Get<T> getter, {
        DispatchBus? dispatchBus,
      });
}

//////////////////////////////////////////////////////////////
/// ComposedComponent
typedef IndexedDependentBuilder<T> = Dependent<T> Function(int);

class DependentArray<T> {
  final IndexedDependentBuilder<T> builder;
  final int length;

  DependentArray({required this.builder, required this.length})
      : assert(builder != null && length >= 0);

  DependentArray.fromList(List<Dependent<T>> list)
      : this(builder: (int index) => list[index], length: list.length);

  Dependent<T> operator [](int index) => builder(index);
}

typedef FlowAdapterView<T> = DependentArray<T> Function(T);

class FlowDependencies<T> {
  final FlowAdapterView<T> build;

  const FlowDependencies(this.build);

  Reducer<T> createReducer() => (T state, Action action) {
    T copy = state;
    bool hasChanged = false;
    final DependentArray<T> list = build(state);
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        final Dependent<T> dep = list[i];
        final SubReducer<T>? subReducer = dep?.createSubReducer();
        if (subReducer != null) {
          copy = subReducer(copy, action, hasChanged);
          hasChanged = hasChanged || copy != state;
        }
      }
    }
    return copy;
  };
}

abstract class ComposedComponent<T> extends BasicComponent<T> {
  ComposedComponent(
      {required Reducer<T> reducer, ShouldUpdate<T>? shouldUpdate}) : super(
      reducer: reducer,
      view: null,
      shouldUpdate: shouldUpdate
  );
}

/// [Adapter]
///
class Adapter<T> extends ComposedComponent<T> {
  final FlowAdapterView<T> _adapter;
  final FlowDependencies<T> _dependencies;
  ComponentContext<T>? _ctx;

  Adapter({
    Reducer<T>? reducer,
    required FlowDependencies<T> dependencies,
    ShouldUpdate<T>? shouldUpdate,
  })  : _adapter = dependencies.build,
        _dependencies = dependencies,
        super(
        reducer: reducer ?? (T state, Action _) => state,
        shouldUpdate: shouldUpdate,
      );

  @override
  Reducer<T> createReducer() {
    return combineReducers<T>(<Reducer<T>>[
      super.createReducer(),
      _dependencies.createReducer()
    ]) ??
            (T state, Action action) {
          return state;
        };
  }

  @override
  Widget buildComponent(
      Store<Object> store,
      Get<T> getter, {
        DispatchBus? dispatchBus,
      }) {
    throw Exception('ComposedComponent could not build single component');
  }

  DependentArray<T>? _dependentArray;

  @override
  List<Widget> buildComponents(
      Store<Object> store,
      Get<T> getter, {
        DispatchBus? dispatchBus,
      }) {
    _ctx ??= createContext(
      store,
      getter,
      bus: dispatchBus,
      markNeedsBuild: () {
        Log.doPrint('$runtimeType do relaod');
      },
    );
    _dependentArray = _adapter(getter());
    final List<Widget> widgets = <Widget>[];
    if (_dependentArray != null) {
      for (int i = 0; i < _dependentArray!.length; i++) {
        final Dependent<T> dependent = _dependentArray!.builder(i);
        widgets.addAll(
          dependent.buildComponents(
            store,
            getter,
            bus: dispatchBus,
          ),
        );
      }
    }
    _ctx!.onLifecycle(LifecycleCreator.initState());
    return widgets;
  }
}
