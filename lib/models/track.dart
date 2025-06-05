class Track {
  int trackNumber;
  String trackName;
  String imagePath;

  Track({
    required this.trackNumber,
    required this.trackName,
    required this.imagePath,
  });

  // Factory constructor for creating a Track object from a map
  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      trackNumber: map['trackNumber'] ?? 0,
      trackName: map['trackName'] ?? '',
      imagePath: map['imagePath'] ?? '',
    );
  }

  // Method to convert a Track object to a map
  Map<String, dynamic> toMap() {
    return {
      'trackNumber': trackNumber,
      'trackName': trackName,
      'imagePath': imagePath,
    };
  }
}
