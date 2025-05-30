import 'package:flutter/material.dart';

enum SponsorStatus {
  active,
  renewSoon,
}

class Sponsor {
  final String id;
  final String initials;
  final String name;
  final String email;
  final String? contactNumber;
  final String? contactPerson;
  final String? industryType;
  final String? logoUrl;
  final String? notes;

  final List<String> parts; // e.g., "Car Doors", "Suit"
  final int activeDeals;
  final DateTime endDate;
  final SponsorStatus status;
  // Use enum for status

  Sponsor({
    required this.id,
    required this.initials,
    required this.name,
    required this.email,
    required this.parts,
    required this.activeDeals,
    required this.endDate,
    required this.status,
    this.contactNumber,
    this.contactPerson,
    this.industryType,
    this.logoUrl,
    this.notes,
  });

  factory Sponsor.fromMap(Map<String, dynamic> map) {
    return Sponsor(
      id: map['id'] as String,
      initials: map['initials'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      parts: List<String>.from(map['parts'] as List),
      activeDeals: map['activeDeals'] as int,
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int),
      status: SponsorStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => SponsorStatus.active,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'initials': initials,
      'name': name,
      'email': email,
      'parts': parts,
      'activeDeals': activeDeals,
      'endDate': endDate.millisecondsSinceEpoch,
      'status': status.toString(),
    };
  }

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

  static String generateInitials(String name) {
    if (name.isEmpty) return "";
    List<String> words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
}
