import 'package:flutter_redux/flutter_redux.dart';
import 'action.dart';
import 'state.dart';

buildEffects() {
  return combineEffects<ToDoState>(<Object, Effect<ToDoState>>{
    // Lifecycle.initState: _onInit,
    ToDoAction.onEdit: _onEdit,
    ToDoAction.onRemove: _onRemove,
  });
}

void _onEdit(Action action, ComponentContext<ToDoState> ctx) {
  final String uniqueId = action.payload;
  final ToDoState todo = ToDoState()
    ..title = ""
    ..desc = "";
  ctx.dispatch(ToDoActionCreator.editAction(todo));
}

void _onRemove(Action action, ComponentContext<ToDoState> ctx) {
  final String uniqueId = action.payload;
  ctx.dispatch(ToDoActionCreator.removeAction(uniqueId));
}
