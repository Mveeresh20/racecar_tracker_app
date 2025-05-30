import 'package:flutter/material.dart';

class Racer {
  final String id;
  final String initials; // e.g., "WB", "JM"
  final String vehicleImageUrl; // URL for the racer's specific vehicle image
  final String name; // e.g., "Wayne Brotzký"
  final String vehicleModel; // e.g., "Ferrari F2004"
  final String teamName; // e.g., "Speed Rebels"
  final String currentEvent; // e.g., "Summer GP 2025"
  final String earnings;

  ///below are racer details // e.g., "$5,200"
  final String contactNumber;
  final String vehicleNumber;
  final int activeRaces;
  final int totalRaces;
  final String? racerImageUrl; // URL for the racer's profile image
  final bool isLocalImage; // Flag to indicate if the image is local or network

  Racer({
    required this.id,
    required this.initials,
    required this.vehicleImageUrl,
    required this.name,
    required this.vehicleModel,
    required this.teamName,
    required this.currentEvent,
    required this.earnings,
    //
    required this.contactNumber,
    required this.vehicleNumber,
    required this.activeRaces,
    required this.totalRaces,
    this.racerImageUrl,
    this.isLocalImage = true,
  });

  factory Racer.fromMap(Map<String, dynamic> map) {
    return Racer(
      id: map['id'] as String,
      initials: map['initials'] as String,
      vehicleImageUrl: map['vehicleImageUrl'] as String,
      name: map['name'] as String,
      vehicleModel: map['vehicleModel'] as String,
      teamName: map['teamName'] as String,
      currentEvent: map['currentEvent'] as String,
      earnings: map['earnings'] as String,
      contactNumber: map['contactNumber'] as String,
      vehicleNumber: map['vehicleNumber'] as String,
      activeRaces: map['activeRaces'] as int,
      totalRaces: map['totalRaces'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'initials': initials,
      'vehicleImageUrl': vehicleImageUrl,
      'name': name,
      'vehicleModel': vehicleModel,
      'teamName': teamName,
      'currentEvent': currentEvent,
      'earnings': earnings,
      'contactNumber': contactNumber,
      'vehicleNumber': vehicleNumber,
      'activeRaces': activeRaces,
      'totalRaces': totalRaces,
    };
  }
}
