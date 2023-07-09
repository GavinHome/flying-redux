import 'package:flying_redux/flying_redux.dart';
import 'state.dart';
import '../report/state.dart';
import '../todo/component.dart';
import '../todo/state.dart';

// Dependents<PageState> dependentBuilder(PageState state) => state.toDos
//     .asMap()
//     .keys
//     .map((index) =>
//         TodoConnector(toDos: state.toDos, index: index) + TodoComponent())
//     .toList();

// class PageAdapter extends BasicAdapter<PageState> {
//   PageAdapter() : super(
//       builder: dependentBuilder
//   );
// }

BasicAdapter<PageState> get adapter => BasicAdapter(
    builder: (PageState state) => state.toDos
        .asMap()
        .keys
        .map((index) =>
            TodoConnector(toDos: state.toDos, index: index) + TodoComponent())
        .toList());

class TodoConnector extends ConnOp<PageState, ToDoState> {
  TodoConnector({required this.toDos, required this.index}) : super();

  final List<ToDoState> toDos;
  final int index;

  @override
  ToDoState get(PageState state) {
    return toDos[index];
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
      ..done = state.toDos.where((e) => e.isDone).length;
  }

  @override
  void set(PageState state, ReportState subState) {}
}
