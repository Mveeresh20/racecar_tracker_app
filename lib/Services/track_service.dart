import 'package:firebase_database/firebase_database.dart';
import 'package:racecar_tracker/models/track.dart';
import 'package:racecar_tracker/Services/user_service.dart';

class TrackService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref(
    '478_users',
  );
  final UserService _userService = UserService();

  Future<void> saveTrack(Track track) async {
    String? userId = _userService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not authenticated');
    }

    final userTracksRef = _databaseRef.child(userId).child('tracks');
    // Use push() to generate a unique key for each track
    final newTrackRef = userTracksRef.push();

    await newTrackRef.set(track.toMap());
  }

  // Fetch all tracks for the current user
  Future<List<Track>> fetchTracks() async {
    String? userId = _userService.getCurrentUserId();
    if (userId == null) {
      // Return an empty list if the user is not authenticated
      return [];
    }

    final userTracksRef = _databaseRef.child(userId).child('tracks');
    final snapshot = await userTracksRef.get();

    if (snapshot.exists) {
      final Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Track> tracks = [];
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
             // Ensure map is of the correct type before passing to fromMap
            tracks.add(Track.fromMap(Map<String, dynamic>.from(value)));
          }
        });
        return tracks;
      }
    }
    // Return an empty list if no tracks are found or data is in an unexpected format
    return [];
  }
}
