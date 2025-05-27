import 'package:flutter/material.dart';

enum EventStatusType { registrationOpen, registrationClosed }

class Event {
  final String title;
  final String raceType;
  final int currentRacers;
  final int maxRacers;
  final EventStatusType status;
  final String trackName;

  final String type;
  final DateTime dateTime;
  final String location;
  final List<String> racerImageUrls;
  final int totalOtherRacers;
  final String raceName;

  Event({
    required this.title,
    required this.type,
    required this.dateTime,
    required this.location,
    this.racerImageUrls = const [],
    this.totalOtherRacers = 0,

    required this.raceType,
    required this.trackName,
    required this.currentRacers,
    required this.maxRacers,
    required this.status,
    this.raceName = '',
  });
  String get statusText {
    switch (status) {
      case EventStatusType.registrationOpen:
        return "Registration\nopen";
      case EventStatusType.registrationClosed:
        return "Registration\nClosed";
    }
  }

  Color get statusColor {
    switch (status) {
      case EventStatusType.registrationOpen:
        return Color(0xFFA8E266); // Green for Open
      case EventStatusType.registrationClosed:
        return const Color(0xFFFE5F38); // Orange for Closed
    }
  }
}
