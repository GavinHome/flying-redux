import 'package:flutter_redux/flutter_redux.dart';
import '../page/state.dart';
import '../report/state.dart';
import '../todo/component.dart';
import '../todo/state.dart';

class TodoListAdapter extends Adapter<PageState> {
  TodoListAdapter()
      : super(
    dependencies: FlowDependencies<PageState>(
            (PageState indexs) {
          final List<Dependent<PageState>> dependents = <Dependent<PageState>>[];
          int index = 0;
          for (ToDoState _ in indexs.toDos) {
            dependents.add(TodoConnector(toDoStates: indexs.toDos, index: index) + TodoComponent());
            index++;
          }
          return DependentArray<PageState>.fromList(
              dependents
          );
        }),
  );
}

class TodoConnector extends ConnOp<PageState, ToDoState> {
  TodoConnector({required this.toDoStates, required this.index}) : super();

  final List<ToDoState> toDoStates;
  final int index;

  @override
  ToDoState get(PageState state) {
    return toDoStates[index];
  }

  @override
  void set(PageState state, ToDoState subState) {
    state.toDos[index] = subState;
  }
}

class ReportConnector extends ConnOp<PageState, ReportState> {
  @override
  ReportState get(PageState state) {
    return ReportState()
      ..total = state.toDos.length
      ..done = state.toDos
          .where((e) => e.isDone)
          .length;
  }

  @override
  void set(PageState state, ReportState subState) {}
}
