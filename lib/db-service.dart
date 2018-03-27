import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  static final DbService _instance = new DbService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  final CollectionReference _msgReference = Firestore.instance.collection('messages');

  DbService._internal();

  factory DbService() {
    return _instance;
  }

  Future<FirebaseUser> getUserForUID(String uid) async {
    var token = await _getToken(uid);
    return await _auth.signInWithCustomToken(token: token);
  }

  void sendMessage(String senderUID, String addresseeUID, String body) {
    _msgReference.document().setData({
      'sender': senderUID,
      'addressee': addresseeUID,
      'body': body,
      'createdAt': new DateTime.now()
    });
  }

  Future<QuerySnapshot> loadMessages(String senderUID, String addresseeUID) {
    return _msgReference
      .where('sender', isEqualTo: senderUID)
      .where('addressee', isEqualTo: addresseeUID)
      .orderBy('createdAt').getDocuments();
  }

  Stream<QuerySnapshot> getRosterListener(String addresseeUID) {
    return _msgReference.where('addressee', isEqualTo: addresseeUID).snapshots;
  }

  Stream<QuerySnapshot> getChatListener(String senderUID, String addresseeUID) {
    return _msgReference.where('sender', isEqualTo: senderUID)
      .where('addressee', isEqualTo: addresseeUID).snapshots;
  }

  Future<String> _getToken(String uid) async {
    print("Got UID: '$uid'");
    var client = new HttpClient();
    Uri uri = Uri.parse("https://us-central1-massajor-9e764.cloudfunctions.net/getToken?uid=$uid");
    var req = await client.getUrl(uri);
    var resp = await req.close();
    return await resp.transform(UTF8.decoder).join();
  }
}