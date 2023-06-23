// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart' hide Page, Action;
import 'state.dart';
import '../todo/state.dart';

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
    view: (PageState state, Dispatch dispatch,
        ComponentContext<PageState> ctx) {
      List<ToDoState> _ws = state.toDos;
      return Scaffold(
          body: Stack(children: <Widget>[
            Container(
              // child: ListView.builder(
              //   itemBuilder: (BuildContext context, int index) => _ws[index],
              //   itemCount: _ws?.length ?? 0,
              // ),
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) => Text(_ws?[index]?.title ?? "test"),
                itemCount: _ws?.length ?? 0,
              ),
            ),
            // Positioned(
            //     bottom: 0,
            //     left: 0,
            //     right: 0,
            //     child: ReportComponent().buildComponent(ctx.store, ReportState.stateGetter(state)) //ctx.buildComponent('report'),
            // )
          ]),
        floatingActionButton: FloatingActionButton(
              onPressed: () => dispatch(const Action("onAdd")),
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),

      );
    },
    effects: combineEffects<PageState>(<Object, Effect<PageState>>{
      Lifecycle.initState: _onInit,
      'onAdd': _onAdd
    }),
  );
}

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
  ctx.dispatch(Action('add', payload:
          ToDoState(
            uniqueId: '',
            title: 'Hello Flutter Redux',
            desc: 'Learn how to flutter redux program.',
            isDone: true,
          )
  ));
}

PageState _init(PageState state, Action action) {
  final List<ToDoState> toDos = action.payload ?? <ToDoState>[];
  final PageState newState = state.clone();
  newState.toDos = toDos;
  return newState;
}

PageState _add(PageState state, Action action) {
  final ToDoState toDo = action.payload;
  final PageState newState = state.clone();
  if(toDo != null) {
    newState.toDos.add(toDo);
  }

  return newState;
}