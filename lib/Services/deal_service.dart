import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:racecar_tracker/Services/base_service.dart';
import 'package:racecar_tracker/models/deal_detail_item.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';
import 'package:racecar_tracker/Services/app_constant.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/sponsor.dart';
import '../models/racer.dart';
import '../models/event.dart';
import '../Utils/Constants/app_constants.dart';

class DealService extends BaseService {
  final ImagePickerUtil _imagePicker = ImagePickerUtil();
  final _uuid = const Uuid();

  // Get reference to user's deals
  DatabaseReference getUserDealsRef(String userId) {
    return database.ref().child('478_users').child(userId).child('deals');
  }

  // Create a new deal
  Future<String> createDeal({
    required String userId,
    required String sponsorId,
    required String racerId,
    required String eventId,
    required String sponsorInitials,
    required String racerInitials,
    required String title,
    required String raceType,
    required double dealValue,
    required double commissionPercentage,
    required List<String> advertisingPositions,
    required DateTime startDate,
    required DateTime endDate,
    required String renewalReminder,
    required DealStatusType status,
    List<File>? brandingImages,
    required BuildContext context,
  }) async {
    try {
      // Validate input data
      if (userId.isEmpty) throw Exception('User ID is required');
      if (sponsorId.isEmpty) throw Exception('Sponsor ID is required');
      if (racerId.isEmpty) throw Exception('Racer ID is required');
      if (eventId.isEmpty) throw Exception('Event ID is required');
      if (title.isEmpty) throw Exception('Title is required');
      if (raceType.isEmpty) throw Exception('Race type is required');
      if (dealValue <= 0) throw Exception('Deal value must be greater than 0');
      if (commissionPercentage < 0 || commissionPercentage > 100) {
        throw Exception('Commission percentage must be between 0 and 100');
      }
      if (advertisingPositions.isEmpty) {
        throw Exception('At least one advertising position is required');
      }

      List<String>? brandingImageUrls;

      // Upload branding images if provided
      if (brandingImages != null && brandingImages.isNotEmpty) {
        brandingImageUrls = await Future.wait(
          brandingImages.map((file) async {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final uniqueId = _uuid.v4();
            final imagePath =
                'branding_${timestamp}_$uniqueId${path.extension(file.path)}';

            String? signedUrl = await _imagePicker.getSignedUrl(
              imagePath,
              AppConstant.bundleNameForPostAPI,
            );

            if (signedUrl == null) {
              throw Exception('Failed to get signed URL for image upload');
            }

            Completer<String> completer = Completer<String>();
            await _imagePicker.uploadFileToS3WithCallback(
              signedUrl,
              file.path,
              context,
              (url) => completer.complete(url),
              (error) => completer.completeError(error),
            );

            return await completer.future;
          }),
        );
      }

      // Calculate commission amount
      final commissionAmount = dealValue * (commissionPercentage / 100);

      // Create deal data with explicit types
      final Map<String, dynamic> dealData = {
        'userId': userId,
        'sponsorId': sponsorId,
        'racerId': racerId,
        'eventId': eventId,
        'sponsorInitials': sponsorInitials,
        'racerInitials': racerInitials,
        'title': title,
        'raceType': raceType,
        'dealValue': dealValue,
        'commissionPercentage': commissionPercentage,
        'commissionAmount': commissionAmount,
        'advertisingPositions': advertisingPositions,
        'brandingImageUrls': brandingImageUrls ?? [],
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
        'renewalReminder': renewalReminder,
        'status': status.toString(),
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };

      // Validate the data before saving
      if (!_isValidDealData(dealData)) {
        throw Exception('Invalid deal data format');
      }

      // Create the deal in Firestore
      final dealRef = getUserDealsRef(userId).push();
      await dealRef.set(dealData);
      final dealId = dealRef.key;
      if (dealId == null) {
        throw Exception('Failed to create deal');
      }

      // Update sponsor's active deals count
      await _updateSponsorDealCount(sponsorId, 1);

      return dealId;
    } catch (e) {
      print('Error creating deal: $e');
      rethrow;
    }
  }

  // Helper method to validate deal data
  bool _isValidDealData(Map<String, dynamic> data) {
    try {
      // Check required fields - be more lenient
      if (data['userId'] == null ||
          data['sponsorId'] == null ||
          data['racerId'] == null ||
          data['eventId'] == null ||
          data['title'] == null ||
          data['raceType'] == null) {
        return false;
      }

      // Validate numeric fields - be more lenient
      if (data['dealValue'] == null || data['commissionPercentage'] == null) {
        return false;
      }

      // Validate string fields - be more lenient
      if (data['userId'] == null ||
          data['sponsorId'] == null ||
          data['racerId'] == null ||
          data['eventId'] == null ||
          data['title'] == null ||
          data['raceType'] == null) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating deal data: $e');
      return false;
    }
  }

  // Update deal
  Future<void> updateDeal(
    String id, {
    required String userId,
    String? sponsorId,
    String? racerId,
    String? eventId,
    String? sponsorInitials,
    String? racerInitials,
    String? title,
    String? raceType,
    double? dealValue,
    double? commissionPercentage,
    List<String>? advertisingPositions,
    DateTime? startDate,
    DateTime? endDate,
    String? renewalReminder,
    DealStatusType? status,
    List<File>? brandingImages,
    required BuildContext context,
  }) async {
    try {
      final userDealsRef = getUserDealsRef(userId);

      // Get the existing deal to check if it exists
      final snapshot = await userDealsRef.child(id).get();
      if (!snapshot.exists) {
        throw Exception('Deal not found');
      }

      final existingData = snapshot.value;
      if (existingData == null) {
        throw Exception('Deal data is null');
      }

      // Convert to proper Map type
      final existingDealMap = Map<String, dynamic>.from(existingData as Map);
      final existingDeal = DealDetailItem.fromMap(existingDealMap);

      final updates = <String, dynamic>{};

      // Update basic info
      if (sponsorId != null) updates['sponsorId'] = sponsorId;
      if (racerId != null) updates['racerId'] = racerId;
      if (eventId != null) updates['eventId'] = eventId;
      if (sponsorInitials != null) updates['sponsorInitials'] = sponsorInitials;
      if (racerInitials != null) updates['racerInitials'] = racerInitials;
      if (title != null) updates['title'] = title;
      if (raceType != null) updates['raceType'] = raceType;
      if (dealValue != null) {
        updates['dealValue'] = dealValue;
        if (commissionPercentage != null) {
          updates['commissionAmount'] =
              dealValue * (commissionPercentage / 100);
        } else {
          updates['commissionAmount'] =
              dealValue * (existingDeal.commissionPercentage / 100);
        }
      }
      if (commissionPercentage != null) {
        updates['commissionPercentage'] = commissionPercentage;
        if (dealValue != null) {
          updates['commissionAmount'] =
              dealValue * (commissionPercentage / 100);
        } else {
          updates['commissionAmount'] =
              existingDeal.dealValue * (commissionPercentage / 100);
        }
      }
      if (advertisingPositions != null)
        updates['advertisingPositions'] = advertisingPositions;
      if (startDate != null)
        updates['startDate'] = startDate.millisecondsSinceEpoch;
      if (endDate != null) updates['endDate'] = endDate.millisecondsSinceEpoch;
      if (renewalReminder != null) updates['renewalReminder'] = renewalReminder;
      if (status != null) updates['status'] = status.toString();

      // Handle branding images update
      if (brandingImages != null && brandingImages.isNotEmpty) {
        // Upload new images
        final newUrls = await Future.wait(
          brandingImages.map((file) async {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final uniqueId = _uuid.v4(); // Generate a unique ID for each image
            final imagePath =
                'branding_${timestamp}_$uniqueId${path.extension(file.path)}';

            String? signedUrl = await _imagePicker.getSignedUrl(
              imagePath,
              AppConstant.bundleNameForPostAPI,
            );

            if (signedUrl == null) {
              throw Exception('Failed to get signed URL for image upload');
            }

            Completer<String> completer = Completer<String>();
            await _imagePicker.uploadFileToS3WithCallback(
              signedUrl,
              file.path,
              context,
              (url) => completer.complete(url),
              (error) => completer.completeError(error),
            );

            return await completer.future;
          }),
        );
        updates['brandingImageUrls'] = newUrls;
      }

      updates['updatedAt'] = ServerValue.timestamp;

      // Use the proper update method with type-safe Map
      await userDealsRef.child(id).update(updates);

      // Update sponsor's active deals count if needed
      if (sponsorId != null && sponsorId != existingDeal.sponsorId) {
        await _updateSponsorDealCount(existingDeal.sponsorId, -1);
        await _updateSponsorDealCount(sponsorId, 1);
      }
    } catch (e) {
      print('Error updating deal: $e');
      rethrow;
    }
  }

  // Delete deal
  Future<void> deleteDeal(String id) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final userDealsRef = getUserDealsRef(userId);

      // Get the existing deal to check if it exists and get sponsor info
      final snapshot = await userDealsRef.child(id).get();
      if (!snapshot.exists) {
        throw Exception('Deal not found');
      }

      final existingData = snapshot.value;
      if (existingData == null) {
        throw Exception('Deal data is null');
      }

      // Convert to proper Map type
      final existingDealMap = Map<String, dynamic>.from(existingData as Map);
      final existingDeal = DealDetailItem.fromMap(existingDealMap);

      // Delete associated branding images
      if (existingDeal.brandingImageUrls.isNotEmpty) {
        await Future.wait(
          existingDeal.brandingImageUrls.map((url) => deleteFile(url)),
        );
      }

      await userDealsRef.child(id).remove();

      // Update sponsor's active deals count
      await _updateSponsorDealCount(existingDeal.sponsorId, -1);
    } catch (e) {
      print('Error deleting deal: $e');
      rethrow;
    }
  }

  // Get deal by ID
  Future<DealDetailItem?> getDeal(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('No user logged in when trying to get deal');
      return null;
    }
    print('Fetching deal $id for user $userId');

    try {
      final userDealsRef = getUserDealsRef(userId);
      final snapshot = await userDealsRef.child(id).get();

      if (!snapshot.exists) {
        print('No deal found with ID $id');
        return null;
      }

      final data = snapshot.value;
      if (data == null) {
        print('Deal data is null for ID $id');
        return null;
      }

      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      final dealMap = Map<String, dynamic>.from(data as Map);
      dealMap['id'] = id; // Add the ID to the map

      final deal = DealDetailItem.fromMap(dealMap);
      print('Deal found with ${deal.brandingImageUrls.length} branding images');
      print('Branding image URLs: ${deal.brandingImageUrls}');
      return deal;
    } catch (e) {
      print('Error getting deal $id: $e');
      return null;
    }
  }

  // Stream all deals for a user
  Stream<List<DealItem>> streamDeals(String userId) {
    return streamList<DealItem>(getUserDealsRef(userId), _fromMapSimple);
  }

  // Stream active deals for a user
  Stream<List<DealItem>> streamActiveDeals(String userId) {
    return getUserDealsRef(
      userId,
    ).orderByChild('status').equalTo(DealStatusType.paid.toString()).onValue.map((
      event,
    ) {
      final data = event.snapshot.value;
      if (data == null) return <DealItem>[];

      try {
        if (data is Map) {
          return data.entries
              .map((entry) {
                try {
                  final value = entry.value;
                  Map<String, dynamic> dealMap;

                  if (value is Map) {
                    dealMap = Map<String, dynamic>.from(value);
                  } else if (value is String) {
                    try {
                      final jsonMap = jsonDecode(value) as Map<String, dynamic>;
                      dealMap = Map<String, dynamic>.from(jsonMap);
                    } catch (parseError) {
                      print('Error parsing active deal string: $parseError');
                      return null;
                    }
                  } else {
                    print(
                      'Unexpected active deal value type: ${value.runtimeType}',
                    );
                    return null;
                  }

                  dealMap['id'] = entry.key;
                  return _fromMapSimple(dealMap);
                } catch (e) {
                  print('Error processing active deal entry: $e');
                  return null;
                }
              })
              .whereType<DealItem>()
              .toList();
        } else if (data is String) {
          try {
            final jsonMap = jsonDecode(data) as Map<String, dynamic>;
            return jsonMap.entries
                .map((entry) {
                  try {
                    final value = entry.value;
                    Map<String, dynamic> dealMap;

                    if (value is Map) {
                      dealMap = Map<String, dynamic>.from(value);
                    } else if (value is String) {
                      final nestedJsonMap =
                          jsonDecode(value) as Map<String, dynamic>;
                      dealMap = Map<String, dynamic>.from(nestedJsonMap);
                    } else {
                      print(
                        'Unexpected nested active deal value type: ${value.runtimeType}',
                      );
                      return null;
                    }

                    dealMap['id'] = entry.key;
                    return _fromMapSimple(dealMap);
                  } catch (e) {
                    print('Error processing nested active deal entry: $e');
                    return null;
                  }
                })
                .whereType<DealItem>()
                .toList();
          } catch (parseError) {
            print('Error parsing active deals data string: $parseError');
            return <DealItem>[];
          }
        } else {
          print('Unexpected active deals data type: ${data.runtimeType}');
          return <DealItem>[];
        }
      } catch (e) {
        print('Error in streamActiveDeals: $e');
        return <DealItem>[];
      }
    });
  }

  // Stream deals by sponsor for a user
  Stream<List<DealItem>> streamDealsBySponsor(String userId, String sponsorId) {
    return getUserDealsRef(
      userId,
    ).orderByChild('sponsorId').equalTo(sponsorId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <DealItem>[];

      List<DealItem> deals = [];

      try {
        if (data is Map) {
          // Handle when data is a Map
          deals =
              data.entries
                  .map((entry) {
                    try {
                      final value = entry.value;
                      Map<String, dynamic> dealMap;

                      if (value is Map) {
                        // Value is already a Map
                        dealMap = Map<String, dynamic>.from(value);
                      } else if (value is String) {
                        // Value is a String, try to parse as JSON
                        try {
                          final jsonMap =
                              jsonDecode(value) as Map<String, dynamic>;
                          dealMap = Map<String, dynamic>.from(jsonMap);
                        } catch (parseError) {
                          print('Error parsing deal string: $parseError');
                          print('String value: $value');
                          return null;
                        }
                      } else {
                        print('Unexpected value type: ${value.runtimeType}');
                        return null;
                      }

                      dealMap['id'] = entry.key;
                      return _fromMapSimple(dealMap);
                    } catch (e) {
                      print('Error processing deal entry: $e');
                      print('Entry key: ${entry.key}');
                      print('Entry value: ${entry.value}');
                      return null;
                    }
                  })
                  .whereType<DealItem>()
                  .toList();
        } else if (data is String) {
          // Handle when entire data is a String
          try {
            final jsonMap = jsonDecode(data) as Map<String, dynamic>;
            deals =
                jsonMap.entries
                    .map((entry) {
                      try {
                        final value = entry.value;
                        Map<String, dynamic> dealMap;

                        if (value is Map) {
                          dealMap = Map<String, dynamic>.from(value);
                        } else if (value is String) {
                          final nestedJsonMap =
                              jsonDecode(value) as Map<String, dynamic>;
                          dealMap = Map<String, dynamic>.from(nestedJsonMap);
                        } else {
                          print(
                            'Unexpected nested value type: ${value.runtimeType}',
                          );
                          return null;
                        }

                        dealMap['id'] = entry.key;
                        return _fromMapSimple(dealMap);
                      } catch (e) {
                        print('Error processing nested deal entry: $e');
                        return null;
                      }
                    })
                    .whereType<DealItem>()
                    .toList();
          } catch (parseError) {
            print('Error parsing deals data string: $parseError');
            print('Data string: $data');
            return <DealItem>[];
          }
        } else {
          print('Unexpected data type: ${data.runtimeType}');
          return <DealItem>[];
        }

        // Sort deals by creation date in descending order (most recent first)
        deals.sort((a, b) {
          try {
            // Try to get creation date from the original data
            final aCreatedAt = _getCreatedAtFromData(data, a.id);
            final bCreatedAt = _getCreatedAtFromData(data, b.id);
            return bCreatedAt.compareTo(aCreatedAt);
          } catch (e) {
            print('Error sorting deals: $e');
            return 0;
          }
        });

        return deals;
      } catch (e) {
        print('Error in streamDealsBySponsor: $e');
        print('Data type: ${data.runtimeType}');
        return <DealItem>[];
      }
    });
  }

  // Helper method to extract createdAt from data
  DateTime _getCreatedAtFromData(dynamic data, String dealId) {
    try {
      if (data is Map) {
        final dealData = data[dealId];
        if (dealData is Map) {
          final createdAt = dealData['createdAt'];
          if (createdAt is int) {
            return DateTime.fromMillisecondsSinceEpoch(createdAt);
          }
        }
      }
      // Fallback to current time if we can't get the actual creation time
      return DateTime.now();
    } catch (e) {
      print('Error getting createdAt for deal $dealId: $e');
      return DateTime.now();
    }
  }

  // Stream deals by racer for a user
  Stream<List<DealItem>> streamDealsByRacer(String userId, String racerId) {
    return getUserDealsRef(
      userId,
    ).orderByChild('racerId').equalTo(racerId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <DealItem>[];

      try {
        if (data is Map) {
          return data.entries
              .map((entry) {
                try {
                  final value = entry.value;
                  Map<String, dynamic> dealMap;

                  if (value is Map) {
                    dealMap = Map<String, dynamic>.from(value);
                  } else if (value is String) {
                    try {
                      final jsonMap = jsonDecode(value) as Map<String, dynamic>;
                      dealMap = Map<String, dynamic>.from(jsonMap);
                    } catch (parseError) {
                      print('Error parsing racer deal string: $parseError');
                      return null;
                    }
                  } else {
                    print(
                      'Unexpected racer deal value type: ${value.runtimeType}',
                    );
                    return null;
                  }

                  dealMap['id'] = entry.key;
                  return _fromMapSimple(dealMap);
                } catch (e) {
                  print('Error processing racer deal entry: $e');
                  return null;
                }
              })
              .whereType<DealItem>()
              .toList();
        } else if (data is String) {
          try {
            final jsonMap = jsonDecode(data) as Map<String, dynamic>;
            return jsonMap.entries
                .map((entry) {
                  try {
                    final value = entry.value;
                    Map<String, dynamic> dealMap;

                    if (value is Map) {
                      dealMap = Map<String, dynamic>.from(value);
                    } else if (value is String) {
                      final nestedJsonMap =
                          jsonDecode(value) as Map<String, dynamic>;
                      dealMap = Map<String, dynamic>.from(nestedJsonMap);
                    } else {
                      print(
                        'Unexpected nested racer deal value type: ${value.runtimeType}',
                      );
                      return null;
                    }

                    dealMap['id'] = entry.key;
                    return _fromMapSimple(dealMap);
                  } catch (e) {
                    print('Error processing nested racer deal entry: $e');
                    return null;
                  }
                })
                .whereType<DealItem>()
                .toList();
          } catch (parseError) {
            print('Error parsing racer deals data string: $parseError');
            return <DealItem>[];
          }
        } else {
          print('Unexpected racer deals data type: ${data.runtimeType}');
          return <DealItem>[];
        }
      } catch (e) {
        print('Error in streamDealsByRacer: $e');
        return <DealItem>[];
      }
    });
  }

  // Helper method to update sponsor's active deals count
  Future<void> _updateSponsorDealCount(String sponsorId, int increment) async {
    try {
      final sponsorRef = sponsorsRef.child(sponsorId);
      final snapshot = await sponsorRef.child('activeDeals').get();
      final currentCount = snapshot.value as int? ?? 0;
      await sponsorRef.update({'activeDeals': currentCount + increment});
    } catch (e) {
      // Don't crash if sponsor update fails
      print('Warning: Failed to update sponsor deal count: $e');
    }
  }

  // Helper method to convert Map to DealItem (simplified version)
  DealItem _fromMapSimple(Map<String, dynamic> map) {
    try {
      // Handle endDate conversion safely
      DateTime endDate;
      if (map['endDate'] is int) {
        endDate = DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int);
      } else if (map['endDate'] is String) {
        // Try to parse as milliseconds if it's a string
        final endDateMs = int.tryParse(map['endDate'] as String);
        if (endDateMs != null) {
          endDate = DateTime.fromMillisecondsSinceEpoch(endDateMs);
        } else {
          // Fallback to current date
          endDate = DateTime.now();
        }
      } else {
        // Fallback to current date
        endDate = DateTime.now();
      }

      // Handle dealValue conversion safely
      String dealValue;
      if (map['dealValue'] is num) {
        dealValue = '\$${(map['dealValue'] as num).toStringAsFixed(2)}';
      } else if (map['dealValue'] is String) {
        final numericValue = double.tryParse(
          map['dealValue'].replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        dealValue = '\$${(numericValue ?? 0.0).toStringAsFixed(2)}';
      } else {
        dealValue = '\$0.00';
      }

      // Handle commissionPercentage conversion safely
      String commission;
      if (map['commissionPercentage'] is num) {
        commission =
            '${(map['commissionPercentage'] as num).toStringAsFixed(1)}%';
      } else if (map['commissionPercentage'] is String) {
        final numericValue = double.tryParse(
          map['commissionPercentage'].replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        commission = '${(numericValue ?? 0.0).toStringAsFixed(1)}%';
      } else {
        commission = '0.0%';
      }

      // Handle advertisingPositions conversion safely
      List<String> parts;
      if (map['advertisingPositions'] is List) {
        parts = List<String>.from(map['advertisingPositions'] as List);
      } else {
        parts = [];
      }

      return DealItem(
        sponsorId: map['sponsorId']?.toString() ?? '',
        racerId: map['racerId']?.toString() ?? '',
        eventId: map['eventId']?.toString() ?? '',
        sponsorInitials: map['sponsorInitials']?.toString() ?? '',
        racerInitials: map['racerInitials']?.toString() ?? '',
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        raceType: map['raceType']?.toString() ?? '',
        dealValue: dealValue,
        commission: commission,
        renewalDate: DateFormat('MMMM yyyy').format(endDate),
        parts: parts,
        status: DealStatusType.values.firstWhere(
          (e) => e.toString() == map['status']?.toString(),
          orElse: () => DealStatusType.pending,
        ),
      );
    } catch (e) {
      print('Error in _fromMapSimple: $e');
      print('Map data: $map');
      // Return a default DealItem instead of crashing
      return DealItem(
        sponsorId: '',
        racerId: '',
        eventId: '',
        sponsorInitials: '',
        racerInitials: '',
        id: '',
        title: 'Error Loading Deal',
        raceType: '',
        dealValue: '\$0.00',
        commission: '0.0%',
        renewalDate: DateFormat('MMMM yyyy').format(DateTime.now()),
        parts: [],
        status: DealStatusType.pending,
      );
    }
  }
}
