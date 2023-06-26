import 'package:flutter/material.dart' hide Action;

import '../redux/index.dart';
import 'basic.dart';
import 'component.dart';

/// [Connector]
abstract class MutableConn<T, P> {
  const MutableConn();

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

/// Definition of Cloneable
abstract class Cloneable<T extends Cloneable<T>> {
  T clone();
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

class NoneConn<T> extends ConnOp<T, T> {
  const NoneConn();

  @override
  T get(T state) => state;

  @override
  T set(T state, T subState) => subState;
}

class ConnOp<T, P> extends MutableConn<T, P> with ConnOpMixin<T, P> {
  final P Function(T)? _getter;
  final void Function(T, P)? _setter;

  const ConnOp({
    P Function(T)? get,
    void Function(T, P)? set,
  })  : _getter = get,
        _setter = set;

  @override
  P get(T state) => _getter != null ? _getter!(state) : Object() as P;

  @override
  void set(T state, P subState) =>
      _setter != null ? _setter!(state, subState) : {};
}

SubReducer<T>? _conn<T, P>(
    Reducer<Object>? reducer, MutableConn<T, P> connector) {
  return reducer == null
      ? null
      : connector.subReducer(
          (P state, Action action) => reducer(state as Object, action) as P);
}

/// [_Dependent]
/// Implementation of Dependent
class _Dependent<T, P> extends Dependent<T> {
  final MutableConn<T, P> connector;
  SubReducer<T>? _subReducer;
  final Reducer<P> _reducer;
  final BasicComponent<P> _component;

  _Dependent({
    required BasicComponent<P> component,
    required this.connector,
  })  : _reducer = component.createReducer(),
        _component = component {
    _subReducer = _conn<T, P>(
        _reducer == null
            ? null
            : (Object state, Action action) {
                return _reducer(state as P, action) as Object;
              },
        connector);
  }

  @override
  bool isComponent() => _component is Component;

  @override
  bool isAdapter() => _component is ComposedComponent;

  @override
  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    DispatchBus? bus,
  }) {
    return _component.buildComponent(
      store,
      () => connector.get(getter()),
      dispatchBus: bus,
    );
  }

  @override
  SubReducer<T> createSubReducer() =>
      _subReducer ?? (T state, Action _, bool __) => state;

  @override
  List<Widget> buildComponents(
    Store<Object> store,
    Get<T> getter, {
    DispatchBus? bus,
  }) {
    return _component.buildComponents(
      store,
      () => connector.get(getter()),
      dispatchBus: bus,
    );
  }

  @override
  BasicComponent<Object> get component => _component as BasicComponent<Object>;
}

/// create a dependent
Dependent<K> createDependent<K, T>(
  MutableConn<K, T> connector,
  BasicComponent<T> component,
) =>
    (_Dependent<K, T>(
      connector: connector,
      component: component,
    ));
/// [ConnOpMixin]
/// Mixin of Connector for Component
mixin ConnOpMixin<T, P> on MutableConn<T, P> {
  Dependent<T> operator +(BasicComponent<P> component) => createDependent<T, P>(
        this,
        component,
      );
}
