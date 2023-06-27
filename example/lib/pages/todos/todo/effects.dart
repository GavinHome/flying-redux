import 'package:flutter/material.dart' hide Action, Page;
import 'package:flutter_redux/flutter_redux.dart';

import 'action.dart';
import 'state.dart';

buildEffects() {
  return combineEffects<ToDoState>(<Object, Effect<ToDoState>>{
    ToDoAction.onEdit: _onEdit,
    ToDoAction.onRemove: _onRemove,
  });
}

void _onEdit(Action action, ComponentContext<ToDoState> ctx) {
  if (action.payload == ctx.state.uniqueId) {
    Navigator.of(ctx.context)
        // .push<ToDoState>(MaterialPageRoute<ToDoState>(
        //     builder: (BuildContext buildCtx) =>
        //         edit_page.TodoEditPage().buildPage(ctx.state)))
        .pushNamed('todo_edit', arguments: ctx.state)
        .then((dynamic toDo) {
      if (toDo != null) {
        ctx.dispatch(ToDoActionCreator.editAction(toDo));
      }
    });
  }
}

void _onRemove(Action action, ComponentContext<ToDoState> ctx) async {
  if (action.payload == ctx.state.uniqueId) {
    final String? select = await showDialog<String>(
        context: ctx.context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: Text('Are you sure to delete "${ctx.state.title}"?'),
            actions: <Widget>[
              GestureDetector(
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () => Navigator.of(buildContext).pop(),
              ),
              GestureDetector(
                child: const Text('Yes', style: TextStyle(fontSize: 16.0)),
                onTap: () => Navigator.of(buildContext).pop('Yes'),
              )
            ],
          );
        });

    if (select == 'Yes') {
      ctx.dispatch(ToDoActionCreator.removeAction(ctx.state.uniqueId));
    }
  }
}
