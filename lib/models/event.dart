
import 'package:flutter/material.dart';

enum EventStatusType {
  registrationOpen,
  registrationClosed,
}

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
  });
   String get statusText {
    switch (status) {
      case EventStatusType.registrationOpen:
        return "Registration Open";
      case EventStatusType.registrationClosed:
        return "Registration Closed";
    }
  }
  Color get statusColor {
    switch (status) {
      case EventStatusType.registrationOpen:
        return Colors.green; // Green for Open
      case EventStatusType.registrationClosed:
        return const Color(0xFFFF9800); // Orange for Closed
    }
  }
}