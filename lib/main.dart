import 'package:connected_ride/views/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(App());

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.amber,
    ));

    return _mainRootWidget();
  }

  Widget _mainRootWidget() {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trip Share',
        home: Home()
    );
  }

}