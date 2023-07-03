import 'package:flutter_test/flutter_test.dart';

import 'redux/index_test.dart' as redux;
import 'component/index_test.dart' as component;

void main() {
  group('all_test', () {
    redux.main();
    component.main();
  });
}
