import 'package:flutter/material.dart' hide Page;
import 'page.dart';

/// Define a basic behavior of routes.
abstract class AbstractRoutes {
  Widget get home;
  Widget buildPage(String? path, dynamic arguments);
}

/// Each page has a unique store.
@immutable
class PageRoutes implements AbstractRoutes {
  final Map<String, Page<Object, dynamic>> pages;
  final String? initialRoute;

  PageRoutes({
    this.initialRoute,
    required this.pages,

    /// For common enhance
    void Function(String, Page<Object, dynamic>)? visitor,
  }) {
    if (visitor != null) {
      pages.forEach(visitor);
    }
  }

  @override
  Widget buildPage(String? path, dynamic arguments) {
    assert(path != null && path.isNotEmpty && pages.keys.contains(path),
        "The path is empty or the element cannot be found, the page cannot be displayed");
    return pages[path]!.buildPage(arguments);
  }

  String? get initialRoutePath => initialRoute ?? pages.keys.toList(growable: false)[0];

  @override
  Widget get home => buildPage(initialRoutePath, <String, dynamic>{});
}
