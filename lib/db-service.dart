import 'dart:async' show Future, Stream;
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Massajor/chat-item.dart';

const String getTokenURL = 'https://us-central1-massajor-9e764.cloudfunctions.net/getToken';

class DbService {
  static final DbService _instance = new DbService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _msgReference = Firestore.instance.collection('messages');
  final CollectionReference _evtReference = Firestore.instance.collection('events');
  final CollectionReference _fcmReference = Firestore.instance.collection('fcmRegistrations');
  FirebaseUser user;

  DbService._internal();

  factory DbService() {
    return _instance;
  }

  Future<FirebaseUser> getUserForUID(String uid) async {
    var token = await _getToken(uid);
    return await _auth.signInWithCustomToken(token: token);
  }

  void sendMessage(ChatItem item) {
    _msgReference.document().setData({
      'sender': item.sender,
      'addressee': item.addressee,
      'body': item.body,
      'type': item.type,
      'createdAt': item.createdAt,
      'status': item.status
    });
  }

  void setMessageRead(String docID) {
    print('Setting msg_id: ${docID} to read');
    _msgReference.document(docID).updateData({
      'status': 'read'
    });
  }

  Future<QuerySnapshot> loadMessages(String senderUID, String addresseeUID) {
    return _msgReference
      .where('sender', isEqualTo: senderUID)
      .where('addressee', isEqualTo: addresseeUID)
      .orderBy('createdAt').getDocuments();
  }

  Stream<QuerySnapshot> getRosterListener(String addresseeUID) {
    return _msgReference.where('addressee', isEqualTo: addresseeUID)
      .orderBy('createdAt', descending: true).snapshots;
  }

  Stream<QuerySnapshot> getChatListener(String senderUID, String addresseeUID) {
    return _msgReference.where('sender', isEqualTo: senderUID)
      .where('addressee', isEqualTo: addresseeUID)
      .orderBy('createdAt', descending: true).snapshots;
  }

  Stream<QuerySnapshot> getChatEventsListener(String senderUID, String addresseeUID) {
    return _evtReference.where('sender', isEqualTo: senderUID)
      .where('addressee', isEqualTo: addresseeUID).snapshots;
  }

  void sendEvent(String senderUID, String addresseeUID, String type) {
    _evtReference.document().setData({
      'sender': senderUID,
      'addressee': addresseeUID,
      'type': type,
      'createdAt': new DateTime.now()
    });
  }

  void deleteEvent(String senderUID, String addresseeUID, String type) async {
    QuerySnapshot s = await _evtReference.where('sender', isEqualTo: senderUID)
      .where('addressee', isEqualTo: addresseeUID)
      .where('type', isEqualTo: type).getDocuments();
    s.documents.forEach((DocumentSnapshot d) {
      d.reference.delete();
    });
  }

  void setFCMRegistration(String senderUID, String token) async {
    var qs = await _fcmReference.where('sender', isEqualTo: senderUID).limit(1).getDocuments();
    if (qs.documents.length != 0) {
      qs.documents.first.reference.updateData({
        'token': token,
        'updatedAt': new DateTime.now().toUtc()
      });
    } else {
      _fcmReference.document().setData({
        'sender': senderUID,
        'token': token,
        'updatedAt': new DateTime.now().toUtc()
      });
    }
  }

  Future<String> _getToken(String uid) async {
    print("Got UID: '$uid'");
    var client = new HttpClient();
    Uri uri = Uri.parse("$getTokenURL?uid=$uid");
    var req = await client.getUrl(uri);
    var resp = await req.close();
    return await resp.transform(utf8.decoder).join();
  }
}
