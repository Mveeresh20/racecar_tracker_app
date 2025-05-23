import 'package:flutter/material.dart';

enum DealStatusType {
  pending,
  paid,
  // Add other statuses like 'completed', 'cancelled' if needed
}

class DealItem {
  final String title; // e.g., "ABC Motors X Sarah White"
  final String raceType; // e.g., "Summer Race"
  final String dealValue; // e.g., "$1500"
  final String commission; // e.g., "10%"
  final String renewalDate; // e.g., "June 2026"
  final List<String> parts; // e.g., ["Car Doors", "Suit"]
  final DealStatusType status; // e.g., DealStatusType.pending

  DealItem({
    required this.title,
    required this.raceType,
    required this.dealValue,
    required this.commission,
    required this.renewalDate,
    required this.parts,
    required this.status,
  });

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