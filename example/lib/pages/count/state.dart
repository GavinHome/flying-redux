import 'package:flying_redux/flying_redux.dart';

class PageState extends Cloneable<PageState> {
  late int count;

  @override
  PageState clone() {
    return PageState()..count = count;
  }

  @override
  String toString() {
    return 'count: ${count.toString()}';
  }
}

PageState initState(Map<String, dynamic>? args) {
  //just do something here...
  return PageState()..count = 99;
}
