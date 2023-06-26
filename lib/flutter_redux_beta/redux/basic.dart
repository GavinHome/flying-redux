import 'package:collection/collection.dart';

/// Definition of the standard Store.
class Store<T> {
  late Get<T> getState;
  late Dispatch dispatch;
  late ReplaceReducer<T> replaceReducer;
  late Subscribe subscribe;
}

/// [Action] message action
class Action {
  const Action(this.type, {this.payload});
  final Object type;
  final dynamic payload;
}

/// Definition of the function type that returns type R.
typedef Get<R> = R Function();

/// [Dispatch] patch action function
typedef Dispatch = dynamic Function(Action action);

/// Definition of a standard subscription function.
/// input a subscriber and output an anti-subscription function.
typedef Subscribe = void Function() Function(void Function() callback);

/// Definition of ReplaceReducer
typedef ReplaceReducer<T> = void Function(Reducer<T>? reducer);

/// [Reducer]是对状态变化函数的定义
/// 如果对状态有修改, 需要返回一个包含修改的新的对象.
typedef Reducer<T> = T Function(T, Action);

/// combine & as
/// for action.type which override it's == operator
Reducer<T> asReducer<T>(Map<Object, Reducer<T>> map) => (T state,
        Action action) =>
    map.entries
        .firstWhereOrNull(
            (MapEntry<Object, Reducer<T>> entry) => action.type == entry.key)
        ?.value(state, action) ??
    state;

/// Combine an iterable of Reducer<T> into one Reducer<T>
Reducer<T>? combineReducers<T>(Iterable<Reducer<T>>? reducers) {
  final List<Reducer<T>>? notNullReducers =
      reducers?.where((Reducer<T>? r) => r != null).toList(growable: false);
  if (notNullReducers == null || notNullReducers.isEmpty) {
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

typedef SubReducer<T> = T Function(T state, Action action, bool isStateCopied);

/// Combine an iterable of SubReducer<T> into one Reducer<T>
Reducer<T>? combineSubReducers<T>(Iterable<SubReducer<T>>? subReducers) {
  final List<SubReducer<T>>? notNullReducers = subReducers
      ?.where((SubReducer<T>? e) => e != null)
      .toList(growable: false);

  if (notNullReducers == null || notNullReducers.isEmpty) {
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

/// Definition of Cloneable
abstract class Cloneable<T extends Cloneable<T>> {
  T clone();
}