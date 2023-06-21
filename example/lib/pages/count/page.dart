import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart' hide Page, Action;
import 'action.dart';
import 'reducer.dart';
import 'state.dart';

class CountPage extends Page<PageState, Map<String, dynamic>> {
  CountPage()
      : super(
            initState: initState, //此处初始化不涉及生命周期
            reducer: buildReducer(),
            view: (PageState state, Dispatch dispatch, ComponentContext ctx) {
              //如果不带有生命周期处理,则在view中处理网络请求数据
              //然后利用dispatch发送更改数据的reducer
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
