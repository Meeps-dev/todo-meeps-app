import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  Future<String> uploadImage(String path) async {
    final file = File(path);

    final FirebaseStorage _storage = FirebaseStorage.instance;

    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = _storage.ref().child("profile_images/$fileName");

    try {
      final uploadTask = await ref.putFile(file);

      print("UPLOAD STATE => ${uploadTask.state}");
      print("BYTES TRANSFERRED => ${uploadTask.bytesTransferred}");
      print("TOTAL BYTES => ${uploadTask.totalBytes}");

      return await ref.getDownloadURL();
    } catch (e) {
      print("UPLOAD ERROR => $e");
      rethrow;
    }
  }
}
