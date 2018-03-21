import 'package:flutter/material.dart';
import 'package:Massajor/roster.dart';
import 'package:Massajor/settings.dart';
import 'package:Massajor/app-theme.dart';
import 'package:Massajor/login.dart';

void main() => runApp(new MainApp());

class _MainAppState extends State<MainApp> {
  bool _userSignedIn = false;

  void _handleLogin(String username, String pwd) {
    setState(() {
      _userSignedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Massajor',
      theme: AppTheme.currentTheme,
      home: _userSignedIn ? new Roster() : new Login(onLogin: _handleLogin),
      routes: <String, WidgetBuilder>{
        '/settings': (BuildContext context) => new Settings()
      }
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MainAppState();
}
