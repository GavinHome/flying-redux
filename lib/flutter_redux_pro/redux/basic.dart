import 'package:collection/collection.dart';

/// Definition of the function type that returns type R.
typedef Get<R> = R Function();

/// [Reducer]是对状态变化函数的定义
/// 如果对状态有修改, 需要返回一个包含修改的新的对象.
typedef Reducer<T> = T Function(T, Action);

/// combine & as
/// for action.type which override it's == operator
Reducer<T> asReducer<T>(Map<Object, Reducer<T>> map) => (map == null ||
        map.isEmpty)
    ? (T state, Action action) => state
    : (T state, Action action) =>
        map.entries
            .firstWhereOrNull((MapEntry<Object, Reducer<T>> entry) =>
                action.type == entry.key)
            ?.value(state, action) ??
        state;

typedef SubReducer<T> = T Function(T state, Action action, bool isStateCopied);

/// dispatch about
/// [DispatchBus] global eventBus
abstract class DispatchBus {
  void attach(DispatchBus parent);

  void detach();

  void dispatch(Action action, {Dispatch? excluded});

  void broadcast(Action action, {DispatchBus? excluded});

  void Function() registerReceiver(Dispatch? dispatch);
}

/// [Dispatch] patch action function
typedef Dispatch = dynamic Function(Action action);

/// [Action] [Effect] message action
class Action {
  const Action(this.type, {this.payload});
  final Object type;
  final dynamic payload;
}

/// [Store]
///

/// Definition of a standard subscription function.
/// input a subscriber and output an anti-subscription function.
typedef Subscribe = void Function() Function(void Function() callback);

/// Definition of the standard observable flow.
typedef Observable<T> = Stream<T> Function();

/// ReplaceReducer 的定义
typedef ReplaceReducer<T> = void Function(Reducer<T> reducer);

/// Definition of the standard Store.
class Store<T> {
  late Get<T> getState;
  late Dispatch dispatch;
  late Subscribe subscribe;
  late Observable<T> observable;
  late ReplaceReducer<T> replaceReducer;
  late Future<dynamic> Function() teardown;
}

/// Definition of synthesize functions.
typedef Composable<T> = T Function(T next);

/// Definition of the standard Middleware.
typedef Middleware<T> = Composable<Dispatch> Function({
  Dispatch dispatch,
  Get<T> getState,
});
