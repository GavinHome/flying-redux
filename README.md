<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

<!--TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them. -->

Flutter Redux fork from [Fish_Redux](https://github.com/alibaba/fish-redux). Because 
fish_redux has not been updated for a long time. I have done a lot of refactoring and 
modification based on fish_redux, and simplified some concepts, and finally renamed it.
Flutter Redux is also an assembled flutter application framework based on Redux state management.

## Features

<!--TODO: List what your package can do. Maybe include images, gifs, or videos.-->

It has four characteristics:

> 1. Functional Programming

> 2. Pluggable componentization

> 3. It Supports null safety

## Getting started

<!-- TODO: List prerequisites and provide or point to information on how to
start using the package. -->

There are three steps to use the counter as an example:

> 0. Add flutter_redux package

> 1. Create a state class and initialize the state

> 2. Define Action and Create ActionCreator

> 3. Create a function Reducer that modifies the state

> 4. Create a widgets view and Page for display

```dart
import 'package:flutter_redux/flutter_redux.dart';

/// [State]
class PageState extends Cloneable<PageState> {
  late int count;

  @override
  PageState clone() {
    return PageState()..count = count;
  }
}

/// [InitState]
PageState initState(Map<String, dynamic>? args) {
  //just do nothing here...
  return PageState()..count = 0;
}

/// [Action]
enum CounterAction { increment }

/// [ActionCreator]
class CounterActionCreator {
  static Action increment() {
    return const Action(CounterAction.increment, payload: 1);
  }
}

/// [Reducer]
buildReducer() {
  return asReducer(<Object, Reducer<PageState>>{
    CounterAction.increment: _increment,
  });
}

PageState _increment(PageState state, Action action) {
  final int num = action.payload;
  return state.clone()..count = (state.count + num);
}

/// [Page]
class CountPage extends Page<PageState, Map<String, dynamic>> {
  CountPage()
      : super(
            initState: initState,
            reducer: buildReducer(),
            view: (PageState state, Dispatch dispatch, ComponentContext<PageState> ctx) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'You have pushed the button this many times:',
                      ),
                      Text(state.count.toString()),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => dispatch(CounterActionCreator.increment()),
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ), // This trailing comma makes auto-formatting nicer for build methods.
              );
            });
}
```

## Usage

<!-- TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. -->

<!--
```dart
const like = 'sample';
```
-->
If you want to know specific usage examples, please refer to the todo list code in the example project.

-   [todo list](example) - a simple todo list demo.
-   run it:

``` dart
cd ./example
flutter run
```

## Additional information

<!-- TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more. -->
