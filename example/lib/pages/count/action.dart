import 'package:flutter_redux/flutter_redux.dart';
import 'action.dart';
import 'state.dart';

enum CounterAction { increment }

class CounterActionCreator {
  static Action increment() {
    return const Action(CounterAction.increment, payload: 1);
  }
}
