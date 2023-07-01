import 'package:collection/collection.dart';

/// [Action]
/// Effect or Reducer message action
class Action {
  const Action(this.type, {this.payload});
  final Object type;
  final dynamic payload;
}

/// [Store]
/// Definition of the standard Store.
class Store<T> {
  late Get<T> getState;
  late Dispatch dispatch;
  late Subscribe subscribe;
  late Observable<T> observable;
  late ReplaceReducer<T> replaceReducer;
  late Future<dynamic> Function() teardown;
}

/// [Get]
/// Definition of the function type that returns type R.
typedef Get<R> = R Function();

/// [Dispatch] patch action function
typedef Dispatch = dynamic Function(Action action);

/// [Subscribe]
/// Definition of a standard subscription function.
/// input a subscriber and output an unsubscription function.
typedef Subscribe = void Function() Function(void Function() callback);

/// [Observable]
/// Definition of the standard observable flow.
typedef Observable<T> = Stream<T> Function();

/// [ReplaceReducer]
/// Definition of a standard ReplaceReducer function.
typedef ReplaceReducer<T> = void Function(Reducer<T> reducer);

/// [Middleware]
/// Definition of the standard Middleware.
typedef Middleware<T> = Composable<Dispatch> Function({
  Dispatch dispatch,
  Get<T> getState,
});

/// Definition of synthesize functions.
typedef Composable<T> = T Function(T next);

/// [Reducer]
/// Definition of the state change function
/// If there is a modification to the state, a new object containing
/// the modification needs to be returned.
typedef Reducer<T> = T Function(T, Action);

/// [SubReducer]
/// Definition of the sub-state change function
typedef SubReducer<T> = T Function(T state, Action action, bool isStateCopied);

/// [asReducer]
/// combine & as
/// for action.type which override it's == operator
Reducer<T>? asReducer<T>(Map<Object, Reducer<T>>? map) => (map == null ||
        map.isEmpty)
    ? (T state, Action action) => state
    : (T state, Action action) =>
        map.entries
            .firstWhereOrNull((MapEntry<Object, Reducer<T>> entry) =>
                action.type == entry.key)
            ?.value(state, action) ??
        state;

/// [CombineReducers]
/// Combine an iterable of SubReducer<T> into one Reducer<T>
Reducer<T>? combineSubReducers<T>(Iterable<SubReducer<T>> subReducers) {
  final List<SubReducer<T>> notNullReducers = subReducers
      .toList(growable: false);

  if (notNullReducers.isEmpty) {
    return null;
  }

  if (notNullReducers.length == 1) {
    final SubReducer<T> single = notNullReducers.single;
    return (T state, Action action) => single(state, action, false);
  }

  return (T state, Action action) {
    T copy = state;
    bool hasChanged = false;
    for (SubReducer<T> subReducer in notNullReducers) {
      copy = subReducer(copy, action, hasChanged);
      hasChanged = hasChanged || copy != state;
    }
    assert(copy != null);
    return copy;
  };
}

/// Combine an iterable of Reducer<T> into one Reducer<T>
Reducer<T>? combineReducers<T>(Iterable<Reducer<T>> reducers) {
  final List<Reducer<T>> notNullReducers =
      reducers.toList(growable: false);

  if (notNullReducers.isEmpty) {
    return null;
  }

  if (notNullReducers.length == 1) {
    return notNullReducers.single;
  }

  return (T state, Action action) {
    T nextState = state;
    for (Reducer<T> reducer in notNullReducers) {
      nextState = reducer(nextState, action);
    }
    assert(nextState != null);
    return nextState;
  };
}
