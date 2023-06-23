import 'package:flutter_redux/flutter_redux.dart';

import '../page/state.dart';

class ReportState implements Cloneable<ReportState> {
  int total;
  int done;

  ReportState({this.total = 0, this.done = 0});

  @override
  ReportState clone() {
    return ReportState()
      ..total = total
      ..done = done;
  }

  @override
  String toString() {
    return 'ReportState{total: $total, done: $done}';
  }

  static Get<ReportState> stateGetter(PageState state) {
    return () =>
    ReportState()
      ..total = state?.toDos?.length ?? 0
      ..done = state?.toDos
          ?.where((e) => e.isDone)
          ?.length ?? 0;
  }
}
