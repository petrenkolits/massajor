import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Massajor/roster.dart';
import 'package:Massajor/settings.dart';
import 'package:Massajor/app-theme.dart';
import 'package:Massajor/login.dart';

void main() => runApp(new MainApp());

class _MainAppState extends State<MainApp> {
  FirebaseUser _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _getToken(String uid) async {
    print("Got UID: '$uid'");
    var client = new HttpClient();
    Uri uri = Uri.parse("https://us-central1-massajor-9e764.cloudfunctions.net/getToken?uid=$uid");
    var req = await client.getUrl(uri);
    var resp = await req.close();
    return await resp.transform(UTF8.decoder).join();
  }

  Future<Null> _handleLogin(String username, String pwd) async {
    var token = await _getToken(username);
    print(token);
    var usr = await _auth.signInWithCustomToken(token: token);
    setState(() {
      _user = usr;
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
      home: isUserSignedIn ? new Roster() : new Login(onLogin: _handleLogin),
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
