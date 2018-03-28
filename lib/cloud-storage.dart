import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorage {
  static final CloudStorage _instance = new CloudStorage._internal();
  final StorageReference _ref = FirebaseStorage.instance.ref();
  CloudStorage._internal();

  factory CloudStorage() {
    return _instance;
  }

  Future<Uri> uploadFile(String uid, File file) async {
    final int ts = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final String destName = "$uid/${ts}_${file.path.split('/').last}";
    final StorageUploadTask uploadTask = _ref.child(destName).put(file);
    return (await uploadTask.future).downloadUrl;
  }
}
