import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class BaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = Uuid();

  // Database references
  DatabaseReference get racersRef => _database.ref().child('racers');
  DatabaseReference get sponsorsRef => _database.ref().child('sponsors');
  DatabaseReference get dealsRef => _database.ref().child('deals');
  DatabaseReference get eventsRef => _database.ref().child('events');
  DatabaseReference get commissionSummaryRef =>
      _database.ref().child('commission-summary');

  // Storage references
  Reference get racersStorageRef => _storage.ref().child('racers');
  Reference get sponsorsStorageRef => _storage.ref().child('sponsors');
  Reference get dealsStorageRef => _storage.ref().child('deals');

  // Generate unique ID
  String generateId() => _uuid.v4();

  // Upload file to Firebase Storage
  Future<String> uploadFile(File file, Reference storageRef) async {
    try {
      final fileName = '${generateId()}${path.extension(file.path)}';
      final fileRef = storageRef.child(fileName);
      final uploadTask = await fileRef.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Delete file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Generic CRUD operations
  Future<String> create<T>(DatabaseReference ref, T data) async {
    try {
      final newRef = ref.push();
      await newRef.set(data);
      return newRef.key!;
    } catch (e) {
      throw Exception('Failed to create record: $e');
    }
  }

  Future<void> update<T>(
      DatabaseReference ref, String id, Map<String, dynamic> data) async {
    try {
      await ref.child(id).update(data);
    } catch (e) {
      throw Exception('Failed to update record: $e');
    }
  }

  Future<void> delete(DatabaseReference ref, String id) async {
    try {
      await ref.child(id).remove();
    } catch (e) {
      throw Exception('Failed to delete record: $e');
    }
  }

  Future<T?> getById<T>(
    DatabaseReference ref,
    String id,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    try {
      final snapshot = await ref.child(id).get();
      if (snapshot.exists) {
        return fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get record: $e');
    }
  }

  Stream<List<T>> streamList<T>(
    DatabaseReference ref,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <T>[];

      return data.entries.map((entry) {
        final map = Map<String, dynamic>.from(entry.value as Map);
        map['id'] = entry.key;
        return fromMap(map);
      }).toList();
    });
  }
}
