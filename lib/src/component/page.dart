import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/index.dart';
import 'basic.dart';
import 'component.dart';

typedef InitState<T, P> = T Function(P? params);

/// [Page]
/// Implementation of Page component
abstract class Page<T, P> extends Component<T> {
  Page({
    required this.initState,
    this.middleware,
    Effect<T>? effect,
    Reducer<T>? reducer,
    Dependencies<T>? dependencies,
    required ViewBuilder<T> view,
    ShouldUpdate<T>? shouldUpdate,
  })  : super(
          effect: effect,
          dependencies: dependencies,
          reducer: reducer,
          view: view,
          shouldUpdate: shouldUpdate,
        );

  final InitState<T, P> initState;
  final List<Middleware<T>>? middleware;

  ///  build about
  Widget buildPage(P? param) => _PageWidget<T, P>(
        param: param,
        page: this,
      );
}

class _PageWidget<T, P> extends StatefulWidget {
  final P? param;
  final Page<T, P> page;

  const _PageWidget({
    Key? key,
    this.param,
    required this.page,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageState<T, P>();
}

class _PageState<T, P> extends State<_PageWidget<T, P>> {
  late Store<T> _store;
  DispatchBus? _pageBus;
  late T state;

  final Map<String, Object> extra = <String, Object>{};

  @override
  void initState() {
    super.initState();
    state = widget.page.initState(widget.param);
    _pageBus = DispatchBusDefault();
    _store = createStore(state, widget.page.createReducer(),
        middleware: widget.page.middleware);
    _pageBus?.registerReceiver(_store.dispatch);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return widget.page.buildComponent(_store as Store<Object>, _store.getState,
        dispatchBus: _pageBus);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
