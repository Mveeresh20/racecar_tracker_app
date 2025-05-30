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
    return DealDetailItem(
      id: map['id'] as String,
      sponsorId: map['sponsorId'] as String,
      racerId: map['racerId'] as String,
      eventId: map['eventId'] as String,
      title: map['title'] as String,
      raceType: map['raceType'] as String,
      dealValue: (map['dealValue'] as num).toDouble(),
      commissionPercentage: (map['commissionPercentage'] as num).toDouble(),
      commissionAmount: (map['commissionAmount'] as num).toDouble(),
      renewalReminder: map['renewalReminder'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int),
      parts: List<String>.from(map['advertisingPositions'] as List),
      brandingImageUrls: List<String>.from(
        map['brandingImageUrls'] as List? ?? [],
      ),
      status: DealStatusType.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => DealStatusType.pending,
      ),
      sponsorInitials: map['sponsorInitials'] as String,
      racerInitials: map['racerInitials'] as String,
    );
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
