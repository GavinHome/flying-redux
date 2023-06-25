import 'package:flutter/widgets.dart' hide Action;

import '../redux/index.dart';
import 'basic.dart';

/// Definition of the component Connector.
abstract class MutableConnector<T, P> {
  const MutableConnector();

  void set(T state, P subState);

  P get(T state);

  /// For mutable state, there are three abilities needed to be met.
  ///     1. get: (S) => P
  ///     2. set: (S, P) => void
  ///     3. shallow copy: s.clone()
  ///
  /// For immutable state, there are two abilities needed to be met.
  ///     1. get: (S) => P
  ///     2. set: (S, P) => S
  ///
  /// See in [connector].
  SubReducer<T>? subReducer(Reducer<P> reducer) {
    return reducer == null
        ? null
        : (T state, Action action, bool isStateCopied) {
            final P props = get(state);
            if (props == null) {
              return state;
            }
            final P newProps = reducer(props, action);
            final bool hasChanged = newProps != props;
            final T copy =
                (hasChanged && !isStateCopied) ? _clone<T>(state) : state;
            if (hasChanged) {
              set(copy, newProps);
            }
            return copy;
          };
  }
}

class NoneConn<T> extends MutableConnector<T, T> with ConnOpMixin<T, T>
{
  const NoneConn();

  @override
  T get(T state) => state;

  @override
  T set(T state, T subState) => subState;
}

abstract class ConnOp<T, P> extends MutableConnector<T, P> with ConnOpMixin<T, P>
{
  const ConnOp();

  @override
  P get(T state);

  @override
  void set(T state, P subState);
}

/// how to clone an object
dynamic _clone<T>(T state) {
  if (state is Cloneable) {
    return state.clone();
  } else if (state is List) {
    return state.toList();
  } else if (state is Map<String, dynamic>) {
    return <String, dynamic>{}..addAll(state);
  } else if (state == null) {
    return null;
  } else {
    throw ArgumentError(
        'Could not clone this state of type ${state.runtimeType}.');
  }
}

SubReducer<T>? _conn<T, P>(
    Reducer<Object> reducer, MutableConnector<T, P> connector) {
  return reducer == null
      ? null
      : connector
      .subReducer((P state, Action action) => reducer(state as Object, action) as P);
}

class _Dependent<T, P> extends Dependent<T> {
  final MutableConnector<T, P> connector;
  SubReducer<T>? _subReducer;
  final Reducer<P> _reducer;
  final BasicComponent<P> _component;

  _Dependent({
    required BasicComponent<P> component,
    required this.connector,
  })  : _reducer = component.createReducer(),
        _component = component {
    _subReducer = _conn<T, P>(
            (Object state, Action action) {
          return _reducer(state as P, action) as Object;
        },
        connector);
  }

  @override
  Widget buildComponent(
      Store<Object> store,
      Get<T> getter) {
    return _component.build(
      store,
          () => connector.get(getter())
    );
  }

  @override
  SubReducer<T> createSubReducer() => _subReducer!;

  @override
  BasicComponent<Object> get component => _component as BasicComponent<Object>;

  @override
  List<Widget> buildComponents(Store<Object> store, Get<T> getter) {
    return _component.buildComponents(
      store,
          () => connector.get(getter()),
    );
  }
}

_Dependent<K, T> createDependent<K, T>(
    MutableConnector<K, T> connector,
    BasicComponent<T> component,
    ) => (_Dependent<K, T>(
      connector: connector,
      component: component,
    ));

mixin ConnOpMixin<T, P> on MutableConnector<T, P> {
  Dependent<T> operator +(BasicComponent<P> component) => createDependent<T, P>(
    this,
    component,
  );
}
