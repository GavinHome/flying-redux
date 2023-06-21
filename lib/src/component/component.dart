// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'package:flutter/material.dart' hide Action, ViewBuilder;

import '../redux/basic.dart';
import 'basic.dart';
import 'context.dart';
import 'utils.dart';

class Component<T> extends BasicComponent<T> {
  final Reducer<T>? reducer;
  final ViewBuilder<T> view;
  final ShouldUpdate<T>? shouldUpdate;

  Component({required this.reducer, required this.view, this.shouldUpdate})
      : assert(view != null),
        super(
          reducer: reducer,
          view: view,
          shouldUpdate: shouldUpdate,
        );

  @override
  Widget buildComponent(Store<T> store, Get<T> getter) =>
      ComponentWidget<T>(component: this, store: store, getter: getter);
}

class ComponentWidget<T> extends StatefulWidget {
  final Component<T> component;
  final Store<T> store;
  final Get<T> getter;

  const ComponentWidget({
    super.key,
    required this.component,
    required this.store,
    required this.getter,
  })  : assert(store != null),
        assert(getter != null);

  @override
  _ComponentState<T> createState() => _ComponentState<T>();
}

class _ComponentState<T> extends State<ComponentWidget<T>> {
  late ComponentContext<T> _ctx;
  Component<T> get component => widget.component;
  late Function() subscribe;

  @override
  void initState() {
    super.initState();
    _ctx = component.createContext(
        widget.store, widget.getter, buildUpdate, context);
    subscribe = _ctx.store.subscribe(_ctx.onNotify);
  }

  @override
  Widget build(BuildContext context) => _ctx.buildView();

  void buildUpdate() {
    if (mounted) {
      setState(() {});
    }
    Log.doPrint('${widget.component.runtimeType} do relaod');
  }

  @mustCallSuper
  @override
  void dispose() {
    subscribe();
    super.dispose();
  }
}
