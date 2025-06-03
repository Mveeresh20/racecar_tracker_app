import 'package:flutter/material.dart';

enum SponsorStatus { active, renewSoon }

class Sponsor {
  final String id;
  final String userId;
  final String initials;
  final String name;
  final String email;
  final String? contactNumber;
  final String? contactPerson;
  final String? industryType;
  final String? logoUrl;
  final String? notes;
  final List<String> parts;
  final int activeDeals;
  final DateTime endDate;
  final SponsorStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? sponsorshipAmount;
  final String? lastDealAmount;
  final int totalDeals;
  final String? commission;

  Sponsor({
    required this.id,
    required this.userId,
    required this.initials,
    required this.name,
    required this.email,
    required this.parts,
    required this.activeDeals,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.contactNumber,
    this.contactPerson,
    this.industryType,
    this.logoUrl,
    this.notes,
    this.sponsorshipAmount,
    this.lastDealAmount,
    this.totalDeals = 0,
    this.commission,
  });

  factory Sponsor.fromMap(Map<dynamic, dynamic> map) {
    return Sponsor(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      initials: map['initials']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      parts:
          (map['parts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      activeDeals: (map['activeDeals'] as num?)?.toInt() ?? 0,
      endDate: DateTime.fromMillisecondsSinceEpoch(
        (map['endDate'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      status: SponsorStatus.values.firstWhere(
        (e) => e.toString() == map['status']?.toString(),
        orElse: () => SponsorStatus.active,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      contactNumber: map['contactNumber']?.toString(),
      contactPerson: map['contactPerson']?.toString(),
      industryType: map['industryType']?.toString(),
      logoUrl: map['logoUrl']?.toString(),
      notes: map['notes']?.toString(),
      sponsorshipAmount: map['sponsorshipAmount']?.toString(),
      lastDealAmount: map['lastDealAmount']?.toString(),
      totalDeals: (map['totalDeals'] as num?)?.toInt() ?? 0,
      commission: map['commission']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'initials': initials,
      'name': name,
      'email': email,
      'parts': parts,
      'activeDeals': activeDeals,
      'endDate': endDate.millisecondsSinceEpoch,
      'status': status.toString(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'contactNumber': contactNumber,
      'contactPerson': contactPerson,
      'industryType': industryType,
      'logoUrl': logoUrl,
      'notes': notes,
      'sponsorshipAmount': sponsorshipAmount,
      'lastDealAmount': lastDealAmount,
      'totalDeals': totalDeals,
      'commission': commission,
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
        return const Color(0xFF24C166);
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

  // Create a copy of the sponsor with updated fields
  Sponsor copyWith({
    String? id,
    String? userId,
    String? initials,
    String? name,
    String? email,
    List<String>? parts,
    int? activeDeals,
    DateTime? endDate,
    SponsorStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? contactNumber,
    String? contactPerson,
    String? industryType,
    String? logoUrl,
    String? notes,
    String? sponsorshipAmount,
    String? lastDealAmount,
    int? totalDeals,
    String? commission,
  }) {
    return Sponsor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      initials: initials ?? this.initials,
      name: name ?? this.name,
      email: email ?? this.email,
      parts: parts ?? this.parts,
      activeDeals: activeDeals ?? this.activeDeals,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contactNumber: contactNumber ?? this.contactNumber,
      contactPerson: contactPerson ?? this.contactPerson,
      industryType: industryType ?? this.industryType,
      logoUrl: logoUrl ?? this.logoUrl,
      notes: notes ?? this.notes,
      sponsorshipAmount: sponsorshipAmount ?? this.sponsorshipAmount,
      lastDealAmount: lastDealAmount ?? this.lastDealAmount,
      totalDeals: totalDeals ?? this.totalDeals,
      commission: commission ?? this.commission,
    );
  }
}
