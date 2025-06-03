import 'package:firebase_database/firebase_database.dart';
import 'package:racecar_tracker/Services/base_service.dart';
import 'package:racecar_tracker/models/event.dart';

class EventService extends BaseService {
  // Get user-specific events reference
  DatabaseReference getUserEventsRef(String userId) {
    return database.ref().child('478_users/$userId/events');
  }

  // Create new event
  Future<void> createEvent(String userId, Event event) async {
    final eventRef = getUserEventsRef(userId).push();
    await eventRef.set(event.toMap());
  }

  // Fetch user's events
  Stream<List<Event>> getUserEvents(String userId) {
    return getUserEventsRef(userId).onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final Map<dynamic, dynamic> data = event.snapshot.value as Map;
      return data.entries.map((entry) {
        final Map<String, dynamic> eventData = Map<String, dynamic>.from(
          entry.value,
        );
        eventData['id'] = entry.key;
        return Event.fromMap(eventData);
      }).toList();
    });
  }

  // Fetch all events
  Stream<List<Event>> getEvents() {
    return eventsRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final Map<dynamic, dynamic> data = event.snapshot.value as Map;
      return data.entries.map((entry) {
        final Map<String, dynamic> eventData = Map<String, dynamic>.from(
          entry.value,
        );
        eventData['id'] = entry.key;
        return Event.fromMap(eventData);
      }).toList();
    });
  }

  // Update event
  Future<void> updateEvent(String userId, Event event) async {
    if (event.id.isEmpty) {
      throw Exception('Event ID is required for update');
    }
    await getUserEventsRef(userId).child(event.id).update(event.toMap());
  }

  // Delete event
  Future<void> deleteEvent(String userId, String eventId) async {
    await getUserEventsRef(userId).child(eventId).remove();
  }

  // Get event by ID
  Future<Event?> getEvent(String userId, String id) async {
    try {
      final snapshot = await getUserEventsRef(userId).child(id).get();
      if (!snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data['id'] = snapshot.key; // Add the key as the event ID
      return Event.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  // Stream all events
  Stream<List<Event>> streamEvents() {
    return streamList<Event>(eventsRef, _fromMap);
  }

  // Stream upcoming events
  Stream<List<Event>> streamUpcomingEvents(String userId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return getUserEventsRef(userId)
        .orderByChild('endDate')
        .startAt(now) // Show events that haven't ended yet
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return <Event>[];

          return data.entries.map((entry) {
            final map = Map<String, dynamic>.from(entry.value as Map);
            map['id'] = entry.key;
            return _fromMap(map);
          }).toList();
        });
  }

  // Stream events by status
  Stream<List<Event>> streamEventsByStatus(EventStatusType status) {
    return eventsRef
        .orderByChild('status')
        .equalTo(status.toString())
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return <Event>[];

          return data.entries.map((entry) {
            final map = Map<String, dynamic>.from(entry.value as Map);
            map['id'] = entry.key;
            return _fromMap(map);
          }).toList();
        });
  }

  // Update event registration status
  Future<void> updateEventRegistration(String id, bool isOpen) async {
    try {
      final event = await getById<Event>(eventsRef, id, _fromMap);
      if (event == null) throw Exception('Event not found');

      final status =
          isOpen
              ? EventStatusType.registrationOpen
              : EventStatusType.registrationClosed;

      await update(eventsRef, id, {
        'status': status.toString(),
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update current racers count
  Future<void> updateCurrentRacers(String id, int increment) async {
    try {
      final event = await getById<Event>(eventsRef, id, _fromMap);
      if (event == null) throw Exception('Event not found');

      final newCount = event.currentRacers + increment;
      if (newCount < 0) throw Exception('Cannot have negative racers');
      if (newCount > event.maxRacers) throw Exception('Exceeds maximum racers');

      final updates = {
        'currentRacers': newCount,
        'updatedAt': ServerValue.timestamp,
      };

      // Update status if needed
      if (newCount >= event.totalRacers) {
        updates['status'] = EventStatusType.registrationClosed.toString();
      } else if (event.status == EventStatusType.registrationClosed) {
        updates['status'] = EventStatusType.registrationOpen.toString();
      }

      await update(eventsRef, id, updates);
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to convert Map to Event object
  Event _fromMap(Map<String, dynamic> map) {
    return Event(
      status: EventStatusType.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            map['status']?.toString().split('.').last,
        orElse: () => EventStatusType.upcoming,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      userId: map['userId'] as String,
      id: map['id'] as String,
      name: map['name'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int),
      description: map['description'] as String,
      totalRacers: map['totalRacers'] as int,
      totalSponsors: map['totalSponsors'] as int,
      type: map['type'] as String,
      location: map['location'] as String,
      totalPrizeMoney:
          (map['totalPrizeMoney'] is int)
              ? (map['totalPrizeMoney'] as int).toDouble()
              : (map['totalPrizeMoney'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
