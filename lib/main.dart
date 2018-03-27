import 'package:Massajor/db-service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Massajor/roster.dart';
import 'package:Massajor/settings.dart';
import 'package:Massajor/app-theme.dart';
import 'package:Massajor/login.dart';

void main() => runApp(new MainApp());

class _MainAppState extends State<MainApp> {
  DbService dbService = new DbService();
  FirebaseUser _user;

  void _handleLogin(String username, String pwd) async {
    dbService.user = await dbService.getUserForUID(username);
    setState(() {
      _user = dbService.user;
    });
  }

  get isUserSignedIn {
    return _user != null;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Massajor',
      theme: AppTheme.currentTheme,
      home: isUserSignedIn ? new Roster(user: _user) : new Login(onLogin: _handleLogin),
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
