import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static final FirebaseStorageService instance = FirebaseStorageService._init();
  FirebaseStorageService._init();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadConfessionAudio(String localPath) async {
    final fileId = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('confessions/audio_$fileId.m4a');
    final uploadTask = await ref.putFile(File(localPath));
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadCommentImage(String localPath) async {
    final fileId = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('comments/image_$fileId.png');
    final uploadTask = await ref.putFile(File(localPath));
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteAudioFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (_) {}
  }

  Future<void> deleteImageFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (_) {}
  }
}
