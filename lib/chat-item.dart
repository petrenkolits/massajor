import 'package:flutter/foundation.dart';

class ChatItem {
  ChatItem({
    this.id,
    @required this.sender,
    @required this.addressee,
    @required this.currentUserUID,
    @required this.body,
    this.createdAt
  });

  String id;
  String body;
  String sender;
  String addressee;
  String currentUserUID;
  DateTime createdAt = new DateTime.now();

  bool get isIncoming {
    return currentUserUID == addressee;
  }
}
