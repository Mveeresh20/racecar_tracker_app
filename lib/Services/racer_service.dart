import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:racecar_tracker/Services/base_service.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/sponsor.dart';

class RacerService extends BaseService {
  // Create a new racer
  Future<String> createRacer({
    required String name,
    required String teamName,
    required String vehicleModel,
    required String contactNumber,
    required String vehicleNumber,
    required String currentEvent,
    File? racerImage,
    File? vehicleImage,
  }) async {
    try {
      String? racerImageUrl;
      String? vehicleImageUrl;

      // Upload images if provided
      if (racerImage != null) {
        racerImageUrl = await uploadFile(
          racerImage,
          racersStorageRef.child('profile'),
        );
      }
      if (vehicleImage != null) {
        vehicleImageUrl = await uploadFile(
          vehicleImage,
          racersStorageRef.child('vehicle'),
        );
      }

      // Create racer data
      final racerData = {
        'name': name,
        'teamName': teamName,
        'vehicleModel': vehicleModel,
        'contactNumber': contactNumber,
        'vehicleNumber': vehicleNumber,
        'currentEvent': currentEvent,
        'racerImageUrl': racerImageUrl,
        'vehicleImageUrl': vehicleImageUrl,
        'initials': Sponsor.generateInitials(name),
        'activeRaces': 0,
        'totalRaces': 0,
        'earnings': '0',
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };

      return await create(racersRef, racerData);
    } catch (e) {
      // Delete uploaded images if racer creation fails
      rethrow;
    }
  }

  // Update racer
  Future<void> updateRacer(
    String id, {
    String? name,
    String? teamName,
    String? vehicleModel,
    String? contactNumber,
    String? vehicleNumber,
    String? currentEvent,
    File? racerImage,
    File? vehicleImage,
  }) async {
    try {
      final racer = await getById<Racer>(racersRef, id, _fromMap);
      if (racer == null) throw Exception('Racer not found');

      final updates = <String, dynamic>{};

      // Update basic info
      if (name != null) {
        updates['name'] = name;
        updates['initials'] = Sponsor.generateInitials(name);
      }
      if (teamName != null) updates['teamName'] = teamName;
      if (vehicleModel != null) updates['vehicleModel'] = vehicleModel;
      if (contactNumber != null) updates['contactNumber'] = contactNumber;
      if (vehicleNumber != null) updates['vehicleNumber'] = vehicleNumber;
      if (currentEvent != null) updates['currentEvent'] = currentEvent;

      // Handle image updates
      if (racerImage != null) {
        if (racer.racerImageUrl != null) {
          await deleteFile(racer.racerImageUrl!);
        }
        updates['racerImageUrl'] = await uploadFile(
          racerImage,
          racersStorageRef.child('profile'),
        );
      }
      if (vehicleImage != null) {
        if (racer.vehicleImageUrl != null) {
          await deleteFile(racer.vehicleImageUrl);
        }
        updates['vehicleImageUrl'] = await uploadFile(
          vehicleImage,
          racersStorageRef.child('vehicle'),
        );
      }

      updates['updatedAt'] = ServerValue.timestamp;
      await update(racersRef, id, updates);
    } catch (e) {
      rethrow;
    }
  }

  // Delete racer
  Future<void> deleteRacer(String id) async {
    try {
      final racer = await getById<Racer>(racersRef, id, _fromMap);
      if (racer == null) throw Exception('Racer not found');

      // Delete associated images
      if (racer.racerImageUrl != null) {
        await deleteFile(racer.racerImageUrl!);
      }
      if (racer.vehicleImageUrl != null) {
        await deleteFile(racer.vehicleImageUrl);
      }

      await delete(racersRef, id);
    } catch (e) {
      rethrow;
    }
  }

  // Get racer by ID
  Future<Racer?> getRacer(String id) async {
    return await getById<Racer>(racersRef, id, _fromMap);
  }

  // Stream all racers
  Stream<List<Racer>> streamRacers() {
    return streamList<Racer>(racersRef, _fromMap);
  }

  // Helper method to convert Map to Racer object
  Racer _fromMap(Map<String, dynamic> map) {
    return Racer(
      id: map['id'] as String,
      initials: map['initials'] as String,
      name: map['name'] as String,
      teamName: map['teamName'] as String,
      vehicleModel: map['vehicleModel'] as String,
      contactNumber: map['contactNumber'] as String,
      vehicleNumber: map['vehicleNumber'] as String,
      currentEvent: map['currentEvent'] as String,
      activeRaces: map['activeRaces'] as int,
      totalRaces: map['totalRaces'] as int,
      earnings: map['earnings'] as String,
      racerImageUrl: map['racerImageUrl'] as String?,
      vehicleImageUrl: map['vehicleImageUrl'] as String,
      isLocalImage: false,
    );
  }
}
