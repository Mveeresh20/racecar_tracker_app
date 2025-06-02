import 'package:flutter/material.dart';
import 'package:racecar_tracker/models/sponsor.dart';

class Racer {
  final String id;
  final String userId;
  final String name;
  final String teamName;
  final String vehicleModel;
  final String contactNumber;
  final String vehicleNumber;
  final String currentEvent;
  final String? racerImageUrl;
  final String? vehicleImageUrl;
  final String initials;
  final int activeRaces;
  final int totalRaces;
  final String earnings;
  final DateTime createdAt;
  final DateTime updatedAt;

  Racer({
    required this.id,
    required this.userId,
    required this.name,
    required this.teamName,
    required this.vehicleModel,
    required this.contactNumber,
    required this.vehicleNumber,
    required this.currentEvent,
    this.racerImageUrl,
    this.vehicleImageUrl,
    required this.initials,
    required this.activeRaces,
    required this.totalRaces,
    required this.earnings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Racer.fromMap(Map<String, dynamic> map) {
    return Racer(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      teamName: map['teamName'] as String,
      vehicleModel: map['vehicleModel'] as String,
      contactNumber: map['contactNumber'] as String,
      vehicleNumber: map['vehicleNumber'] as String,
      currentEvent: map['currentEvent'] as String,
      racerImageUrl: map['racerImageUrl'] as String?,
      vehicleImageUrl: map['vehicleImageUrl'] as String?,
      initials: map['initials'] as String,
      activeRaces: map['activeRaces'] as int? ?? 0,
      totalRaces: map['totalRaces'] as int? ?? 0,
      earnings: map['earnings'] as String? ?? '0',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'teamName': teamName,
      'vehicleModel': vehicleModel,
      'contactNumber': contactNumber,
      'vehicleNumber': vehicleNumber,
      'currentEvent': currentEvent,
      'racerImageUrl': racerImageUrl,
      'vehicleImageUrl': vehicleImageUrl,
      'initials': initials,
      'activeRaces': activeRaces,
      'totalRaces': totalRaces,
      'earnings': earnings,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Racer copyWith({
    String? id,
    String? userId,
    String? name,
    String? teamName,
    String? vehicleModel,
    String? contactNumber,
    String? vehicleNumber,
    String? currentEvent,
    String? racerImageUrl,
    String? vehicleImageUrl,
    String? initials,
    int? activeRaces,
    int? totalRaces,
    String? earnings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Racer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      teamName: teamName ?? this.teamName,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      contactNumber: contactNumber ?? this.contactNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      currentEvent: currentEvent ?? this.currentEvent,
      racerImageUrl: racerImageUrl ?? this.racerImageUrl,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      initials: initials ?? this.initials,
      activeRaces: activeRaces ?? this.activeRaces,
      totalRaces: totalRaces ?? this.totalRaces,
      earnings: earnings ?? this.earnings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLocalImage {
    return (racerImageUrl?.startsWith('file://') ?? false) ||
        (vehicleImageUrl?.startsWith('file://') ?? false);
  }

  bool get isLocalRacerImage {
    return racerImageUrl?.startsWith('file://') ?? false;
  }

  bool get isLocalVehicleImage {
    return vehicleImageUrl?.startsWith('file://') ?? false;
  }
}
