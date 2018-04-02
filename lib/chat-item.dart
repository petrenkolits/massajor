import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatItem {
  final String id;
  String body;
  String sender;
  String addressee;
  String currentUserUID;
  String status;
  String type;
  DateTime createdAt;

  ChatItem({
    this.id,
    @required this.sender,
    @required this.addressee,
    @required this.currentUserUID,
    @required this.body,
    this.status = 'unread',
    this.type = 'text',
    this.createdAt
  }) {
    this.createdAt ??= new DateTime.now();
  }

  ChatItem.fromDS(String currentUserUID, DocumentSnapshot d):
    id = d.documentID,
    sender = d.data['sender'],
    addressee = d.data['addressee'],
    body = d.data['body'],
    type = d.data['type'],
    status = d.data['status'],
    createdAt = d.data['createdAt'];

  bool get isIncoming => currentUserUID == addressee;
  bool get isText => type == 'text';
  bool get isRead => status == 'read';
}
