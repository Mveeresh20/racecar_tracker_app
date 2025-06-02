// lib/models/deal_detail_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/models/deal_item.dart';
// Import shared enum

class DealDetailItem {
  final String id; // Matches the ID from DealCardItem
  final String sponsorId;
  final String racerId;
  final String eventId;

  // Fields visible on the Deal Detail screen
  final String title; // "DC Auto X John Meave"
  final String raceType; // "Summership 2023"
  final double dealValue;
  final double commissionPercentage;
  final double commissionAmount;
  final String renewalReminder; // "2 Days Before"
  final DateTime startDate; // "03/12/2025"
  final DateTime endDate; // "03/25/2025"
  final List<String> parts; // Assigned Branding Locations
  final List<String> brandingImageUrls; // Branding images
  final DealStatusType status; // "Pending" / "Paid"

  // Additional detail-specific fields for the top section
  final String sponsorInitials; // "DC"
  final String racerInitials; // "JM"

  DealDetailItem({
    required this.id,
    required this.sponsorId,
    required this.racerId,
    required this.eventId,
    required this.title,
    required this.raceType,
    required this.dealValue,
    required this.commissionPercentage,
    required this.commissionAmount,
    required this.renewalReminder,
    required this.startDate,
    required this.endDate,
    required this.parts,
    required this.brandingImageUrls,
    required this.status,
    required this.sponsorInitials,
    required this.racerInitials,
  });

  // Getters for formatted values
  String get totalDealAmount => '\$${dealValue.toStringAsFixed(2)}';
  String get yourCommission => '${commissionPercentage.toStringAsFixed(1)}%';
  String get yourEarn => '\$${commissionAmount.toStringAsFixed(2)}';

  // Factory method to create from map
  factory DealDetailItem.fromMap(Map<String, dynamic> map) {
    try {
      return DealDetailItem(
        id: map['id']?.toString() ?? '',
        sponsorId: map['sponsorId']?.toString() ?? '',
        racerId: map['racerId']?.toString() ?? '',
        eventId: map['eventId']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        raceType: map['raceType']?.toString() ?? '',
        dealValue:
            (map['dealValue'] is num)
                ? (map['dealValue'] as num).toDouble()
                : double.tryParse(map['dealValue']?.toString() ?? '0') ?? 0.0,
        commissionPercentage:
            (map['commissionPercentage'] is num)
                ? (map['commissionPercentage'] as num).toDouble()
                : double.tryParse(
                      map['commissionPercentage']?.toString() ?? '0',
                    ) ??
                    0.0,
        commissionAmount:
            (map['commissionAmount'] is num)
                ? (map['commissionAmount'] as num).toDouble()
                : double.tryParse(map['commissionAmount']?.toString() ?? '0') ??
                    0.0,
        renewalReminder: map['renewalReminder']?.toString() ?? '',
        startDate:
            map['startDate'] != null
                ? DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int)
                : DateTime.now(),
        endDate:
            map['endDate'] != null
                ? DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int)
                : DateTime.now().add(const Duration(days: 365)),
        parts:
            (map['advertisingPositions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        brandingImageUrls:
            (map['brandingImageUrls'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        status: DealStatusType.values.firstWhere(
          (e) => e.toString() == map['status']?.toString(),
          orElse: () => DealStatusType.pending,
        ),
        sponsorInitials: map['sponsorInitials']?.toString() ?? '',
        racerInitials: map['racerInitials']?.toString() ?? '',
      );
    } catch (e) {
      print('Error creating DealDetailItem from map: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sponsorId': sponsorId,
      'racerId': racerId,
      'eventId': eventId,
      'title': title,
      'raceType': raceType,
      'dealValue': dealValue,
      'commissionPercentage': commissionPercentage,
      'commissionAmount': commissionAmount,
      'renewalReminder': renewalReminder,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'advertisingPositions': parts,
      'brandingImageUrls': brandingImageUrls,
      'status': status.toString(),
      'sponsorInitials': sponsorInitials,
      'racerInitials': racerInitials,
    };
  }
}
