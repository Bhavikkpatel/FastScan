import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './pages/Index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scanner',
      home: Index(),
    );
  }
}
