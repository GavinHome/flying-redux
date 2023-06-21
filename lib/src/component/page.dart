// ignore_for_file: unused_element

import 'package:flutter/widgets.dart' hide Action;

import '../redux/index.dart';
import 'basic.dart';
import 'context.dart';

typedef InitState<T, P> = T Function(P params);

/*
 * Page Container
 * <T>: Page State 
 * <p>: Page Params
 */
abstract class Page<T, P> {
  final InitState<T, P> initState;
  final Reducer<T> reducer;
  final ViewBuilder<T> view;

  Page({required this.initState, required this.reducer, required this.view});

  Widget buildPage(P param) => _PageWidget<T, P>(
        param: param,
        page: this,
      );

  Reducer<T> createReducer() {
    return combineReducers<T>(<Reducer<T>>[
          reducer,
        ]) ??
        (T state, Action action) {
          return state;
        };
  }

  ComponentContext<T> createContext(Store<T> store, Function() markNeedsBuild) =>
      ComponentContext<T>(store: store, getState: store.getState, view: view, markNeedsBuild: markNeedsBuild);
}

class _PageWidget<T, P> extends StatefulWidget {
  final P param;
  final Page<T, P> page;

  const _PageWidget({key, required this.param, required this.page})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageState<T, P>();
}

class _PageState<T, P> extends State<_PageWidget<T, P>> {
  late Store<T> _store;
  late T state;
  late ComponentContext<T> _ctx;
  get buildUpdate => setUpdate;

  @override
  void initState() {
    super.initState();
    state = widget.page.initState(widget.param);
    _store = createStore(state, widget.page.createReducer());
    _ctx = widget.page.createContext(_store, buildUpdate);
    _ctx.store.subscribe(_ctx.onNotify);
  }

  void setUpdate() {
      if (mounted) {
        setState(() {});
      }
      Log.doPrint('${widget.runtimeType} do relaod');
  }

  @override
  Widget build(BuildContext context) => _ctx.buildView();
}

class Log {
  static void doPrint([String? message]) {
    print('[FishRedux]: $message');
  }
}
