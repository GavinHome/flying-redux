import 'package:flutter/material.dart';
import 'routes.dart';

Widget createApp() {
  return const _App();
}

class _App extends StatelessWidget {
  // ignore: unused_element
  const _App

  ({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter redux pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: routes.home,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (BuildContext context) =>
            routes.buildPage(settings.name, settings.arguments)
        );
      },
    );
  }
}


