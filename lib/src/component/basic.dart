// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart' hide Action;
import 'package:collection/collection.dart';
import 'dart:async';
import '../redux/index.dart';
import 'context.dart';
import 'utils.dart';

Reducer<T> _noop<T>() => (T state, Action action) => state;

/// Component's view part
/// 1.State is used to decide how to render
/// 2.Dispatch is used to send actions
/// 3.ViewService is used to build sub-components or adapter.
typedef ViewBuilder<T> = Widget Function(
    T state, Dispatch dispatch, ComponentContext<T> ctx);

/// Setup for component
// typedef Setup<T> = void Function(Lifecycle lifeCycle, Dispatch dispatch, ComponentContext<T> ctx);
// typedef Setup<T> = Map<Lifecycle, void Function(Dispatch dispatch)>;

/// Predicate if a component should be updated when the store is changed.
typedef ShouldUpdate<T> = bool Function(T old, T now);

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
typedef Effects<T> = FutureOr<void> Function(Action action, ComponentContext<T> ctx);

typedef Effect<T> = FutureOr<void> Function(Action action, ComponentContext<T> ctx);

/// for action.type which override it's == operator
/// return [UserEffect]
Effects<T>? combineEffects<T>(Map<Object, Effect<T>>? map) =>
    (map == null || map.isEmpty)
        ? null
        : (Action action, ComponentContext<T> ctx) {
      final Effect<T>? subEffect = map.entries
          .firstWhereOrNull(
              (MapEntry<Object, Effect<T>> entry) =>
          action.type == entry.key)?.value;

      if (subEffect != null) {
        return (subEffect.call(action, ctx) ?? Object()) == null;
      }

      /// no subEffect
      return null;
    };

abstract class BasicComponent<T> {
  BasicComponent({
    this.reducer,
    required this.view,
    this.shouldUpdate,
    this.effects,
  });

  final Reducer<T>? reducer;
  final ViewBuilder<T> view;
  final ShouldUpdate<T>? shouldUpdate;
  final Effects<T>? effects;

  Reducer<T> createReducer() {
    return combineReducers<T>(<Reducer<T>>[
          reducer ?? _noop(),
        ]) ??
        (T state, Action action) {
          return state;
        };
  }

  ComponentContext<T> createContext(Store<Object> store, Get<T> getter,
          Function() markNeedsBuild, BuildContext buildContext) =>
      ComponentContext<T>(
        store: store,
        getState: getter,
        view: view,
        effects: effects,
        markNeedsBuild: markNeedsBuild,
        buildContext: buildContext,
        shouldUpdate: shouldUpdate,
      );

  Widget build(Store<Object> store, Get<T> getter);
}

class ReduxComponent<T> extends BasicComponent<T> {
  ReduxComponent({Reducer<T>? reducer, required ViewBuilder<T> view, ShouldUpdate<T>? shouldUpdate, Effects<T>? effects})
      : super(
        reducer: reducer,
        view: view,
        shouldUpdate: shouldUpdate,
          effects: effects
      );

  @override
  Widget build(Store<Object> store, Get<T> getter) =>
      _ComponentWidget<T>(component: this, store: store, getter: getter);
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
    _ctx = component.createContext(
        widget.store, widget.getter, buildUpdate, context);
    _ctx.onLifecycle(Lifecycle.initState);
    subscribe = _ctx.store.subscribe(_ctx.onNotify);
  }

  @override
  Widget build(BuildContext context) => _ctx.buildView();

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
    // _ctx.clearCache();
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
