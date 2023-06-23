import 'package:flutter/material.dart';
import 'package:sample/pages/count/page.dart';
import 'package:sample/pages/todos/page/page.dart';

Widget createApp() {
  return const _App();
}

class _App extends StatelessWidget {
  // ignore: unused_element
  const _App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: 
        //CountPage().buildPage(<String, dynamic>{}),
      ToDoListPage().buildPage(<String, dynamic>{})
    );
  }
}
