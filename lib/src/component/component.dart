// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'package:flutter/material.dart' hide Action, ViewBuilder;

import '../redux/basic.dart';
import 'basic.dart';

/*
 * Page Container
 * <T>: Page State
 * <p>: Page Params
 */

class Component<T, P> extends ReduxComponent<T> {
  Component({Reducer<T>? reducer, required ViewBuilder<T> view, Effects<T>? effects, ShouldUpdate<T>? shouldUpdate})
      : assert(view != null),
        super(
          reducer: reducer,
          view: view,
          effects: effects,
          shouldUpdate: shouldUpdate,
        );

  Widget buildComponent(Store<Object> store, Get<T> getter) {
    // store.replaceReducer((Object state, Action action) => state);
    return super.build(store, getter);
  }
}
