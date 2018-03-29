import 'package:flutter/foundation.dart';

class ChatTitleBarData {
  ChatTitleBarData({
    @required this.title,
    this.isTyping
  });

  String title;
  bool isTyping = false;

  String get status {
    return isTyping ? 'typing...' : 'idle';
  }
}
