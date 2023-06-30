import 'package:flying_redux/flying_redux.dart';

import 'pages/count/page.dart';
import 'pages/todos/edit/page.dart';
import 'pages/todos/page/page.dart';

final AbstractRoutes routes = PageRoutes(
  initialRoute: 'todo_list',
  pages: <String, Page<Object, dynamic>>{
    /// Register TodoList main page
    'todo_list': ToDoListPage(),

    /// Register Todo edit page
    'todo_edit': TodoEditPage(),

    /// Register Count page
    'count': CountPage(),
  },
  visitor: (String path, Page<Object, dynamic> page) {
    Log.doPrint("route visitor, $path");
  },
);
