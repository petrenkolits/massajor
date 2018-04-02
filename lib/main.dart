import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Massajor/db-service.dart';
import 'package:Massajor/roster.dart';
import 'package:Massajor/settings.dart';
import 'package:Massajor/app-theme.dart';
import 'package:Massajor/login.dart';

void main() => runApp(new MainApp());

class _MainAppState extends State<MainApp> {
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  DbService dbService = new DbService();
  FirebaseUser _user;

  void _handleLogin(String username, String pwd) async {
    dbService.user = await dbService.getUserForUID(username);
    String token = await _fcmSetupAndGetToken();
    if (token.isNotEmpty) {
      print("Got FCM token: '$token'");
      dbService.setFCMRegistration(dbService.user.uid, token);
    }
    setState(() {
      _user = dbService.user;
    });
  }

  Future<String> _fcmSetupAndGetToken() async {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(onMessage: _onMessage, onLaunch: _onLaunch, onResume: _onResume);
    return await _firebaseMessaging.getToken();
  }

  Future<dynamic> _onMessage(Map<String, dynamic> args) async {
    print(args.keys);
  }

  Future<dynamic> _onLaunch(Map<String, dynamic> args) async {
    print('_onLaunch');
  }

  Future<dynamic> _onResume(Map<String, dynamic> args) async {
    print('_onResume');
  }

  get isUserSignedIn => _user != null;

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
