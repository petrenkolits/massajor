import 'package:flutter/foundation.dart';

class ChatItem {
  ChatItem({
    this.id,
    @required this.sender,
    @required this.addressee,
    @required this.currentUserUID,
    @required this.body,
    this.type,
    this.createdAt
  });

  String id;
  String body;
  String sender;
  String addressee;
  String currentUserUID;
  String type = 'text';
  DateTime createdAt = new DateTime.now();

  bool get isIncoming {
    return currentUserUID == addressee;
  }

  bool get isText {
    return type == 'text';
  }
}
