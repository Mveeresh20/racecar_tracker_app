import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:racecar_tracker/Services/base_service.dart';
import 'package:racecar_tracker/models/sponsor.dart';

class SponsorService extends BaseService {
  // Create a new sponsor
  Future<String> createSponsor({
    required String name,
    required String email,
    required String contactPerson,
    required String contactNumber,
    required String industryType,
    required List<String> parts,
    required DateTime endDate,
    File? logo,
    String? notes,
  }) async {
    try {
      String? logoUrl;

      // Upload logo if provided
      if (logo != null) {
        logoUrl = await uploadFile(logo, sponsorsStorageRef.child('logos'));
      }

      // Create sponsor data
      final sponsorData = {
        'name': name,
        'email': email,
        'contactPerson': contactPerson,
        'contactNumber': contactNumber,
        'industryType': industryType,
        'parts': parts,
        'endDate': endDate.millisecondsSinceEpoch,
        'logoUrl': logoUrl,
        'notes': notes,
        'initials': Sponsor.generateInitials(name),
        'activeDeals': 0,
        'status': SponsorStatus.active.toString(),
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };

      return await create(sponsorsRef, sponsorData);
    } catch (e) {
      // Delete uploaded logo if sponsor creation fails
      rethrow;
    }
  }

  // Update sponsor
  Future<void> updateSponsor(
    String id, {
    String? name,
    String? email,
    String? contactPerson,
    String? contactNumber,
    String? industryType,
    List<String>? parts,
    DateTime? endDate,
    File? logo,
    String? notes,
  }) async {
    try {
      final sponsor = await getById<Sponsor>(sponsorsRef, id, _fromMap);
      if (sponsor == null) throw Exception('Sponsor not found');

      final updates = <String, dynamic>{};

      // Update basic info
      if (name != null) {
        updates['name'] = name;
        updates['initials'] = Sponsor.generateInitials(name);
      }
      if (email != null) updates['email'] = email;
      if (contactPerson != null) updates['contactPerson'] = contactPerson;
      if (contactNumber != null) updates['contactNumber'] = contactNumber;
      if (industryType != null) updates['industryType'] = industryType;
      if (parts != null) updates['parts'] = parts;
      if (endDate != null) {
        updates['endDate'] = endDate.millisecondsSinceEpoch;
        // Update status based on end date
        final daysUntilEnd = endDate.difference(DateTime.now()).inDays;
        updates['status'] =
            daysUntilEnd <= 30
                ? SponsorStatus.renewSoon.toString()
                : SponsorStatus.active.toString();
      }

      // Handle logo update
      if (logo != null) {
        if (sponsor.logoUrl != null) {
          await deleteFile(sponsor.logoUrl!);
        }
        updates['logoUrl'] = await uploadFile(
          logo,
          sponsorsStorageRef.child('logos'),
        );
      }
      if (notes != null) updates['notes'] = notes;

      updates['updatedAt'] = ServerValue.timestamp;
      await update(sponsorsRef, id, updates);
    } catch (e) {
      rethrow;
    }
  }

  // Delete sponsor
  Future<void> deleteSponsor(String id) async {
    try {
      final sponsor = await getById<Sponsor>(sponsorsRef, id, _fromMap);
      if (sponsor == null) throw Exception('Sponsor not found');

      // Delete associated logo
      if (sponsor.logoUrl != null) {
        await deleteFile(sponsor.logoUrl!);
      }

      await delete(sponsorsRef, id);
    } catch (e) {
      rethrow;
    }
  }

  // Get sponsor by ID
  Future<Sponsor?> getSponsor(String id) async {
    return await getById<Sponsor>(sponsorsRef, id, _fromMap);
  }

  // Stream all sponsors
  Stream<List<Sponsor>> streamSponsors() {
    return streamList<Sponsor>(sponsorsRef, _fromMap);
  }

  // Get active sponsors
  Stream<List<Sponsor>> streamActiveSponsors() {
    return sponsorsRef
        .orderByChild('status')
        .equalTo(SponsorStatus.active.toString())
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return <Sponsor>[];

          return data.entries.map((entry) {
            final map = Map<String, dynamic>.from(entry.value as Map);
            map['id'] = entry.key;
            return _fromMap(map);
          }).toList();
        });
  }

  // Helper method to convert Map to Sponsor object
  Sponsor _fromMap(Map<String, dynamic> map) {
    return Sponsor(
      id: map['id'] as String,
      initials: map['initials'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      contactPerson: map['contactPerson'] as String?,
      contactNumber: map['contactNumber'] as String?,
      industryType: map['industryType'] as String?,
      logoUrl: map['logoUrl'] as String?,
      notes: map['notes'] as String?,
      parts: List<String>.from(map['parts'] as List),
      activeDeals: map['activeDeals'] as int,
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int),
      status: SponsorStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => SponsorStatus.active,
      ),
    );
  }
}
