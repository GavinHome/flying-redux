import 'package:flying_redux/flying_redux.dart';
import 'package:flutter/material.dart' hide Page, Action;
import '../todo/action.dart';
import '../report/component.dart';
// import '../todo/component.dart';
import '../todo/state.dart';
import 'adapter.dart';
import 'state.dart';

class ToDoListPage extends Page<PageState, Map<String, dynamic>> {
  ToDoListPage()
      : super(
          initState: initState,
          reducer: asReducer(
            <Object, Reducer<PageState>>{
              'initToDos': _init,
              'add': _add,
              ToDoAction.remove: _remove
            },
          ),
          middleware: <Middleware<PageState>>[
            logMiddleware<PageState>(
                tag: 'ToDoListPage',
                monitor: (PageState? state) {
                  return state == null ? '' : state.toString();
                })
          ],
          effect: combineEffects<PageState>(<Object, Effect<PageState>>{
            Lifecycle.initState: _onInit,
            'onAdd': _onAdd
          }),
          dependencies: Dependencies<PageState>(
            // adapter: const NoneConn<PageState>() +
            //     BasicAdapter<PageState>(
            //         builder: (PageState state) => state.toDos
            //             .asMap()
            //             .keys
            //             .map((index) =>
            //                 TodoConnector(toDos: state.toDos, index: index) +
            //                 TodoComponent())
            //             .toList()),

            // adapter: const NoneConn<PageState>() +
            //     BasicAdapter<PageState>(builder: dependentBuilder),
            // adapter: const NoneConn<PageState>() + PageAdapter(),

            adapter: const NoneConn<PageState>() + adapter,
            slots: <String, Dependent<PageState>>{
              'report': ReportConnector() + ReportComponent(),
            },
          ),
          view: (PageState state, Dispatch dispatch,
              ComponentContext<PageState> ctx) {
            final List<Widget> ws = ctx.buildComponents();
            return Scaffold(
              body: Stack(children: <Widget>[
                ListView.builder(
                  itemBuilder: (BuildContext context, int index) => ws[index],
                  itemCount: ws.length,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ctx.buildComponent('report'),
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
      title: 'How Flying Redux',
      desc: 'Learn how to use Flying Redux in a flutter application.',
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
      ctx.dispatch(Action('add', payload: toDo));
    }
  });
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
  if (toDo != null) {
    newState.toDos.add(toDo);
  }

  return newState;
}

PageState _remove(PageState state, Action action) {
  final String unique = action.payload;
  return state.clone()
    ..toDos = (state.toDos.toList()
      ..removeWhere((ToDoState state) => state.uniqueId == unique));
}
