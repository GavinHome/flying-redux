import 'package:collection/collection.dart';
/// Definition of the function type that returns type R.
typedef Get<R> = R Function();

/// [Action] message action
class Action {
  const Action(this.type, {this.payload});
  final Object type;
  final dynamic payload;
}

/// [Dispatch] patch action function
typedef Dispatch = dynamic Function(Action action);

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

/// Definition of a standard subscription function.
/// input a subscriber and output an anti-subscription function.
typedef Subscribe = void Function() Function(void Function() callback);

/// Definition of the standard Store.
class Store<T> {
  late Get<T> getState;
  late Dispatch dispatch;
  late Subscribe subscribe;
}

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

/// Definition of Cloneable
abstract class Cloneable<T extends Cloneable<T>> {
  T clone();
}
