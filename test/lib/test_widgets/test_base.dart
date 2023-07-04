import 'package:flying_redux/flying_redux.dart';
import 'package:flutter/material.dart' hide Action, Page, ViewBuilder;

@immutable
class TestStub extends StatefulWidget {
  final Widget testWidget;
  final String title;

  const TestStub(this.testWidget, {super.key, this.title = 'FlutterTest'});

  @override
  StubState createState() => StubState();
}

class StubState extends State<TestStub> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: widget.title,
        home: Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: widget.testWidget));
  }
}

class TestPage<T extends Cloneable<T>, P> extends Page<T, P> {
  TestPage({
    required InitState<T, P> initState,
    List<Middleware<T>>? middleware,
    required ViewBuilder<T> view,
    Reducer<T>? reducer,
    Effect<T>? effect,
    Dependencies<T>? dependencies,
    ShouldUpdate<T>? shouldUpdate,
    Key Function(T)? key,
  }) : super(
          initState: initState,
          middleware: middleware,
          view: view,
          reducer: reducer,
          effect: effect,
          dependencies: dependencies,
          shouldUpdate: shouldUpdate,
        );
}

class TestComponent<T extends Cloneable<T>> extends Component<T> {
  TestComponent({
    required ViewBuilder<T> view,
    Reducer<T>? reducer,
    Effect<T>? effect,
    Dependencies<T>? dependencies,
    ShouldUpdate<T>? shouldUpdate,
    Key Function(T)? key,
  }) : super(
          view: view,
          reducer: reducer,
          effect: effect,
          dependencies: dependencies,
          shouldUpdate: shouldUpdate,
        );
}

// class TestAdapter<T extends Cloneable<T>> extends BasicAdapter<T> {
//   TestAdapter({
//     Reducer<T>? reducer,
//     required Dependents<T> Function(T) builder,
//     ShouldUpdate<T>? shouldUpdate,
//   }) : super(
//     reducer: reducer,
//     builder: builder,
//     shouldUpdate: shouldUpdate
//   );
// }
