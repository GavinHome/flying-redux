import 'package:flutter/material.dart' hide ViewBuilder, Action;

import '../redux/redux.dart';
import 'basic.dart';
import 'basic_component.dart';
import 'context.dart';
import 'dependencies.dart';

class Component<T> extends BasicComponent<T> {
  Component({
    Effect<T>? effect,
    Reducer<T>? reducer,
    Dependencies<T>? dependencies,
    required ViewBuilder<T> view,
    ShouldUpdate<T>? shouldUpdate,
  })  : assert(view != null),
        super(
          dependencies: dependencies,
          reducer: reducer ?? (T state, Action _) => state,
          effect: effect,
          view: view,
          shouldUpdate: shouldUpdate,
        );

  @override
  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    DispatchBus? dispatchBus,
  }) {
    return ComponentWidget<T>(
      component: this,
      store: store,
      bus: dispatchBus!,
      getter: getter,
      dependencies: dependencies,
    );
  }

  @override
  List<Widget> buildComponents(
    Store<Object> store,
    Get<T> getter, {
    DispatchBus? dispatchBus,
  }) {
    return <Widget>[
      buildComponent(
        store,
        getter,
        dispatchBus: dispatchBus,
      )
    ];
  }
}
