import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // Upload a single file and return its download URL
  Future<String> uploadFile(File file, String folder) async {
    try {
      final String fileName = '${_uuid.v4()}${path.extension(file.path)}';
      final Reference ref = _storage.ref().child('$folder/$fileName');

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Upload multiple files and return their download URLs
  Future<List<String>> uploadFiles(List<File> files, String folder) async {
    try {
      final List<String> urls = await Future.wait(
        files.map((file) => uploadFile(file, folder)),
      );
      return urls;
    } catch (e) {
      throw Exception('Failed to upload files: $e');
    }
  }

  // Delete a file by its URL
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Delete multiple files by their URLs
  Future<void> deleteFiles(List<String> fileUrls) async {
    try {
      await Future.wait(fileUrls.map((url) => deleteFile(url)));
    } catch (e) {
      throw Exception('Failed to delete files: $e');
    }
  }

  // Get a reference to a specific folder
  Reference getFolderRef(String folder) {
    return _storage.ref().child(folder);
  }
}
