import 'package:flutter_redux/flutter_redux.dart';
import 'package:sample/pages/count/state.dart';

enum CounterAction { increment }

class CounterActionCreator {
  static Action increment() {
    return const Action(CounterAction.increment, payload: 1);
  }
}
