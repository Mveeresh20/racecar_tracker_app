// lib/models/deal_detail_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/models/deal_item.dart';
// Import shared enum

class DealDetailItem {
  final String id; // Matches the ID from DealCardItem

  // Fields visible on the Deal Detail screen
  final String title; // "DC Auto X John Meave"
  final String raceType; // "Summership 2023"
  final String totalDealAmount; // "$1,20,000"
  final String yourCommission; // "20%"
  final String yourEarn; // "$20,000"
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
    required this.title,
    required this.raceType,
    required this.totalDealAmount,
    required this.yourCommission,
    required this.yourEarn,
    required this.renewalReminder,
    required this.startDate,
    required this.endDate,
    required this.parts,
    required this.brandingImageUrls,
    required this.status,
    required this.sponsorInitials,
    required this.racerInitials,
  });
}