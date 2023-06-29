import 'package:flutter_redux/flutter_redux.dart';

import '../todo/state.dart';

class PageState implements Cloneable<PageState> {
  late List<ToDoState> toDos = [];

  @override
  PageState clone() {
    return PageState()..toDos = toDos;
  }

  @override
  String toString() {
    return 'toDos${toDos.toString()}';
  }
}

PageState initState(Map<String, dynamic>? args) {
  //just demo, do nothing here...
  return PageState()..toDos = [];
}
