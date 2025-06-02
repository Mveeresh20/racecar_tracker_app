import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:racecar_tracker/Services/sponsor_service.dart';
import 'package:racecar_tracker/Services/user_service.dart';

class SponsorProvider with ChangeNotifier {
  final SponsorService _sponsorService = SponsorService();
  List<Sponsor> _sponsors = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _sponsorsSubscription;
  String? _currentUserId;

  // Getters
  List<Sponsor> get sponsors => _sponsors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _currentUserId;

  // Initialize user's sponsors
  Future<void> initUserSponsors(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cancel any existing subscription
      await _sponsorsSubscription?.cancel();

      // Clear existing data
      _sponsors = [];

      // Set up new subscription
      _sponsorsSubscription = _sponsorService
          .getSponsorsStream(userId)
          .listen(
            (sponsors) {
              _sponsors = sponsors;
              _isLoading = false;
              _error = null;
              notifyListeners();
            },
            onError: (error) {
              _error = error.toString();
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new sponsor
  Future<void> createSponsor(Sponsor sponsor) async {
    final userId = UserService().getCurrentUserId();
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      await _sponsorService.createSponsor(userId, sponsor);
      // The stream will automatically update the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update an existing sponsor
  Future<void> updateSponsor(Sponsor sponsor) async {
    final userId = UserService().getCurrentUserId();
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      await _sponsorService.updateSponsor(userId, sponsor);
      // The stream will automatically update the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete a sponsor
  Future<void> deleteSponsor(String sponsorId) async {
    final userId = UserService().getCurrentUserId();
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      await _sponsorService.deleteSponsor(userId, sponsorId);
      // The stream will automatically update the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear data and cancel subscription
  Future<void> logout() async {
    await _sponsorsSubscription?.cancel();
    _sponsorsSubscription = null;
    _sponsors = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  @override
  void dispose() {
    _sponsorsSubscription?.cancel();
    super.dispose();
  }
}
 