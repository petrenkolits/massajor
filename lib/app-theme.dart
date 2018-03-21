import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData _kIOSTheme = new ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light,
  );

  static final ThemeData _kDefaultTheme = new ThemeData(
    primarySwatch: Colors.purple,
    accentColor: Colors.orangeAccent[400],
  );

  static ThemeData get currentTheme {
    return defaultTargetPlatform == TargetPlatform.iOS ? _kIOSTheme : _kDefaultTheme;
  }
}
