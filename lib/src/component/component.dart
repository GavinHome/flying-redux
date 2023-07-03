import 'package:flutter/material.dart' hide ViewBuilder, Action;

import '../redux/index.dart';
import 'basic.dart';

/// [Component]
/// Implementation of Component
class Component<T> extends BasicComponent<T> {
  Component({
    Effect<T>? effect,
    Reducer<T>? reducer,
    Dependencies<T>? dependencies,
    required ViewBuilder<T> view,
    ShouldUpdate<T>? shouldUpdate,
  }) : super(
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
    return _ComponentWidget<T>(
      component: this,
      store: store,
      bus: dispatchBus,
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

class _ComponentWidget<T> extends StatefulWidget {
  final BasicComponent<T> component;
  final Store<Object> store;
  final Get<T> getter;
  final DispatchBus? bus;
  final Dependencies<T>? dependencies;

  const _ComponentWidget({
    required this.component,
    required this.store,
    required this.getter,
    this.dependencies,
    this.bus,
    Key? key,
  }) : super(key: key);

  @override
  _ComponentState<T> createState() => _ComponentState<T>();
}

class _ComponentState<T> extends State<_ComponentWidget<T>> {
  late ComponentContext<T> _ctx;
  BasicComponent<T> get component => widget.component;
  late Function() subscribe;

  @override
  void initState() {
    super.initState();
    _ctx = component.createContext(
      widget.store,
      widget.getter,
      buildContext: context,
      bus: widget.bus,
      markNeedsBuild: () {
        if (mounted) {
          setState(() {});
        }
        Log.doPrint('${component.runtimeType} do reload');
      },
    );
    _ctx.onLifecycle(LifecycleCreator.initState());
    subscribe = _ctx.store.subscribe(_ctx.onNotify);
  }

  @override
  Widget build(BuildContext context) => _ctx.buildView();

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctx.onLifecycle(LifecycleCreator.didChangeDependencies());
  }

  @mustCallSuper
  @override
  void deactivate() {
    super.deactivate();
    _ctx.onLifecycle(LifecycleCreator.deactivate());
  }

  @override
  @protected
  @mustCallSuper
  void reassemble() {
    super.reassemble();
    _ctx.clearCache();
    _ctx.onLifecycle(LifecycleCreator.reassemble());
  }

  @mustCallSuper
  @override
  void didUpdateWidget(_ComponentWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ctx.didUpdateWidget();
    _ctx.onLifecycle(LifecycleCreator.didUpdateWidget());
  }

  @mustCallSuper
  void disposeCtx() {
    _ctx
      ..onLifecycle(LifecycleCreator.dispose())
      ..dispose();
  }

  @mustCallSuper
  @override
  void dispose() {
    disposeCtx();
    subscribe();
    super.dispose();
  }
}
