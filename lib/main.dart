import 'package:flutter/material.dart';
import 'package:everybody_cheese/app.dart';
import 'package:everybody_cheese/login.dart';

void main() => runApp(EverybodyCheeseApp());

class EverybodyCheeseApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Everybody Cheese',
      home: App(),
      initialRoute: '/login',
      onGenerateRoute: _getRoute,
      routes: {
        '/app': (BuildContext context) => App(),
//        '/home': (BuildContext context) => HomePage(),
      },
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}