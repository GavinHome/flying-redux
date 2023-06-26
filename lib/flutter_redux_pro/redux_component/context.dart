import 'dart:async';
import 'package:flutter/material.dart' hide Action, ViewBuilder;
import 'package:collection/collection.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'basic_component.dart';
import 'dependencies.dart';
import 'lifecycle.dart';

/// [Effect]是对副作用函数的定义.
/// 根据返回值, 判断该Action事件是否被消费.
typedef Effect<T> = FutureOr<void> Function(
    Action action, ComponentContext<T> ctx);

typedef SubEffect<T> = FutureOr<void> Function(
    Action action, ComponentContext<T> ctx);

// ignore: constant_identifier_names
const Object _SUB_EFFECT_RETURN_NULL = Object();

/// for action.type which override it's == operator
/// return [UserEffect]
Effect<T>? combineEffects<T>(Map<Object, SubEffect<T>> map) =>
    (map == null || map.isEmpty)
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

abstract class ComponentContext<T> {
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
