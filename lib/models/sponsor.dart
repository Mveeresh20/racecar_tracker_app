import 'package:flutter/material.dart';

enum SponsorStatus {
  active,
  renewSoon,
 
}

class Sponsor {
  final String initials;
  final String name;
  final String email;
  final List<String> parts; // e.g., "Car Doors", "Suit"
  final int activeDeals;
  final DateTime endDate;
  final SponsorStatus status; // Use enum for status

  Sponsor({
    required this.initials,
    required this.name,
    required this.email,
    required this.parts,
    required this.activeDeals,
    required this.endDate,
    required this.status,
  });

  // Helper getters for status text and color
  String get statusText {
    switch (status) {
      case SponsorStatus.active:
        return "Active";
      case SponsorStatus.renewSoon:
        return "Renew Soon";
    }
  }
  

  Color get statusColor {
    switch (status) {
      case SponsorStatus.active:
        return Color(0xFF24C166); 
      case SponsorStatus.renewSoon:
        return const Color(0xFF8CEAFC); 
    }
  }
}