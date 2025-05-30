import 'package:firebase_database/firebase_database.dart';
import 'package:racecar_tracker/Services/base_service.dart';
import 'package:racecar_tracker/models/event.dart';

class EventService extends BaseService {
  // Create a new event
  Future<String> createEvent({
    required String title,
    required String raceType,
    required String trackName,
    required int maxRacers,
    required DateTime dateTime,
    required String location,
    required String type,
    List<String>? racerImageUrls,
  }) async {
    try {
      // Create event data
      final eventData = {
        'title': title,
        'raceType': raceType,
        'trackName': trackName,
        'maxRacers': maxRacers,
        'currentRacers': 0,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'location': location,
        'type': type,
        'racerImageUrls': racerImageUrls ?? [],
        'status': EventStatusType.registrationOpen.toString(),
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };

      return await create(eventsRef, eventData);
    } catch (e) {
      rethrow;
    }
  }

  // Update event
  Future<void> updateEvent(
    String id, {
    String? title,
    String? raceType,
    String? trackName,
    int? maxRacers,
    DateTime? dateTime,
    String? location,
    String? type,
    List<String>? racerImageUrls,
    EventStatusType? status,
  }) async {
    try {
      final event = await getById<Event>(eventsRef, id, _fromMap);
      if (event == null) throw Exception('Event not found');

      final updates = <String, dynamic>{};

      // Update basic info
      if (title != null) updates['title'] = title;
      if (raceType != null) updates['raceType'] = raceType;
      if (trackName != null) updates['trackName'] = trackName;
      if (maxRacers != null) {
        updates['maxRacers'] = maxRacers;
        // If max racers is less than current racers, update status
        if (maxRacers <= event.currentRacers) {
          updates['status'] = EventStatusType.registrationClosed.toString();
        }
      }
      if (dateTime != null)
        updates['dateTime'] = dateTime.millisecondsSinceEpoch;
      if (location != null) updates['location'] = location;
      if (type != null) updates['type'] = type;
      if (racerImageUrls != null) updates['racerImageUrls'] = racerImageUrls;
      if (status != null) updates['status'] = status.toString();

      updates['updatedAt'] = ServerValue.timestamp;
      await update(eventsRef, id, updates);
    } catch (e) {
      rethrow;
    }
  }

  // Delete event
  Future<void> deleteEvent(String id) async {
    try {
      await delete(eventsRef, id);
    } catch (e) {
      rethrow;
    }
  }

  // Get event by ID
  Future<Event?> getEvent(String id) async {
    return await getById<Event>(eventsRef, id, _fromMap);
  }

  // Stream all events
  Stream<List<Event>> streamEvents() {
    return streamList<Event>(eventsRef, _fromMap);
  }

  // Stream upcoming events
  Stream<List<Event>> streamUpcomingEvents() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return eventsRef.orderByChild('dateTime').startAt(now).onValue.map((event) {
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
      if (newCount >= event.maxRacers) {
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
      id: map['id'] as String,
      title: map['title'] as String,
      raceName: map['raceName'] as String,
      raceType: map['raceType'] as String,
      trackName: map['trackName'] as String,
      currentRacers: map['currentRacers'] as int,
      maxRacers: map['maxRacers'] as int,
      status: EventStatusType.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => EventStatusType.registrationOpen,
      ),
      type: map['type'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      location: map['location'] as String,
      racerImageUrls: List<String>.from(map['racerImageUrls'] as List? ?? []),
      totalOtherRacers:
          (map['currentRacers'] as int) -
          (map['racerImageUrls'] as List? ?? []).length,
    );
  }
}
