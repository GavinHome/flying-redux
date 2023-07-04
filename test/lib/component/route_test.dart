import 'package:flying_redux/flying_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;
import 'package:flutter_test/flutter_test.dart';
import '../test_widgets/page/page.dart';
import '../test_widgets/page/state.dart';
import '../test_widgets/test_base.dart';

void main() {
  group('routes_test', () {
    test('create pageRoutes', () {
      TestPage<ToDoList, Map> toDoListPage = TestPage<ToDoList, Map>(
        initState: initState,
        view: toDoListView,
      );
      TestPage<ToDoList, Map> countPage = TestPage<ToDoList, Map>(
        initState: (Map? map) => ToDoList.fromMap(map ?? {}),
        view: (
          Object state,
          Dispatch dispatch,
          ComponentContext<Object> ctx,
        ) =>
            const Text("Counter App"),
      );

      final AbstractRoutes routes = PageRoutes(
          initialRoute: 'todo_list',
          pages: <String, Page<Object, dynamic>>{
            'todo_list': toDoListPage,
            'count_page': countPage,
          });

      expect(routes, isNotNull);
      expect(routes, const TypeMatcher<AbstractRoutes>());
      expect(routes.home, isNotNull);
      expect(routes.home, const TypeMatcher<StatefulWidget>());

      final toDoListWidget = routes.buildPage('todo_list', null);
      expect(toDoListWidget, isNotNull);
      expect(toDoListWidget, const TypeMatcher<StatefulWidget>());
    });
  });
}
