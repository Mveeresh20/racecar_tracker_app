import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:racecar_tracker/Services/base_service.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:uuid/uuid.dart';

class SponsorService extends BaseService {
  final _uuid = const Uuid();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get reference to user's sponsors
  DatabaseReference getUserSponsorsRef(String userId) {
    return _database.child('478_users').child(userId).child('sponsors');
  }

  // Create a new sponsor
  Future<void> createSponsor(String userId, Sponsor sponsor) async {
    try {
      // Validate the sponsor data
      if (sponsor.id.isEmpty) {
        throw Exception('Sponsor ID cannot be empty');
      }

      // Convert sponsor to map and validate the data
      final sponsorMap = sponsor.toMap();

      // Ensure all required fields are present and of correct type
      if (sponsorMap['name'] == null || sponsorMap['name'].toString().isEmpty) {
        throw Exception('Sponsor name is required');
      }
      if (sponsorMap['email'] == null ||
          sponsorMap['email'].toString().isEmpty) {
        throw Exception('Sponsor email is required');
      }
      if (sponsorMap['userId'] == null ||
          sponsorMap['userId'].toString().isEmpty) {
        throw Exception('User ID is required');
      }

      // Ensure parts is a list
      if (sponsorMap['parts'] is! List) {
        sponsorMap['parts'] = [];
      }

      // Ensure dates are stored as timestamps
      if (sponsorMap['endDate'] is! int) {
        sponsorMap['endDate'] =
            DateTime.now()
                .add(const Duration(days: 365))
                .millisecondsSinceEpoch;
      }
      if (sponsorMap['createdAt'] is! int) {
        sponsorMap['createdAt'] = DateTime.now().millisecondsSinceEpoch;
      }
      if (sponsorMap['updatedAt'] is! int) {
        sponsorMap['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
      }

      // Ensure numeric fields are numbers
      if (sponsorMap['activeDeals'] is! int) {
        sponsorMap['activeDeals'] = 0;
      }
      if (sponsorMap['totalDeals'] is! int) {
        sponsorMap['totalDeals'] = 0;
      }

      // Save to Firebase
      final sponsorRef = getUserSponsorsRef(userId).child(sponsor.id);
      await sponsorRef.set(sponsorMap);

      print('Successfully saved sponsor: ${sponsor.name}');
    } catch (e) {
      print('Error creating sponsor: $e');
      throw Exception('Failed to create sponsor: $e');
    }
  }

  // Get real-time stream of sponsors
  Stream<List<Sponsor>> getSponsorsStream(String userId) {
    return getUserSponsorsRef(userId).onValue.map((event) {
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
        // Handle single sponsor case (when data is a map with fields at root level)
        if (data is Map) {
          // Check if this is a single sponsor entry (has required fields)
          if (data.containsKey('name') && data.containsKey('email')) {
            // This is a single sponsor entry
            final sponsorData = Map<String, dynamic>.from(data);

            // Ensure required fields are present
            sponsorData['id'] = sponsorData['id']?.toString() ?? _uuid.v4();
            sponsorData['userId'] = userId;

            // Handle parts list
            if (sponsorData['parts'] is List) {
              sponsorData['parts'] = List<String>.from(sponsorData['parts']);
            } else if (sponsorData['parts'] is String) {
              sponsorData['parts'] = [sponsorData['parts']];
            } else {
              sponsorData['parts'] = [];
            }

            // Handle numeric fields
            sponsorData['activeDeals'] =
                (sponsorData['activeDeals'] is num)
                    ? (sponsorData['activeDeals'] as num).toInt()
                    : 0;
            sponsorData['totalDeals'] =
                (sponsorData['totalDeals'] is num)
                    ? (sponsorData['totalDeals'] as num).toInt()
                    : 0;

            // Handle dates
            sponsorData['createdAt'] =
                (sponsorData['createdAt'] is num)
                    ? (sponsorData['createdAt'] as num).toInt()
                    : DateTime.now().millisecondsSinceEpoch;
            sponsorData['updatedAt'] =
                (sponsorData['updatedAt'] is num)
                    ? (sponsorData['updatedAt'] as num).toInt()
                    : DateTime.now().millisecondsSinceEpoch;
            sponsorData['endDate'] =
                (sponsorData['endDate'] is num)
                    ? (sponsorData['endDate'] as num).toInt()
                    : DateTime.now()
                        .add(const Duration(days: 365))
                        .millisecondsSinceEpoch;

            // Handle status
            if (!sponsorData.containsKey('status')) {
              sponsorData['status'] = 'SponsorStatus.active';
            }

            // Handle commission
            if (!sponsorData.containsKey('commission')) {
              sponsorData['commission'] = '0%';
            }

            try {
              final sponsor = Sponsor.fromMap(sponsorData);
              print('Successfully converted single sponsor: ${sponsor.name}');
              return [sponsor];
            } catch (e) {
              print('Error converting single sponsor: $e');
              print('Sponsor data: $sponsorData');
              return [];
            }
          }

          // Handle map of maps case (multiple sponsors)
          if (data.isNotEmpty) {
            final sponsors =
                data.entries
                    .map((entry) {
                      try {
                        if (entry.value is! Map) {
                          print(
                            'Warning: Sponsor data is not a map: ${entry.value}',
                          );
                          return null;
                        }

                        final sponsorData = Map<String, dynamic>.from(
                          entry.value as Map,
                        );
                        sponsorData['id'] = entry.key;
                        sponsorData['userId'] = userId;

                        // Handle parts list
                        if (sponsorData['parts'] is List) {
                          sponsorData['parts'] = List<String>.from(
                            sponsorData['parts'],
                          );
                        } else if (sponsorData['parts'] is String) {
                          sponsorData['parts'] = [sponsorData['parts']];
                        } else {
                          sponsorData['parts'] = [];
                        }

                        // Handle numeric fields
                        sponsorData['activeDeals'] =
                            (sponsorData['activeDeals'] is num)
                                ? (sponsorData['activeDeals'] as num).toInt()
                                : 0;
                        sponsorData['totalDeals'] =
                            (sponsorData['totalDeals'] is num)
                                ? (sponsorData['totalDeals'] as num).toInt()
                                : 0;

                        // Handle dates
                        sponsorData['createdAt'] =
                            (sponsorData['createdAt'] is num)
                                ? (sponsorData['createdAt'] as num).toInt()
                                : DateTime.now().millisecondsSinceEpoch;
                        sponsorData['updatedAt'] =
                            (sponsorData['updatedAt'] is num)
                                ? (sponsorData['updatedAt'] as num).toInt()
                                : DateTime.now().millisecondsSinceEpoch;
                        sponsorData['endDate'] =
                            (sponsorData['endDate'] is num)
                                ? (sponsorData['endDate'] as num).toInt()
                                : DateTime.now()
                                    .add(const Duration(days: 365))
                                    .millisecondsSinceEpoch;

                        // Handle status
                        if (!sponsorData.containsKey('status')) {
                          sponsorData['status'] = 'SponsorStatus.active';
                        }

                        // Handle commission
                        if (!sponsorData.containsKey('commission')) {
                          sponsorData['commission'] = '0%';
                        }

                        return Sponsor.fromMap(sponsorData);
                      } catch (e) {
                        print('Error converting sponsor data: $e');
                        print('Problematic data: ${entry.value}');
                        return null;
                      }
                    })
                    .where((sponsor) => sponsor != null)
                    .cast<Sponsor>()
                    .toList();

            print('Successfully converted ${sponsors.length} sponsors');
            return sponsors;
          }
        }

        print('Data is not in expected format: ${data.runtimeType}');
        return [];
      } catch (e) {
        print('Error processing sponsor data: $e');
        return [];
      }
    });
  }

  // Update an existing sponsor
  Future<void> updateSponsor(String userId, Sponsor sponsor) async {
    try {
      final sponsorRef = getUserSponsorsRef(userId).child(sponsor.id);
      await sponsorRef.update(sponsor.toMap());
    } catch (e) {
      throw Exception('Failed to update sponsor: $e');
    }
  }

  // Delete a sponsor
  Future<void> deleteSponsor(String userId, String sponsorId) async {
    try {
      final sponsorRef = getUserSponsorsRef(userId).child(sponsorId);
      await sponsorRef.remove();
    } catch (e) {
      throw Exception('Failed to delete sponsor: $e');
    }
  }

  // Get a single sponsor
  Future<Sponsor?> getSponsor(String userId, String sponsorId) async {
    try {
      final snapshot = await getUserSponsorsRef(userId).child(sponsorId).get();
      if (!snapshot.exists) return null;

      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      final rawData = snapshot.value as Map;
      final data = Map<String, dynamic>.from(rawData);
      data['id'] = snapshot.key; // Add the key as the sponsor ID
      return Sponsor.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get sponsor: $e');
    }
  }

  // Upload sponsor logo
  Future<String?> uploadSponsorLogo(
    File logo,
    String userId,
    String sponsorId,
  ) async {
    try {
      final storageRef = sponsorsStorageRef.child('$userId/$sponsorId/logo');
      return await uploadFile(logo, storageRef);
    } catch (e) {
      throw Exception('Failed to upload sponsor logo: $e');
    }
  }

  // Delete sponsor logo
  Future<void> deleteSponsorLogo(String logoUrl) async {
    try {
      await deleteFile(logoUrl);
    } catch (e) {
      throw Exception('Failed to delete sponsor logo: $e');
    }
  }
}
