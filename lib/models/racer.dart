import 'package:flutter/material.dart';

class Racer {
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


  Racer({
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
  }
  );
  

  
}
