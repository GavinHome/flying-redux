import 'package:flutter/material.dart' hide Action;

import '../redux/index.dart';
import 'context.dart';

Reducer<T> _noop<T>() => (T state, Action action) => state;

/// Component's view part
/// 1.State is used to decide how to render
/// 2.Dispatch is used to send actions
/// 3.ViewService is used to build sub-components or adapter.
typedef ViewBuilder<T> = Widget Function(
  T state,
  Dispatch dispatch,
);

/// Predicate if a component should be updated when the store is changed.
typedef ShouldUpdate<T> = bool Function(T old, T now);

abstract class BasicComponent<T> {
  BasicComponent({
    this.reducer,
    required this.view,
    this.shouldUpdate,
  });

  final Reducer<T>? reducer;
  final ViewBuilder<T> view;
  final ShouldUpdate<T>? shouldUpdate;

  Reducer<T> createReducer() {
    return combineReducers<T>(<Reducer<T>>[
          reducer ?? _noop(),
        ]) ??
        (T state, Action action) {
          return state;
        };
  }

  ComponentContext<T> createContext(Store<T> store, Get<T> getter,
          Function() markNeedsBuild, BuildContext buildContext) =>
      ComponentContext<T>(
        store: store,
        getState: getter,
        view: view,
        markNeedsBuild: markNeedsBuild,
        buildContext: buildContext,
        shouldUpdate: shouldUpdate,
      );

  Widget buildComponent(Store<T> store, Get<T> getter);
}
