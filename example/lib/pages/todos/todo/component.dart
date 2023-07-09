import 'package:flying_redux/flying_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'effect.dart';
import 'action.dart';
import 'reducer.dart';
import 'state.dart';

class TodoComponent extends Component<ToDoState> {
  TodoComponent()
      : super(
          reducer: buildReducer(),
          effect: buildEffect(),
          view: (ToDoState state, Dispatch dispatch,
              ComponentContext<ToDoState> ctx) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        height: 36.0,
                        color: state.isDone ? Colors.green : Colors.red,
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              child: const Icon(Icons.label_outline),
                            ),
                            Expanded(
                                child: Text(
                              state.title ?? '',
                              maxLines: 1,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            )),
                            GestureDetector(
                              child: Container(
                                margin: const EdgeInsets.only(right: 16.0),
                                child: (() => state.isDone
                                    ? const Icon(Icons.check_box)
                                    : const Icon(
                                        Icons.check_box_outline_blank))(),
                              ),
                              onTap: () {
                                dispatch(ToDoActionCreator.doneAction(
                                    state.uniqueId));
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
                      color: const Color(0xFFE0E0E0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            state.desc ?? '',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16.0),
                          )),
                          GestureDetector(
                            child: const Icon(Icons.edit),
                            onTap: () {
                              dispatch(ToDoActionCreator.onEditAction(
                                  state.uniqueId));
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
                onLongPress: () {
                  dispatch(ToDoActionCreator.onRemoveAction(state.uniqueId));
                },
              ),
            );
          },
        );
}
