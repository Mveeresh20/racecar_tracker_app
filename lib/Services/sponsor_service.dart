import 'dart:io';
import 'dart:convert';
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
        // Generate a new UUID if ID is empty
        final newId = _uuid.v4();
        // Create a new sponsor with the generated ID
        final updatedSponsor = sponsor.copyWith(id: newId);
        final sponsorMap = updatedSponsor.toMap();

        // Save to Firebase with the new ID
        final sponsorRef = getUserSponsorsRef(userId).child(newId);
        await sponsorRef.set(sponsorMap);

        print('Successfully saved sponsor with generated ID: $newId');
        return;
      }

      // If ID is not empty, proceed with normal save
      final sponsorMap = sponsor.toMap();
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
    return getUserSponsorsRef(userId).onValue.asyncMap((event) async {
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

            // Generate new ID if empty or null
            if (sponsorData['id'] == null ||
                sponsorData['id'].toString().isEmpty) {
              print('Generating new ID for sponsor with empty ID');
              final newId = _uuid.v4();
              sponsorData['id'] = newId;

              // Update the sponsor in Firebase with the new ID synchronously
              await getUserSponsorsRef(userId).child(newId).set(sponsorData);

              // Delete the old entry if it exists
              if (data.containsKey('id') && data['id'].toString().isNotEmpty) {
                await getUserSponsorsRef(
                  userId,
                ).child(data['id'].toString()).remove();
              }

              print('Successfully updated sponsor with new ID: $newId');
            }

            // Ensure required fields are present
            sponsorData['userId'] = userId;
            sponsorData['initials'] =
                sponsorData['initials'] ??
                Sponsor.generateInitials(sponsorData['name'] ?? '');

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
              print(
                'Successfully converted single sponsor: ${sponsor.name} with ID: ${sponsor.id}',
              );
              return [sponsor];
            } catch (e) {
              print('Error converting single sponsor: $e');
              print('Sponsor data: $sponsorData');
              return [];
            }
          }

          // Handle map of maps case (multiple sponsors)
          if (data.isNotEmpty) {
            final List<Sponsor> sponsors = [];

            for (final entry in data.entries) {
              try {
                Map<String, dynamic> sponsorData;

                if (entry.value is Map) {
                  sponsorData = Map<String, dynamic>.from(entry.value as Map);
                } else if (entry.value is String) {
                  try {
                    final jsonMap =
                        jsonDecode(entry.value as String)
                            as Map<String, dynamic>;
                    sponsorData = Map<String, dynamic>.from(jsonMap);
                  } catch (parseError) {
                    print('Error parsing sponsor string: $parseError');
                    print('String value: ${entry.value}');
                    continue;
                  }
                } else {
                  print(
                    'Warning: Sponsor data is not a map or string: ${entry.value}',
                  );
                  continue;
                }

                // Generate new ID if empty or null
                if (entry.key.toString().isEmpty ||
                    sponsorData['id'] == null ||
                    sponsorData['id'].toString().isEmpty) {
                  print('Generating new ID for sponsor with empty ID/key');
                  final newId = _uuid.v4();
                  sponsorData['id'] = newId;

                  // Update the sponsor in Firebase with the new ID synchronously
                  await getUserSponsorsRef(
                    userId,
                  ).child(newId).set(sponsorData);

                  // Delete the old entry if it exists
                  if (entry.key.toString().isNotEmpty) {
                    await getUserSponsorsRef(userId).child(entry.key).remove();
                  }

                  print('Successfully updated sponsor with new ID: $newId');
                } else {
                  sponsorData['id'] = entry.key;
                }

                sponsorData['userId'] = userId;

                // Generate initials if not present
                if (!sponsorData.containsKey('initials') ||
                    sponsorData['initials'].toString().isEmpty) {
                  sponsorData['initials'] = Sponsor.generateInitials(
                    sponsorData['name'] ?? '',
                  );
                }

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

                final sponsor = Sponsor.fromMap(sponsorData);
                sponsors.add(sponsor);
              } catch (e) {
                print('Error converting sponsor data: $e');
                print('Problematic data: ${entry.value}');
                continue;
              }
            }

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
