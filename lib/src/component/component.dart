// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'package:flutter/material.dart' hide Action, ViewBuilder;

import '../redux/basic.dart';
import 'basic.dart';
import 'context.dart';
import 'utils.dart';

class Component<T> extends ReduxComponent<T> {
  Component({Reducer<T>? reducer, required ViewBuilder<T> view, Effects<T>? effects, ShouldUpdate<T>? shouldUpdate})
      : assert(view != null),
        super(
          reducer: reducer,
          view: view,
          effects: effects,
          shouldUpdate: shouldUpdate,
        );

  Widget buildComponent(Store<Object?> store, Get<T> getter) {
    return super.build(store, getter);
  }
}
