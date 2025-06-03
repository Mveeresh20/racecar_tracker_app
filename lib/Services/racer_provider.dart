import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/Services/racer_service.dart';

class RacerProvider extends ChangeNotifier {
  final RacerService _racerService = RacerService();
  List<Racer> _racers = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _racersSubscription;

  List<Racer> get racers => _racers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize racers for a user
  Future<void> initializeRacers(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cancel any existing subscription
      await _racersSubscription?.cancel();

      // Clear existing data
      _racers = [];
      print('RacerProvider: Initializing racers for user $userId');

      // Set up new subscription
      _racersSubscription = _racerService
          .getRacersStream(userId)
          .listen(
            (updatedRacers) {
              print(
                'RacerProvider: Stream emitted ${updatedRacers.length} racers',
              );
              _racers = updatedRacers;
              _isLoading = false;
              _error = null;
              notifyListeners();
              print(
                'RacerProvider: notifyListeners called with ${_racers.length} racers',
              );
            },
            onError: (error) {
              print('RacerProvider: Error in stream: $error');
              _error = error.toString();
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      print('RacerProvider: Error initializing stream: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new racer
  Future<String?> createRacer({
    required String userId,
    required String name,
    required String teamName,
    required String vehicleModel,
    required String contactNumber,
    required String vehicleNumber,
    required String currentEvent,
    File? racerImage,
    File? vehicleImage,
    required BuildContext context,
  }) async {
    try {
      final racerId = await _racerService.createRacer(
        userId: userId,
        name: name,
        teamName: teamName,
        vehicleModel: vehicleModel,
        contactNumber: contactNumber,
        vehicleNumber: vehicleNumber,
        currentEvent: currentEvent,

        context: context,
      );
      return racerId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update an existing racer
  Future<bool> updateRacer(String userId, Racer racer) async {
    try {
      await _racerService.updateRacer(userId, racer);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete a racer
  Future<bool> deleteRacer(String userId, String racerId) async {
    try {
      await _racerService.deleteRacer(userId, racerId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update racer image
  Future<bool> updateRacerImage(
    String userId,
    String racerId,
    File imageFile,
    bool isProfileImage,
    BuildContext context,
  ) async {
    try {
      await _racerService.updateRacerImage(
        userId,
        racerId,
        imageFile,
        isProfileImage,
        context,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete racer image
  Future<bool> deleteRacerImage(
    String userId,
    String racerId,
    bool isProfileImage,
  ) async {
    try {
      await _racerService.deleteRacerImage(userId, racerId, isProfileImage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
