import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:racecar_tracker/Services/event_service.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/Services/user_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _eventsSubscription;
  String? _currentUserId;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _cleanupSubscription();
    super.dispose();
  }

  void _cleanupSubscription() {
    _eventsSubscription?.cancel();
    _eventsSubscription = null;
    _events = [];
    _currentUserId = null;
    _error = null;
    notifyListeners();
  }

  Future<void> initUserEvents(String userId) async {
    // If we're already listening to this user's events, don't reinitialize
    if (_currentUserId == userId && _eventsSubscription != null) {
      return;
    }

    // Clean up existing subscription and data
    _cleanupSubscription();

    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    try {
      // Create new subscription
      _eventsSubscription = _eventService
          .getUserEventsRef(userId)
          .onValue
          .listen(
            (event) {
              if (event.snapshot.value != null) {
                final Map<dynamic, dynamic> data =
                    event.snapshot.value as Map<dynamic, dynamic>;
                _events =
                    data.entries.map((entry) {
                      final eventData = Map<String, dynamic>.from(
                        entry.value as Map,
                      );
                      eventData['id'] = entry.key;
                      return Event.fromMap(eventData);
                    }).toList();
              } else {
                _events = [];
              }
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

  Future<void> createEvent(String userId, Event event) async {
    if (_currentUserId != userId) {
      throw Exception(
        'User ID mismatch. Please reinitialize events for the current user.',
      );
    }

    try {
      await _eventService.createEvent(userId, event);
      // The events list will be updated automatically through the stream
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEvent(String userId, Event event) async {
    if (_currentUserId != userId) {
      throw Exception(
        'User ID mismatch. Please reinitialize events for the current user.',
      );
    }

    try {
      await _eventService.updateEvent(userId, event);
      // The events list will be updated automatically through the stream
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEvent(String userId, String eventId) async {
    if (_currentUserId != userId) {
      throw Exception(
        'User ID mismatch. Please reinitialize events for the current user.',
      );
    }

    try {
      await _eventService.deleteEvent(userId, eventId);
      // The events list will be updated automatically through the stream
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Call this when user logs out
  void logout() {
    _cleanupSubscription();
  }
}
