import 'package:flutter/material.dart';

enum DealStatus { pending, active, expired, completed } // Example enum for status

class SponsorshipDeal {
  final String title;
  final String dealValue;
  final String commission;
  final String renewalDate;
  final DealStatus status;

  SponsorshipDeal({
    required this.title,
    required this.dealValue,
    required this.commission,
    required this.renewalDate,
    required this.status,
  });

  // Helper to get status color
  Color get statusColor {
    switch (status) {
      case DealStatus.pending:
        return Colors.orange;
      case DealStatus.active:
        return Colors.green;
      case DealStatus.expired:
        return Colors.red;
      case DealStatus.completed:
        return Colors.blue;
    }
  }

  String get statusText {
    return status.toString().split('.').last.toUpperCase(); // Converts enum to "PENDING"
  }
}