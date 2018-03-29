import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  ChatItem.fromDS(String currentUserUID, DocumentSnapshot d):
    id = d.documentID,
    sender = d.data['sender'],
    addressee = d.data['addressee'],
    body = d.data['body'],
    type = d.data['type'],
    createdAt = d.data['createdAt'];

  final String id;
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
