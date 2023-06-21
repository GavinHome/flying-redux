import 'package:flutter/widgets.dart' hide Action;
import 'dart:async';
import 'basic.dart';
import '../redux/index.dart';

class ComponentContext<T> {
  final ViewBuilder<T> view;
  final Store<T> store;
  final Get<T> getState;
  late Dispatch _dispatch;
  late ShouldUpdate<T> _shouldUpdate;
  final Function() markNeedsBuild;

  ComponentContext({
    required this.store,
    required this.getState,
    required this.view,
    required this.markNeedsBuild,
    ShouldUpdate<T>? shouldUpdate,
  }) {
    _shouldUpdate = shouldUpdate ?? _updateByDefault<T>();
    _dispatch = _createDispatch(_createNextDispatch(this));
    _latestState = getState();
  }

  T get state => getState();
  Widget? _widgetCache;
  late T _latestState;

  FutureOr<void> dispatch(Action action) => _dispatch.call(action);

  Widget buildView() {
    Widget? result = _widgetCache;
    result ??= _widgetCache = view(store.getState(), dispatch);
    return result;
  }

  void onNotify() {
    final T now = state;
    if (_shouldUpdate(_latestState, now)) {
      _widgetCache = null;
      markNeedsBuild();
      _latestState = now;
    }
  }

  Dispatch _createNextDispatch<T>(ComponentContext<T> ctx) => (Action action) {
        ctx.store.dispatch(action);
      };

  Dispatch _createDispatch<T>(Dispatch next) => (Action action) {
        final Object? result = null;
        if (result == null || result == false) {
          next(action);
        }

        return result == Object() ? null : result;
      };

  static ShouldUpdate<K> _updateByDefault<K>() =>
      (K _, K __) => !identical(_, __);
}
