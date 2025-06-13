class Track {
  int trackNumber;
  String trackName;
  String imagePath;

  Track({
    required this.trackNumber,
    required this.trackName,
    required this.imagePath,
  });

 
  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      trackNumber: map['trackNumber'] ?? 0,
      trackName: map['trackName'] ?? '',
      imagePath: map['imagePath'] ?? '',
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'trackNumber': trackNumber,
      'trackName': trackName,
      'imagePath': imagePath,
    };
  }
}
