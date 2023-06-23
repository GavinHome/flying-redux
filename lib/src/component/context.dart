import 'package:flutter/widgets.dart' hide Action;
import 'dart:async';
import 'basic.dart';
import '../redux/index.dart';

class ComponentContext<T> {
  final ViewBuilder<T> view;
  final Effect<T>? effects;
  final Store<Object?> store;
  final Get<T> getState;
  late Dispatch _dispatch;
  late ShouldUpdate<T> _shouldUpdate;
  final BuildContext buildContext;
  final Function() markNeedsBuild;

  ComponentContext(
      {required this.store,
      required this.getState,
      required this.view,
      required this.markNeedsBuild,
      required this.buildContext,
      ShouldUpdate<T>? shouldUpdate,
        this.effects}) {
    _shouldUpdate = shouldUpdate ?? _updateByDefault<T>();
    _dispatch = _createDispatch(_createEffectDispatch(effects, this), _createNextDispatch(this), this);
    _latestState = getState();
  }

  T get state => getState();
  Widget? _widgetCache;
  late T _latestState;

  FutureOr<void> dispatch(Action action) => _dispatch.call(action);

  Widget buildView() {
    Widget? result = _widgetCache;
    result ??= _widgetCache = view(store.getState() as T, dispatch, this);
    return result;
  }

  /// return [EffectDispatch]
  Dispatch _createEffectDispatch<T>(
      Effects<T>? userEffect, ComponentContext<T> ctx) {
    return (Action action) {
      final Object? result = userEffect?.call(action, ctx);

      //skip-lifecycle-actions
      if (action.type is Lifecycle && (result == null || result == false)) {
        return Object();
      }

      return result;
    };
  }

  Dispatch _createNextDispatch<T>(ComponentContext<T> ctx) => (Action action) {
        ctx.store.dispatch(action);
      };

  Dispatch _createDispatch<T>(
      Dispatch onEffect, Dispatch next, ComponentContext<T> ctx) =>
          (Action action) {
        final Object? result = onEffect?.call(action);
        if (result == null || result == false) {
          next(action);
        }

        return result == Object() ? null : result;
      };

  void dispose() {
  }

  void onNotify() {
    final T now = state;
    if (_shouldUpdate(_latestState, now)) {
      _widgetCache = null;
      markNeedsBuild();
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

  void onLifecycle(Lifecycle type) {
    effects?.call(Action(type), this);
  }

  // Widget buildComponent(String type) {
  //   // final Dependent<T> dependent = _dependencies.slots[type];
  //   // assert(dependent != null);
  //   // return dependent.buildComponent(
  //   //   store,
  //   //   getState,
  //   //   bus: _bus,
  //   // );
  //   return Container();
  // }

  // List<Widget> buildComponents() {
  //   // final Dependent<T> dependent = _dependencies.adapter;
  //   // assert(dependent != null);
  //   // return dependent.buildComponents(
  //   //   store,
  //   //   getState,
  //   //   bus: _bus,
  //   // );
  //
  //   return <Widget>[Container()];
  // }

  static ShouldUpdate<K> _updateByDefault<K>() =>
      (K _, K __) => !identical(_, __);
}
