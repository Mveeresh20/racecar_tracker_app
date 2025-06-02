import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:racecar_tracker/Services/base_service.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:racecar_tracker/Services/app_constant.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class RacerService extends BaseService {
  final _uuid = const Uuid();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final ImagePickerUtil _imagePicker = ImagePickerUtil();

  // Get reference to user's racers
  DatabaseReference getUserRacersRef(String userId) {
    return _database.child('478_users').child(userId).child('racers');
  }

  // Create a new racer
  Future<String> createRacer({
    required String userId,
    required String name,
    required String teamName,
    required String vehicleModel,
    required String contactNumber,
    required String vehicleNumber,
    required String currentEvent,
    String? racerImageUrl,
    String? vehicleImageUrl,
    required BuildContext context,
  }) async {
    try {
      // Generate initials from racer name
      final initials = name
          .split(' ')
          .where((word) => word.isNotEmpty)
          .map((word) => word[0].toUpperCase())
          .join('');

      final racerId = _uuid.v4();
      final racer = Racer(
        id: racerId,
        userId: userId,
        name: name,
        teamName: teamName,
        vehicleModel: vehicleModel,
        contactNumber: contactNumber,
        vehicleNumber: vehicleNumber,
        currentEvent: currentEvent,
        racerImageUrl: racerImageUrl,
        vehicleImageUrl: vehicleImageUrl,
        initials: initials,
        activeRaces: 0,
        totalRaces: 0,
        earnings: '0',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      await getUserRacersRef(userId).child(racerId).set(racer.toMap());
      return racerId;
    } catch (e) {
      print('Error creating racer: $e');
      rethrow;
    }
  }

  // Get real-time stream of racers
  Stream<List<Racer>> getRacersStream(String userId) {
    return getUserRacersRef(userId).onValue.map((event) {
      if (event.snapshot.value == null) {
        print('No data found for user $userId');
        return [];
      }

      final data = event.snapshot.value;
      print('Raw data from Firebase: $data'); // Debug log

      if (data == null) {
        print('Data is null');
        return [];
      }

      try {
        // Handle both Map and List cases
        if (data is Map) {
          final racers =
              data.entries
                  .map((entry) {
                    try {
                      if (entry.value is String) {
                        print(
                          'Warning: Racer data is a string instead of a map: ${entry.value}',
                        );
                        return null;
                      }

                      final racerData = Map<String, dynamic>.from(
                        entry.value as Map,
                      );
                      racerData['id'] =
                          entry.key; // Add the key as the racer ID
                      return Racer.fromMap(racerData);
                    } catch (e) {
                      print('Error converting racer data: $e');
                      print('Problematic data: ${entry.value}');
                      return null;
                    }
                  })
                  .where((racer) => racer != null)
                  .cast<Racer>()
                  .toList();

          print('Successfully converted ${racers.length} racers');
          return racers;
        } else if (data is List) {
          final racers =
              data
                  .asMap()
                  .entries
                  .map((entry) {
                    try {
                      if (entry.value is String) {
                        print(
                          'Warning: Racer data is a string instead of a map: ${entry.value}',
                        );
                        return null;
                      }

                      final racerData = Map<String, dynamic>.from(
                        entry.value as Map,
                      );
                      racerData['id'] =
                          entry.key.toString(); // Use index as ID if no key
                      return Racer.fromMap(racerData);
                    } catch (e) {
                      print('Error converting racer data: $e');
                      print('Problematic data: ${entry.value}');
                      return null;
                    }
                  })
                  .where((racer) => racer != null)
                  .cast<Racer>()
                  .toList();

          print('Successfully converted ${racers.length} racers');
          return racers;
        }

        print('Data is neither a Map nor a List: ${data.runtimeType}');
        return [];
      } catch (e) {
        print('Error processing racer data: $e');
        return [];
      }
    });
  }

  // Update an existing racer
  Future<void> updateRacer(String userId, Racer racer) async {
    try {
      final racerRef = getUserRacersRef(userId).child(racer.id);
      await racerRef.update(racer.toMap());
    } catch (e) {
      throw Exception('Failed to update racer: $e');
    }
  }

  // Delete a racer
  Future<void> deleteRacer(String userId, String racerId) async {
    try {
      final racerRef = getUserRacersRef(userId).child(racerId);
      await racerRef.remove();
    } catch (e) {
      throw Exception('Failed to delete racer: $e');
    }
  }

  // Get a single racer
  Future<Racer?> getRacer(String userId, String racerId) async {
    try {
      final snapshot = await getUserRacersRef(userId).child(racerId).get();
      if (!snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data['id'] = snapshot.key; // Add the key as the racer ID
      return Racer.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get racer: $e');
    }
  }

  // Update racer image
  Future<void> updateRacerImage(
    String userId,
    String racerId,
    File imageFile,
    bool isProfileImage,
    BuildContext context,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageType = isProfileImage ? 'profile' : 'vehicle';
      // Production path structure: images/[type]_[timestamp].[extension]
      final imagePath =
          'images/${imageType}_$timestamp${path.extension(imageFile.path)}';

      String? signedUrl = await _imagePicker.getSignedUrl(
        imagePath,
        AppConstant.bundleNameForPostAPI,
      );

      if (signedUrl != null) {
        String? imageUrl;
        await _imagePicker.uploadFileToS3WithCallback(
          signedUrl,
          imageFile.path,
          context,
          (url) => imageUrl = url, // This will be just the filename
          (error) => throw Exception('Failed to upload image: $error'),
        );

        if (imageUrl != null) {
          final racerRef = getUserRacersRef(userId).child(racerId);
          final updateData =
              isProfileImage
                  ? {'racerImageUrl': imageUrl}
                  : {'vehicleImageUrl': imageUrl};
          await racerRef.update(updateData);
        }
      }
    } catch (e) {
      throw Exception('Failed to update racer image: $e');
    }
  }

  // Delete racer image
  Future<void> deleteRacerImage(
    String userId,
    String racerId,
    bool isProfileImage,
  ) async {
    try {
      final racerRef = getUserRacersRef(userId).child(racerId);
      final updateData =
          isProfileImage ? {'racerImageUrl': null} : {'vehicleImageUrl': null};
      await racerRef.update(updateData);
    } catch (e) {
      throw Exception('Failed to delete racer image: $e');
    }
  }
}
