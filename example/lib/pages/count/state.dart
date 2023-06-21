import 'package:flutter_redux/flutter_redux.dart';

class PageState extends Cloneable<PageState> {
  late int count;

  @override
  PageState clone() {
    return PageState()..count = count;
  }
}

PageState initState(Map<String, dynamic> args) {
  //just do nothing here...
  return PageState()..count = 99;
}
