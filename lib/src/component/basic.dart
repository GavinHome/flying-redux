// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart' hide Action;
import 'package:collection/collection.dart';
import 'dart:async';
import '../redux/index.dart';
import 'context.dart';

/// component or page lifecycle
enum Lifecycle {
  initState,
  didChangeDependencies,
  build,
  reassemble,
  didUpdateWidget,
  deactivate,
  dispose
}

/// [Effect]是对副作用函数的定义.
/// 根据返回值, 判断该Action事件是否被消费.
typedef Effects<T> = FutureOr<void> Function(
    Action action, ComponentContext<T> ctx);

typedef Effect<T> = FutureOr<void> Function(
    Action action, ComponentContext<T> ctx);

/// for action.type which override it's == operator
/// return [UserEffect]
Effects<T>? combineEffects<T>(Map<Object, Effect<T>>? map) =>
    (map == null || map.isEmpty)
        ? null
        : (Action action, ComponentContext<T> ctx) {
            final Effect<T>? subEffect = map.entries
                .firstWhereOrNull((MapEntry<Object, Effect<T>> entry) =>
                    action.type == entry.key)
                ?.value;

            if (subEffect != null) {
              return (subEffect.call(action, ctx) ?? Object()) == null;
            }

            /// no subEffect
            return null;
          };

Reducer<T> _noop<T>() => (T state, Action action) => state;

/// Component's view part
/// 1.State is used to decide how to render
/// 2.Dispatch is used to send actions
/// 3.ViewService is used to build sub-components or adapter.
typedef ViewBuilder<T> = Widget Function(
    T state, Dispatch dispatch, ComponentContext<T> ctx);

/// Predicate if a component should be updated when the store is changed.
typedef ShouldUpdate<T> = bool Function(T old, T now);

abstract class BasicComponent<T> {
  BasicComponent(
      {this.reducer,
      this.view,
      this.shouldUpdate,
      this.effect,
      this.dependencies});

  final Dependencies<T>? dependencies;
  final Reducer<T>? reducer;
  final ViewBuilder<T>? view;
  final ShouldUpdate<T>? shouldUpdate;
  final Effects<T>? effect;

  Reducer<T> createReducer() {
    return combineReducers<T>(<Reducer<T>>[
          reducer ?? _noop(),
          dependencies?.createReducer() ?? _noop()
        ]) ??
        (T state, Action action) {
          return state;
        };
  }

  ComponentContext<T> createContext(Store<Object> store, Get<T> getter,
          {Function()? markNeedsBuild, BuildContext? buildContext}) =>
      ComponentContext<T>(
          store: store,
          getState: getter,
          view: view,
          effect: effect,
          markNeedsBuild: markNeedsBuild,
          buildContext: buildContext,
          shouldUpdate: shouldUpdate,
          dependencies: dependencies);

  Widget build(Store<Object> store, Get<T> getter);

  List<Widget> buildComponents(Store<Object> store, Get<T> getter);
}

class ReduxComponent<T> extends BasicComponent<T> {
  ReduxComponent(
      {Reducer<T>? reducer,
      required ViewBuilder<T> view,
      Dependencies<T>? dependencies,
      ShouldUpdate<T>? shouldUpdate,
      Effects<T>? effect})
      : super(
            reducer: reducer,
            view: view,
            dependencies: dependencies,
            shouldUpdate: shouldUpdate,
            effect: effect);

  @override
  Widget build(Store<Object> store, Get<T> getter) =>
      _ComponentWidget<T>(component: this, store: store, getter: getter);

  @override
  List<Widget> buildComponents(Store<Object> store, Get<T> getter) {
    return <Widget>[
      build(
        store,
        getter,
      )
    ];
  }
}

class _ComponentWidget<T> extends StatefulWidget {
  final BasicComponent<T> component;
  final Store<Object> store;
  final Get<T> getter;

  const _ComponentWidget({
    super.key,
    required this.component,
    required this.store,
    required this.getter,
  });

  @override
  _ComponentState<T> createState() => _ComponentState<T>();
}

class _ComponentState<T> extends State<_ComponentWidget<T>> {
  late ComponentContext<T> _ctx;
  BasicComponent<T> get component => widget.component;
  late Function() subscribe;

  @override
  void initState() {
    super.initState();
    _ctx = component.createContext(widget.store, widget.getter,
        markNeedsBuild: buildUpdate, buildContext: context);
    _ctx.onLifecycle(Lifecycle.initState);
    subscribe = _ctx.store.subscribe(_ctx.onNotify);
  }

  @override
  Widget build(BuildContext context) => _ctx.buildView()!;

  void buildUpdate() {
    if (mounted) {
      setState(() {});
    }
    Log.doPrint('${widget.component.runtimeType} do reload');
  }

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctx.onLifecycle(Lifecycle.didChangeDependencies);
  }

  @mustCallSuper
  @override
  void deactivate() {
    super.deactivate();
    _ctx.onLifecycle(Lifecycle.deactivate);
  }

  @override
  @protected
  @mustCallSuper
  void reassemble() {
    super.reassemble();
    _ctx.clearCache();
    _ctx.onLifecycle(Lifecycle.reassemble);
  }

  @mustCallSuper
  @override
  void didUpdateWidget(_ComponentWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ctx.didUpdateWidget();
    _ctx.onLifecycle(Lifecycle.didUpdateWidget);
  }

  @mustCallSuper
  @override
  void dispose() {
    _ctx.onLifecycle(Lifecycle.dispose);
    _ctx.dispose();
    subscribe();
    super.dispose();
  }
}

/// Definition of the component Dependent.
abstract class Dependent<T> {
  Widget buildComponent(Store<Object> store, Get<T> getter);

  List<Widget> buildComponents(Store<Object> store, Get<T> getter);

  SubReducer<T> createSubReducer();

  BasicComponent<Object> get component;
}

class Dependencies<T> {
  final Map<String, Dependent<T>>? slots;
  final Dependent<T>? adapter;

  Dependencies({
    this.slots,
    this.adapter,
  });

  Dependent<T>? slot(String type) => slots?[type];

  Reducer<T>? createReducer() {
    final List<SubReducer<T>> subs = <SubReducer<T>>[];
    if (slots != null && slots!.isNotEmpty) {
      subs.addAll(slots!.entries.map<SubReducer<T>>(
        (MapEntry<String, Dependent<T>> entry) =>
            entry.value.createSubReducer(),
      ));
    }

    if (adapter != null) {
      subs.add(adapter!.createSubReducer());
    }

    return combineReducers(<Reducer<T>>[
      combineSubReducers(subs) ?? (T state, Action action) => state
    ]);
  }
}

//////////////////////////////////////////
typedef IndexedDependentBuilder<T> = Dependent<T> Function(int);

class DependentArray<T> {
  final IndexedDependentBuilder<T> builder;
  final int length;

  DependentArray({required this.builder, required this.length})
      : assert(length >= 0);

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
        for (int i = 0; i < list.length; i++) {
          final Dependent<T> dep = list[i];
          final SubReducer<T> subReducer = dep.createSubReducer();
          copy = subReducer(copy, action, hasChanged);
          hasChanged = hasChanged || copy != state;
        }
        return copy;
      };
}

/// [ComposedComponent]
///
class Adapter<T> extends BasicComponent<T> {
  final FlowAdapterView<T> _adapter;
  final FlowDependencies<T> _dependencies;
  ComponentContext<T>? _ctx;
  DependentArray<T>? _dependentArray;

  Adapter({
    Reducer<T>? reducer,
    required FlowDependencies<T> dependencies,
    ShouldUpdate<T>? shouldUpdate,
  })  : _adapter = dependencies.build,
        _dependencies = dependencies,
        super(
          reducer: reducer,
          view: null,
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
  Widget build(Store<Object> store, Get<T> getter) {
    throw Exception('ComposedComponent could not build single component');
  }

  @override
  List<Widget> buildComponents(Store<Object> store, Get<T> getter) {
    _ctx ??= createContext(store, getter, markNeedsBuild: () {
      Log.doPrint('$runtimeType do reload');
    });
    _dependentArray = _adapter(getter());
    final List<Widget> widgets = <Widget>[];
    if (_dependentArray != null) {
      for (int i = 0; i < _dependentArray!.length; i++) {
        final Dependent<T> dependent = _dependentArray!.builder(i);
        widgets.add(
          dependent.buildComponent(store, getter),
        );
      }
    }
    _ctx?.onLifecycle(Lifecycle.initState);
    return widgets;
  }
}
