import 'package:flutter/material.dart' hide Action, ViewBuilder;

import '../redux/basic.dart';
import 'basic.dart';

/*
 * Page Container
 * <T>: Page State
 * <p>: Page Params
 */

class Component<T> extends ReduxComponent<T> {
  Component({Reducer<T>? reducer, required ViewBuilder<T> view, Effects<T>? effect, ShouldUpdate<T>? shouldUpdate, Dependencies<T>? dependencies})
      : super(
          reducer: reducer,
          view: view,
          effect: effect,
          shouldUpdate: shouldUpdate,
          dependencies: dependencies
        );

  Widget buildComponent(Store<Object> store, Get<T> getter) {
    return super.build(store, getter);
  }
}
