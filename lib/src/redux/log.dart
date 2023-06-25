import 'package:flutter/foundation.dart';

class Log {
  static void doPrint([String? message]) {
    if (kDebugMode) {
      print('[FlutterRedux]: $message');
    }
  }
}
