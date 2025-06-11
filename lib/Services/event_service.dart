import 'dart:convert';
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

      final data = event.snapshot.value;
      if (data is Map) {
        return data.entries
            .map((entry) {
              try {
                Map<String, dynamic> eventData;

                if (entry.value is Map) {
                  eventData = Map<String, dynamic>.from(entry.value as Map);
                } else if (entry.value is String) {
                  try {
                    final jsonMap =
                        jsonDecode(entry.value as String)
                            as Map<String, dynamic>;
                    eventData = Map<String, dynamic>.from(jsonMap);
                  } catch (parseError) {
                    print('Error parsing event string: $parseError');
                    return null;
                  }
                } else {
                  print(
                    'Warning: Event data is not a map or string: ${entry.value}',
                  );
                  return null;
                }

                eventData['id'] = entry.key;
                return Event.fromMap(eventData);
              } catch (e) {
                print('Error processing event entry: $e');
                return null;
              }
            })
            .whereType<Event>()
            .toList();
      } else {
        print('Unexpected event data type: ${data.runtimeType}');
        return <Event>[];
      }
    });
  }

  // Fetch all events
  Stream<List<Event>> getEvents() {
    return eventsRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final data = event.snapshot.value;
      if (data is Map) {
        return data.entries
            .map((entry) {
              try {
                Map<String, dynamic> eventData;

                if (entry.value is Map) {
                  eventData = Map<String, dynamic>.from(entry.value as Map);
                } else if (entry.value is String) {
                  try {
                    final jsonMap =
                        jsonDecode(entry.value as String)
                            as Map<String, dynamic>;
                    eventData = Map<String, dynamic>.from(jsonMap);
                  } catch (parseError) {
                    print('Error parsing event string: $parseError');
                    return null;
                  }
                } else {
                  print(
                    'Warning: Event data is not a map or string: ${entry.value}',
                  );
                  return null;
                }

                eventData['id'] = entry.key;
                return Event.fromMap(eventData);
              } catch (e) {
                print('Error processing event entry: $e');
                return null;
              }
            })
            .whereType<Event>()
            .toList();
      } else {
        print('Unexpected event data type: ${data.runtimeType}');
        return <Event>[];
      }
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
          final data = event.snapshot.value;
          if (data == null) return <Event>[];

          try {
            if (data is Map) {
              return data.entries
                  .map((entry) {
                    try {
                      Map<String, dynamic> eventMap;

                      if (entry.value is Map) {
                        eventMap = Map<String, dynamic>.from(
                          entry.value as Map,
                        );
                      } else if (entry.value is String) {
                        try {
                          final jsonMap =
                              jsonDecode(entry.value as String)
                                  as Map<String, dynamic>;
                          eventMap = Map<String, dynamic>.from(jsonMap);
                        } catch (parseError) {
                          print(
                            'Error parsing upcoming event string: $parseError',
                          );
                          return null;
                        }
                      } else {
                        print(
                          'Warning: Upcoming event data is not a map or string: ${entry.value}',
                        );
                        return null;
                      }

                      eventMap['id'] = entry.key;
                      return _fromMap(eventMap);
                    } catch (e) {
                      print('Error processing upcoming event entry: $e');
                      return null;
                    }
                  })
                  .whereType<Event>()
                  .toList();
            } else {
              print(
                'Unexpected upcoming events data type: ${data.runtimeType}',
              );
              return <Event>[];
            }
          } catch (e) {
            print('Error in streamUpcomingEvents: $e');
            return <Event>[];
          }
        });
  }

  // Stream events by status
  Stream<List<Event>> streamEventsByStatus(EventStatusType status) {
    return eventsRef.orderByChild('status').equalTo(status.toString()).onValue.map((
      event,
    ) {
      final data = event.snapshot.value;
      if (data == null) return <Event>[];

      try {
        if (data is Map) {
          return data.entries
              .map((entry) {
                try {
                  Map<String, dynamic> eventMap;

                  if (entry.value is Map) {
                    eventMap = Map<String, dynamic>.from(entry.value as Map);
                  } else if (entry.value is String) {
                    try {
                      final jsonMap =
                          jsonDecode(entry.value as String)
                              as Map<String, dynamic>;
                      eventMap = Map<String, dynamic>.from(jsonMap);
                    } catch (parseError) {
                      print('Error parsing status event string: $parseError');
                      return null;
                    }
                  } else {
                    print(
                      'Warning: Status event data is not a map or string: ${entry.value}',
                    );
                    return null;
                  }

                  eventMap['id'] = entry.key;
                  return _fromMap(eventMap);
                } catch (e) {
                  print('Error processing status event entry: $e');
                  return null;
                }
              })
              .whereType<Event>()
              .toList();
        } else {
          print('Unexpected status events data type: ${data.runtimeType}');
          return <Event>[];
        }
      } catch (e) {
        print('Error in streamEventsByStatus: $e');
        return <Event>[];
      }
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
