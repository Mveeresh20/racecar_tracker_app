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
      List<String>? brandingImageUrls;

      // Upload branding images if provided
      if (brandingImages != null && brandingImages.isNotEmpty) {
        brandingImageUrls = await Future.wait(
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
      }

      // Calculate commission amount
      final commissionAmount = dealValue * (commissionPercentage / 100);

      // Create deal data
      final dealData = {
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
        'brandingImageUrls': brandingImageUrls,
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
        'renewalReminder': renewalReminder,
        'status': status.toString(),
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };

      final dealId = await create(getUserDealsRef(userId), dealData);

      // Update sponsor's active deals count
      await _updateSponsorDealCount(sponsorId, 1);

      return dealId;
    } catch (e) {
      rethrow;
    }
  }

  // Update deal
  Future<void> updateDeal(
    String id, {
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
      final deal = await getById<DealDetailItem>(
        dealsRef,
        id,
        DealDetailItem.fromMap,
      );
      if (deal == null) throw Exception('Deal not found');

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
              dealValue * (deal.commissionPercentage / 100);
        }
      }
      if (commissionPercentage != null) {
        updates['commissionPercentage'] = commissionPercentage;
        if (dealValue != null) {
          updates['commissionAmount'] =
              dealValue * (commissionPercentage / 100);
        } else {
          updates['commissionAmount'] =
              deal.dealValue * (commissionPercentage / 100);
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
      await update(dealsRef, id, updates);

      // Update sponsor's active deals count if needed
      if (sponsorId != null && sponsorId != deal.sponsorId) {
        await _updateSponsorDealCount(deal.sponsorId, -1);
        await _updateSponsorDealCount(sponsorId, 1);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete deal
  Future<void> deleteDeal(String id) async {
    try {
      final deal = await getById<DealDetailItem>(
        dealsRef,
        id,
        DealDetailItem.fromMap,
      );
      if (deal == null) throw Exception('Deal not found');

      // Delete associated branding images
      if (deal.brandingImageUrls.isNotEmpty) {
        await Future.wait(deal.brandingImageUrls.map((url) => deleteFile(url)));
      }

      await delete(dealsRef, id);

      // Update sponsor's active deals count
      await _updateSponsorDealCount(deal.sponsorId, -1);
    } catch (e) {
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
    final deal = await getById<DealDetailItem>(
      getUserDealsRef(userId),
      id,
      DealDetailItem.fromMap,
    );
    if (deal == null) {
      print('No deal found with ID $id');
    } else {
      print('Deal found with ${deal.brandingImageUrls.length} branding images');
      print('Branding image URLs: ${deal.brandingImageUrls}');
    }
    return deal;
  }

  // Stream all deals for a user
  Stream<List<DealItem>> streamDeals(String userId) {
    return streamList<DealItem>(getUserDealsRef(userId), _fromMapSimple);
  }

  // Stream active deals for a user
  Stream<List<DealItem>> streamActiveDeals(String userId) {
    return getUserDealsRef(userId)
        .orderByChild('status')
        .equalTo(DealStatusType.paid.toString())
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return <DealItem>[];

          return data.entries.map((entry) {
            final map = Map<String, dynamic>.from(entry.value as Map);
            map['id'] = entry.key;
            return _fromMapSimple(map);
          }).toList();
        });
  }

  // Stream deals by sponsor for a user
  Stream<List<DealItem>> streamDealsBySponsor(String userId, String sponsorId) {
    return getUserDealsRef(
      userId,
    ).orderByChild('sponsorId').equalTo(sponsorId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <DealItem>[];

      return data.entries.map((entry) {
        final map = Map<String, dynamic>.from(entry.value as Map);
        map['id'] = entry.key;
        return _fromMapSimple(map);
      }).toList();
    });
  }

  // Stream deals by racer for a user
  Stream<List<DealItem>> streamDealsByRacer(String userId, String racerId) {
    return getUserDealsRef(
      userId,
    ).orderByChild('racerId').equalTo(racerId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <DealItem>[];

      return data.entries.map((entry) {
        final map = Map<String, dynamic>.from(entry.value as Map);
        map['id'] = entry.key;
        return _fromMapSimple(map);
      }).toList();
    });
  }

  // Helper method to update sponsor's active deals count
  Future<void> _updateSponsorDealCount(String sponsorId, int increment) async {
    final sponsorRef = sponsorsRef.child(sponsorId);
    final snapshot = await sponsorRef.child('activeDeals').get();
    final currentCount = snapshot.value as int? ?? 0;
    await sponsorRef.update({'activeDeals': currentCount + increment});
  }

  // Helper method to convert Map to DealItem (simplified version)
  DealItem _fromMapSimple(Map<String, dynamic> map) {
    return DealItem(
      sponsorId: map['sponsorId'] as String,
      racerId: map['racerId'] as String,
      eventId: map['eventId'] as String,
      sponsorInitials: map['sponsorInitials'] as String,
      racerInitials: map['racerInitials'] as String,
      id: map['id'] as String,
      title: map['title'] as String,
      raceType: map['raceType'] as String,
      dealValue: (map['dealValue'] as num).toString(),
      commission: '${(map['commissionPercentage'] as num).toStringAsFixed(1)}%',
      renewalDate:
          DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int).toString(),
      parts: List<String>.from(map['advertisingPositions'] as List),
      status: DealStatusType.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => DealStatusType.pending,
      ),
    );
  }
}
