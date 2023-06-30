import 'package:flying_redux/flying_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import '../todo/state.dart';

class TodoEditState implements Cloneable<TodoEditState> {
  late ToDoState toDo;

  late TextEditingController nameEditController;
  late TextEditingController descEditController;

  late FocusNode focusNodeName;
  late FocusNode focusNodeDesc;

  @override
  TodoEditState clone() {
    return TodoEditState()
      ..nameEditController = nameEditController
      ..descEditController = descEditController
      ..focusNodeName = focusNodeName
      ..focusNodeDesc = focusNodeDesc
      ..toDo = toDo;
  }
}

TodoEditState initState(ToDoState? arg) {
  final TodoEditState state = TodoEditState();
  state.toDo = arg?.clone() ?? ToDoState();
  state.nameEditController = TextEditingController(text: arg?.title);
  state.descEditController = TextEditingController(text: arg?.desc);
  state.focusNodeName = FocusNode();
  state.focusNodeDesc = FocusNode();

  return state;
}
