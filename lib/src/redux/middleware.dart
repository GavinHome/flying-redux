import 'package:flutter/foundation.dart';

import 'basic.dart';

/// Middleware for print action dispatch.
/// It works on debug mode.
Middleware<T> logMiddleware<T>({
  String tag = 'redux',
  required String Function(T?) monitor,
}) {
  return ({Dispatch? dispatch, Get<T>? getState}) {
    return (Dispatch next) {
      return (Action action) {
        _doPrint('---------- [$tag] ----------');
        _doPrint('[$tag] ${action.type} ${action.payload}');

        final T? prevState = getState?.call();
        if (monitor != null) {
          _doPrint('[$tag] prev-state: ${monitor(prevState)}');
        }

        next(action);

        final T? nextState = getState?.call();
        if (monitor != null) {
          _doPrint('[$tag] next-state: ${monitor(nextState)}');
        }

        _doPrint('========== [$tag] ================');
      };
    };
  };
}

void _doPrint([String? message]) {
  if (kDebugMode) {
    print('[FishRedux]: $message');
  }
}
