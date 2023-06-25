// ignore_for_file:  no_leading_underscores_for_local_identifiers, prefer_function_declarations_over_variables
import 'basic.dart';

Reducer<T> _noop<T>() => (T state, Action action) => state;

typedef _VoidCallback = void Function();

void _throwIfNot(bool condition, [String? message]) {
  if (!condition) {
    throw ArgumentError(message);
  }
}

Store<T> _createStore<T>(final T preloadedState, final Reducer<T>? reducer) {
  _throwIfNot(
    preloadedState != null,
    'Expected the preloadedState to be non-null value.',
  );

  final List<_VoidCallback> listeners = <_VoidCallback>[];

  T state = preloadedState;
  Reducer<T> _reducer = reducer ?? _noop<T>();
  bool isDispatching = false;

  Dispatch dispatch = (Action action) {
    _throwIfNot(!isDispatching, 'Reducers may not dispatch actions.');

    try {
      isDispatching = true;
      state = _reducer(state, action);
    } finally {
      isDispatching = false;
    }

    final List<_VoidCallback> notifyListeners = listeners.toList(
      growable: false,
    );

    for (_VoidCallback listener in notifyListeners) {
      listener();
    }
  };

  final Get<T> getState = (() => state);

  final Subscribe subscribe = (_VoidCallback listener) {
    _throwIfNot(
      !isDispatching,
      'You may not call store.subscribe() while the reducer is executing.',
    );

    listeners.add(listener);

    return () {
      _throwIfNot(
        !isDispatching,
        'You may not unsubscribe from a store listener while the reducer is executing.',
      );
      listeners.remove(listener);
    };
  };

  final ReplaceReducer<T> replaceReducer = (Reducer<T>? replaceReducer) {
    _reducer = replaceReducer ?? _noop();
  };

  return Store<T>()
    ..getState = getState
    ..dispatch = dispatch
    ..replaceReducer = replaceReducer
    ..subscribe = subscribe;
}

/// create a store with enhancer
Store<T> createStore<T>(
  T preloadedState,
  Reducer<T>? reducer,
) =>
    _createStore(preloadedState, reducer);
