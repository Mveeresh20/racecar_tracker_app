import 'package:flutter/material.dart';

enum EventStatusType { registrationOpen, registrationClosed }

class Event {
  final String id;
  final String raceName;
  final String type;
  final String location;
  final String title;
  final String raceType;
  final DateTime dateTime;
  final String trackName;
  final int currentRacers;
  final int maxRacers;
  final EventStatusType status;
  final List<String> racerImageUrls;
  final int totalOtherRacers;

  Event({
    required this.id,
    required this.raceName,
    required this.type,
    required this.location,
    required this.title,
    required this.raceType,
    required this.dateTime,
    required this.trackName,
    required this.currentRacers,
    required this.maxRacers,
    required this.status,
    required this.racerImageUrls,
    required this.totalOtherRacers,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      raceName: map['raceName'] as String,
      type: map['type'] as String,
      location: map['location'] as String,
      title: map['title'] as String,
      raceType: map['raceType'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      trackName: map['trackName'] as String,
      currentRacers: map['currentRacers'] as int,
      maxRacers: map['maxRacers'] as int,
      status: EventStatusType.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => EventStatusType.registrationOpen,
      ),
      racerImageUrls: List<String>.from(map['racerImageUrls'] as List),
      totalOtherRacers: map['totalOtherRacers'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'raceName': raceName,
      'type': type,
      'location': location,
      'title': title,
      'raceType': raceType,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'trackName': trackName,
      'currentRacers': currentRacers,
      'maxRacers': maxRacers,
      'status': status.toString(),
      'racerImageUrls': racerImageUrls,
      'totalOtherRacers': totalOtherRacers,
    };
  }

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
