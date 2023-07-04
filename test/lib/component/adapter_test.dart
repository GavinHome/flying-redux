import 'package:flying_redux/flying_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;
import 'package:flutter_test/flutter_test.dart';

import '../test_widgets/component/action.dart';
import '../test_widgets/component/component.dart';
import '../test_widgets/component/page.dart';
import '../test_widgets/component/state.dart';
import '../test_widgets/test_base.dart';

import '../instrument.dart';
import '../track.dart';

class ToDoComponentInstrument extends TestComponent<Todo> {
  ToDoComponentInstrument(final Track track, int index,
      {bool hasReducer = true})
      : super(
            view: instrumentView<Todo>(toDoView, (Todo state, Dispatch dispatch,
                ComponentContext<Todo> viewService) {
              print('toDo$index-build');
              track.append('toDo$index-build', state.clone());
            }),
            reducer: hasReducer
                ? instrumentReducer<Todo>(toDoReducer,
                    change: (Todo state, Action action) {
                    track.append('toDo$index-onReduce', state.clone());
                  })
                : null,
            effect: instrumentEffect<Todo>(toDoEffect,
                (Action action, Get<Todo> getState) {
              if (action.type == ToDoAction.onEdit) {
                track.append('toDo$index-onEdit', getState().clone());
              } else if (action.type == ToDoAction.broadcast) {
                track.append('toDo$index-onToDoBroadcast', getState().clone());
              } else if (action.type == ToDoListAction.broadcast) {
                track.append('toDo$index-onPageBroadcast', getState().clone());
              }
            }),
            shouldUpdate: shouldUpdate);
}

class ToDoComponent extends ToDoComponentInstrument {
  ToDoComponent(final Track track, final int index)
      : super(track, index, hasReducer: false);
}

Dependencies<ToDoList> toDoListDependencies(final Track track) =>
    Dependencies<ToDoList>(
      adapter: const NoneConn<ToDoList>() +
          BasicAdapter<ToDoList>(
              builder: (ToDoList state) => state.list
                  .asMap()
                  .keys
                  .map((index) =>
                      ConnOp<ToDoList, Todo>(
                          get: (ToDoList toDoList) => toDoList.list[index],
                          set: (ToDoList toDoList, Todo toDo) =>
                              toDoList.list[index] = toDo) +
                      ToDoComponent(track, index))
                  .toList()),
    );

Widget pageView(
  ToDoList state,
  Dispatch dispatch,
  ComponentContext<ToDoList> viewService,
) {
  final List<Widget> ws = viewService.buildComponents();
  return Stack(children: <Widget>[
    ListView.builder(
      itemBuilder: (BuildContext context, int index) => ws[index],
      itemCount: ws.length,
    ),
    Row(
      children: <Widget>[
        Expanded(
            child: GestureDetector(
          child: Container(
            key: const ValueKey('Add'),
            height: 68.0,
            color: Colors.green,
            alignment: AlignmentDirectional.center,
            child: const Text('Add'),
          ),
          onTap: () {
            print('dispatch Add');
            dispatch(const Action(ToDoListAction.onAdd));
          },
          onLongPress: () {
            print('dispatch broadcast');
            dispatch(const Action(ToDoListAction.onBroadcast));
          },
        )),
      ],
    ),
  ]);
}

void main() {
  group('adapter-dependency-component', () {
    test('create', () {
      final TestComponent<Todo> component = TestComponent<Todo>(
        view: toDoView,
      );
      expect(component, isNotNull);

      final Widget componentWidget = component.buildComponent(
        createStore<Todo>(Todo.mock(), null),
        () => Todo.mock(),
      );
      expect(componentWidget, isNotNull);
    });

    testWidgets('build', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView, (ToDoList state,
                  Dispatch dispatch, ComponentContext<ToDoList> viewService) {
                track.append('page-build', state.clone());
              }),
              reducer: toDoListReducer,
              effect: toDoListEffect,
              dependencies: toDoListDependencies(track))
          .buildPage(pageInitParams)));

      expect(find.byKey(const ValueKey<String>('Add')), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-0')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-0')), findsOneWidget);
      expect(find.text('desc-0'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-0')), findsOneWidget);
      expect(find.text('title-0'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-1')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-1')), findsOneWidget);
      expect(find.text('desc-1'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-1')), findsOneWidget);
      expect(find.text('title-1'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-2')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-2')), findsOneWidget);
      expect(find.text('desc-2'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-2')), findsOneWidget);
      expect(find.text('title-2'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-3')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-3')), findsOneWidget);
      expect(find.text('desc-3'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-3')), findsOneWidget);
      expect(find.text('title-3'), findsOneWidget);

      expect(find.text('mark\ndone'), findsNWidgets(3));
      expect(find.text('done'), findsOneWidget);

      expect(track.countOfTag('page-build'), 1);
      expect(track.countOfTag('toDo0-build'), 1);
      expect(track.countOfTag('toDo1-build'), 1);
      expect(track.countOfTag('toDo2-build'), 1);
      expect(track.countOfTag('toDo3-build'), 1);

      track.reset();
    });
  });
}
