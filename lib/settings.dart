import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  final String title = 'Settings';

  @override
  State<StatefulWidget> createState() => new _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title)
      )
    );
  }
}
