// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart' hide Page, Action;
import '../report/component.dart';
import '../todo/state.dart';
import 'adapter.dart';
import 'state.dart';

/// Middleware for print action dispatch.
/// It works on debug mode.
Middleware<T> logMiddleware<T>({
  String tag = 'redux',
  required String Function(T?) monitor,
}) {
  return ({Dispatch? dispatch, Get<T>? getState}) {
    return (Dispatch next) {
      return (Action action) {
        print('---------- [$tag] ----------');
        print('[$tag] ${action.type} ${action.payload}');

        final T? prevState = getState?.call();
        if (monitor != null) {
          print('[$tag] prev-state: ${ monitor(prevState)}');
        }

        next(action);

        final T? nextState = getState?.call();
        if (monitor != null) {
          print('[$tag] next-state: ${monitor(nextState)}');
        }

        print('========== [$tag] ================');
      };
    };
  };
}

class ToDoListPage extends Page<PageState, Map<String, dynamic>> {
  ToDoListPage()
      : super(
    initState: initState,
    reducer: asReducer(
      <Object, Reducer<PageState>>{
        'initToDos': _init,
        'add': _add,
      },
    ),
    middleware: <Middleware<PageState>>[
      logMiddleware<PageState>(
          tag: 'ToDoListPage',
          monitor: (PageState? state) {
            return state.toString();
          })
    ],
    effect: combineEffects<PageState>(<Object, Effect<PageState>>{
      Lifecycle.initState: _onInit,
      'onAdd': _onAdd
    }),
    dependencies: Dependencies<PageState>(
      adapter: const NoneConn<PageState>() + TodoListAdapter(),
      slots:  <String, Dependent<PageState>>{
        'report': ReportConnector() + ReportComponent()
      },
    ),
    view: (PageState state, Dispatch dispatch,
        ComponentContext<PageState> ctx) {
      // final List<ToDoState> ws = state.toDos;
      final List<Widget> ws = ctx.buildComponents();
      return Scaffold(
        body: Stack(children: <Widget>[
          Container(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) => ws[index],
                  // TodoComponent().buildComponent(
                  //     ctx.store, () => ws[index]),
              //ctx.buildComponent(NoneConn<PageState>() + TodoComponent()),
              itemCount: ws.length,
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ctx.buildComponent('report'),
              // child: ReportComponent().buildComponent(ctx.store,
              //     ReportState.stateGetter(
              //         state)) //ctx.buildComponent('report'),
          )
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () => dispatch(const Action("onAdd")),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),

      );
    },
  );
}

/// effects
void _onInit(Action action, ComponentContext<PageState> ctx) {
  final List<ToDoState> initToDos = <ToDoState>[
    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    )
  ];

  ctx.dispatch(Action('initToDos', payload: initToDos));
}

void _onAdd(Action action, ComponentContext<PageState> ctx) {
  Navigator.of(ctx.context)
      .pushNamed('todo_edit', arguments: null)
      .then((dynamic toDo) {
    if (toDo != null &&
        (toDo.title?.isNotEmpty == true || toDo.desc?.isNotEmpty == true)) {
      ctx.dispatch(Action('add', payload: toDo)
      );
    }
  });
  // ctx.dispatch(Action('add', payload:
  //         ToDoState(
  //           uniqueId: '',
  //           title: 'Hello Flutter Redux',
  //           desc: 'Learn how to flutter redux program.',
  //           isDone: true,
  //         )
  // ));
}

/// reducers
PageState _init(PageState state, Action action) {
  final List<ToDoState> toDos = action.payload ?? <ToDoState>[];
  final PageState newState = state.clone();
  newState.toDos = toDos;
  return newState;
}

PageState _add(PageState state, Action action) {
  final ToDoState? toDo = action.payload;
  final PageState newState = state.clone();
  if(toDo != null) {
    newState.toDos.add(toDo);
  }

  return newState;
}

