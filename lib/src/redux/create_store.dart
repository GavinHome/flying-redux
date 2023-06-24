// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_null_comparison, dead_code, prefer_function_declarations_over_variables
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

  final List<_VoidCallback> _listeners = <_VoidCallback>[];

  T _state = preloadedState;
  Reducer<T> _reducer = reducer ?? _noop<T>();
  bool _isDispatching = false;

  Dispatch dispatch = (Action action) {
    _throwIfNot(action != null, 'Expected the action to be non-null value.');
    _throwIfNot(
        action.type != null, 'Expected the action.type to be non-null value.');
    _throwIfNot(!_isDispatching, 'Reducers may not dispatch actions.');

    try {
      _isDispatching = true;
      _state = _reducer(_state, action);
    } finally {
      _isDispatching = false;
    }

    final List<_VoidCallback> _notifyListeners = _listeners.toList(
      growable: false,
    );

    for (_VoidCallback listener in _notifyListeners) {
      listener();
    }
  };

  final Get<T> getState = (() => _state);

  final Subscribe subscribe = (_VoidCallback listener) {
    _throwIfNot(
      listener != null,
      'Expected the listener to be non-null value.',
    );
    _throwIfNot(
      !_isDispatching,
      'You may not call store.subscribe() while the reducer is executing.',
    );

    _listeners.add(listener);

    return () {
      _throwIfNot(
        !_isDispatching,
        'You may not unsubscribe from a store listener while the reducer is executing.',
      );
      _listeners.remove(listener);
    };
  };

  // final ReplaceReducer<T> _replaceReducer = (Reducer<T>? replaceReducer) {
  //   _reducer = replaceReducer ?? _noop();
  // };

  return Store<T>()
    ..getState = getState
    ..dispatch = dispatch
    ..subscribe = subscribe;
    // ..replaceReducer = _replaceReducer
}

/// create a store with enhancer
Store<T> createStore<T>(
  T preloadedState,
  Reducer<T>? reducer,
) =>
    _createStore(preloadedState, reducer);
