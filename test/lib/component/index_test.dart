import 'package:flutter_test/flutter_test.dart';

import 'component_test.dart' as component;
import 'lifecycle_test.dart' as lifecycle;
import 'page_test.dart' as page;
import 'route_test.dart' as route;

void main() {
  group('redux_component_test', () {
    component.main();
    lifecycle.main();
    page.main();
    route.main();
  });
}
