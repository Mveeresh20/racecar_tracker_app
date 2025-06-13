import 'package:flutter/material.dart';
import 'package:racecar_tracker/models/deal_detail_item.dart';

enum DealStatusType { pending, paid }

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
      // Helper function to safely get string values
      String safeString(dynamic value, [String defaultValue = '']) {
        if (value == null) return defaultValue;
        return value.toString();
      }

      // Helper function to safely get list values
      List<String> safeList(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
        if (value is String) {
          return [value];
        }
        return [];
      }

      String safeNumeric(dynamic value, [String defaultValue = '0']) {
        if (value == null) return defaultValue;
        if (value is num) return value.toString();
        if (value is String) {
         
          final numericValue = double.tryParse(
            value.replaceAll(RegExp(r'[^0-9.]'), ''),
          );
          return numericValue?.toString() ?? defaultValue;
        }
        return defaultValue;
      }

      
      String safeDate(dynamic value) {
        if (value == null) return DateTime.now().toIso8601String();
        if (value is int) {
          return DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
        }
        if (value is String) {
          try {
            // Try parsing as milliseconds timestamp
            final timestamp = int.tryParse(value);
            if (timestamp != null) {
              return DateTime.fromMillisecondsSinceEpoch(
                timestamp,
              ).toIso8601String();
            }
            // Try parsing as date string
            return DateTime.parse(value).toIso8601String();
          } catch (e) {
            print('Error parsing date: $e');
            return DateTime.now().toIso8601String();
          }
        }
        return DateTime.now().toIso8601String();
      }

      return DealItem(
        id: safeString(map['id']),
        sponsorId: safeString(map['sponsorId']),
        racerId: safeString(map['racerId']),
        eventId: safeString(map['eventId']),
        title: safeString(map['title'], 'Untitled'),
        raceType: safeString(map['raceType']),
        dealValue: safeNumeric(map['dealValue']),
        commission:
            map['commissionPercentage'] != null
                ? '${safeNumeric(map['commissionPercentage'])}%'
                : '0%',
        renewalDate: safeDate(map['endDate']),
        parts: safeList(map['advertisingPositions']),
        status: DealStatusType.values.firstWhere(
          (e) => e.toString() == safeString(map['status']),
          orElse: () => DealStatusType.pending,
        ),
        sponsorInitials: safeString(map['sponsorInitials']),
        racerInitials: safeString(map['racerInitials']),
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
        return const Color(0xFFFF9800); 
      case DealStatusType.paid:
        return Color(0xFF4CAF50); 
    }
  }
}
