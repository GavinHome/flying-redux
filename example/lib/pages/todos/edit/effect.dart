import 'package:flying_redux/flying_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import '../todo/state.dart';
import 'action.dart';
import 'state.dart';

buildEffect() {
  return combineEffects(<Object, Effect<TodoEditState>>{
    ToDoEditAction.onDone: _onDone,
  });
}

void _onDone(Action action, ComponentContext<TodoEditState> ctx) {
  Navigator.of(ctx.context).pop<ToDoState>(
    ctx.state.toDo.clone()
      ..desc = ctx.state.descEditController.text
      ..title = ctx.state.nameEditController.text,
  );
}
