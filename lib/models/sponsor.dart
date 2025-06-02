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

  factory Sponsor.fromMap(Map<String, dynamic> map) {
    try {
      // Handle numeric fields
      final activeDeals =
          (map['activeDeals'] is num)
              ? (map['activeDeals'] as num).toInt()
              : int.tryParse(map['activeDeals']?.toString() ?? '0') ?? 0;

      final totalDeals =
          (map['totalDeals'] is num)
              ? (map['totalDeals'] as num).toInt()
              : int.tryParse(map['totalDeals']?.toString() ?? '0') ?? 0;

      // Handle dates
      final createdAt =
          (map['createdAt'] is num)
              ? DateTime.fromMillisecondsSinceEpoch(
                (map['createdAt'] as num).toInt(),
              )
              : DateTime.now();

      final updatedAt =
          (map['updatedAt'] is num)
              ? DateTime.fromMillisecondsSinceEpoch(
                (map['updatedAt'] as num).toInt(),
              )
              : DateTime.now();

      final endDate =
          (map['endDate'] is num)
              ? DateTime.fromMillisecondsSinceEpoch(
                (map['endDate'] as num).toInt(),
              )
              : DateTime.now().add(const Duration(days: 365));

      // Handle parts list
      List<String> parts = [];
      if (map['parts'] is List) {
        parts = List<String>.from(map['parts']);
      } else if (map['parts'] is String) {
        parts = [map['parts']];
      }

      // Handle status
      final statusStr = map['status']?.toString() ?? 'SponsorStatus.active';
      final status = SponsorStatus.values.firstWhere(
        (e) => e.toString() == statusStr,
        orElse: () => SponsorStatus.active,
      );

      // Handle commission
      String commission = '0%';
      if (map['commission'] != null) {
        commission = map['commission'].toString();
        if (!commission.contains('%')) {
          commission = '$commission%';
        }
      }

      // Handle sponsorship amount
      String sponsorshipAmount = '0';
      if (map['sponsorshipAmount'] != null) {
        if (map['sponsorshipAmount'] is num) {
          sponsorshipAmount = (map['sponsorshipAmount'] as num).toString();
        } else {
          sponsorshipAmount = map['sponsorshipAmount'].toString();
        }
      }

      return Sponsor(
        id: map['id']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        contactNumber: map['contactNumber']?.toString() ?? '',
        contactPerson: map['contactPerson']?.toString() ?? '',
        industryType: map['industryType']?.toString() ?? '',
        logoUrl: map['logoUrl']?.toString() ?? '',
        parts: parts,
        activeDeals: activeDeals,
        totalDeals: totalDeals,
        commission: commission,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
        endDate: endDate,
        notes: map['notes']?.toString() ?? '',
        sponsorshipAmount: sponsorshipAmount,
        initials: map['initials']?.toString() ?? '',
      );
    } catch (e) {
      print('Error creating Sponsor from map: $e');
      print('Map data: $map');
      rethrow;
    }
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
