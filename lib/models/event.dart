import 'package:flutter/material.dart';

enum EventStatusType {
  registrationOpen,
  registrationClosed,
  upcoming,
  ongoing,
  completed,
}

class Event {
  final String id;
  final String userId;
  final String name;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final EventStatusType status;
  final String type;
  final String description;
  final String? imageUrl;
  final List<String>? racerImageUrls;
  final int totalRacers;
  final int currentRacers;
  final int maxRacers;
  final int totalSponsors;
  final double totalPrizeMoney;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? trackName;

  Event({
    required this.id,
    required this.userId,
    required this.name,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.type,
    required this.description,
    this.imageUrl,
    this.racerImageUrls,
    required this.totalRacers,
    this.currentRacers = 0,
    this.maxRacers = 0,
    required this.totalSponsors,
    required this.totalPrizeMoney,
    required this.createdAt,
    required this.updatedAt,
    this.trackName,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(
        map['startDate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      endDate: DateTime.fromMillisecondsSinceEpoch(
        map['endDate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      status: EventStatusType.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            map['status']?.toString().split('.').last,
        orElse: () => EventStatusType.upcoming,
      ),
      type: map['type'] as String? ?? 'race',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      racerImageUrls:
          (map['racerImageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      totalRacers: map['totalRacers'] as int? ?? 0,
      currentRacers: map['currentRacers'] as int? ?? 0,
      maxRacers: map['maxRacers'] as int? ?? 0,
      totalSponsors: map['totalSponsors'] as int? ?? 0,
      totalPrizeMoney:
          (map['totalPrizeMoney'] is int)
              ? (map['totalPrizeMoney'] as int).toDouble()
              : (map['totalPrizeMoney'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      trackName: map['trackName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'location': location,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'status': status.toString(),
      'type': type,
      'description': description,
      'imageUrl': imageUrl,
      'racerImageUrls': racerImageUrls,
      'totalRacers': totalRacers,
      'currentRacers': currentRacers,
      'maxRacers': maxRacers,
      'totalSponsors': totalSponsors,
      'totalPrizeMoney': totalPrizeMoney,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'trackName': trackName,
    };
  }

  Event copyWith({
    String? id,
    String? userId,
    String? name,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    EventStatusType? status,
    String? type,
    String? description,
    String? imageUrl,
    List<String>? racerImageUrls,
    int? totalRacers,
    int? currentRacers,
    int? maxRacers,
    int? totalSponsors,
    double? totalPrizeMoney,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? trackName,
  }) {
    return Event(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      type: type ?? this.type,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      racerImageUrls: racerImageUrls ?? this.racerImageUrls,
      totalRacers: totalRacers ?? this.totalRacers,
      currentRacers: currentRacers ?? this.currentRacers,
      maxRacers: maxRacers ?? this.maxRacers,
      totalSponsors: totalSponsors ?? this.totalSponsors,
      totalPrizeMoney: totalPrizeMoney ?? this.totalPrizeMoney,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackName: trackName ?? this.trackName,
    );
  }

  String get statusText {
    switch (status) {
      case EventStatusType.registrationOpen:
        return "Registration Open";
      case EventStatusType.registrationClosed:
        return "Registration Closed";
      case EventStatusType.upcoming:
        return "Upcoming";
      case EventStatusType.ongoing:
        return "Ongoing";
      case EventStatusType.completed:
        return "Completed";
    }
  }

  Color get statusColor {
    switch (status) {
      case EventStatusType.registrationOpen:
        return const Color(0xFFA8E266); 
      case EventStatusType.registrationClosed:
        return const Color(0xFFFE5F38); 
      case EventStatusType.upcoming:
        return const Color(0xFFA8E266); 
      case EventStatusType.ongoing:
        return const Color(0xFFFE5F38); 
      case EventStatusType.completed:
        return const Color(0xFFFE5F38); 
    }
  }
}
