import 'package:flutter/material.dart';
import 'package:racecar_tracker/models/deal_detail_item.dart';

enum DealStatusType {
  pending,
  paid,
  // Add other statuses like 'completed', 'cancelled' if needed
}

class DealItem {
  final String id;
  final String sponsorId;
  final String racerId;
  final String eventId;
  final String title;
  final String raceType;
  final String dealValue;
  final String commission;
  final String renewalDate;
  final List<String> parts;
  final DealStatusType status;
  final String sponsorInitials;
  final String racerInitials;

  DealItem({
    required this.id,
    required this.sponsorId,
    required this.racerId,
    required this.eventId,
    required this.title,
    required this.raceType,
    required this.dealValue,
    required this.commission,
    required this.renewalDate,
    required this.parts,
    required this.status,
    required this.sponsorInitials,
    required this.racerInitials,
  });

  // Convert to DealDetailItem
  DealDetailItem toDetailItem({
    required double commissionPercentage,
    required double commissionAmount,
    required DateTime startDate,
    required DateTime endDate,
    required String renewalReminder,
    required List<String> brandingImageUrls,
  }) {
    return DealDetailItem(
      id: id,
      sponsorId: sponsorId,
      racerId: racerId,
      eventId: eventId,
      title: title,
      raceType: raceType,
      dealValue: double.parse(dealValue.replaceAll(RegExp(r'[^0-9.]'), '')),
      commissionPercentage: commissionPercentage,
      commissionAmount: commissionAmount,
      renewalReminder: renewalReminder,
      startDate: startDate,
      endDate: endDate,
      parts: parts,
      brandingImageUrls: brandingImageUrls,
      status: status,
      sponsorInitials: sponsorInitials,
      racerInitials: racerInitials,
    );
  }

  // Factory method to create from map
  factory DealItem.fromMap(Map<String, dynamic> map) {
    try {
      return DealItem(
        id: map['id']?.toString() ?? '',
        sponsorId: map['sponsorId']?.toString() ?? '',
        racerId: map['racerId']?.toString() ?? '',
        eventId: map['eventId']?.toString() ?? '',
         title : map['title'] as String? ?? 'Untitled',

        
        raceType: map['raceType']?.toString() ?? '',
        dealValue:
            (map['dealValue'] is num)
                ? map['dealValue'].toString()
                : (map['dealValue']?.toString() ?? '0'),
        commission:
            map['commissionPercentage'] != null
                ? '${(map['commissionPercentage'] as num).toStringAsFixed(1)}%'
                : '0%',
        renewalDate:
            map['endDate'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                  map['endDate'] as int,
                ).toString()
                : DateTime.now().toString(),
        parts:
            (map['advertisingPositions'] as List<dynamic>?)
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
      print('Error creating DealItem from map: $e');
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
      'commissionPercentage': double.parse(commission.replaceAll('%', '')),
      'endDate': DateTime.parse(renewalDate).millisecondsSinceEpoch,
      'advertisingPositions': parts,
      'status': status.toString(),
      'sponsorInitials': sponsorInitials,
      'racerInitials': racerInitials,
    };
  }

  // Helper getters for status text and color
  String get statusText {
    switch (status) {
      case DealStatusType.pending:
        return "Pending";
      case DealStatusType.paid:
        return "Paid";
    }
  }

  Color get statusColor {
    switch (status) {
      case DealStatusType.pending:
        return const Color(0xFFFF9800); // Light orange for Pending
      case DealStatusType.paid:
        return Color(0xFF4CAF50); // Green for Paid
    }
  }
}
