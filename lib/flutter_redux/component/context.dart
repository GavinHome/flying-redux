import 'package:flutter/widgets.dart' hide Action;
import 'dart:async';
import '../redux/index.dart';
import 'basic.dart';

class ComponentContext<T> {
  final ViewBuilder<T>? view;
  final Effect<T>? effect;
  final Store<Object> store;
  final Get<T> getState;
  late Dispatch _dispatch;
  late ShouldUpdate<T> _shouldUpdate;
  final BuildContext? buildContext;
  final Function()? markNeedsBuild;
  final Dependencies<T>? dependencies;

  ComponentContext(
      {required this.store,
      required this.getState,
      this.view,
      this.dependencies,
      this.markNeedsBuild,
      this.buildContext,
      ShouldUpdate<T>? shouldUpdate,
      this.effect}) {
    _shouldUpdate = shouldUpdate ?? _updateByDefault<T>();
    _dispatch = _createDispatch(
        _createEffectDispatch(effect, this), _createNextDispatch(this), this);
    _latestState = getState();
  }

  T get state => getState();
  Widget? _widgetCache;
  late T _latestState;

  FutureOr<void> dispatch(Action action) => _dispatch.call(action);

  Widget? buildView() {
    Widget? result = _widgetCache;
    result ??= _widgetCache = view?.call(getState(), dispatch, this);
    return result;
  }

  Widget buildComponent(String type) {
    final Dependent<T>? dependent = dependencies?.slot(type);
    if (dependent == null) {
      throw Exception("The dependent $type is not defined");
    }

    return dependent.buildComponent(
      store,
      getState,
    );
  }

  List<Widget> buildComponents() {
    final Dependent<T>? dependent = dependencies?.adapter;
    if (dependent == null) throw Exception("The adapter is not defined");
    return dependent.buildComponents(
      store,
      getState,
    );
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
          Dispatch? onEffect, Dispatch next, ComponentContext<T> ctx) =>
      (Action action) {
        final Object? result = onEffect?.call(action);
        if (result == null || result == false) {
          next(action);
        }

        return result == Object() ? null : result;
      };

  void dispose() {}

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

  void onLifecycle(Lifecycle type) {
    effect?.call(Action(type), this);
  }

  void clearCache() {
    _widgetCache = null;
  }

  static ShouldUpdate<K> _updateByDefault<K>() =>
      (K _, K __) => !identical(_, __);
}
