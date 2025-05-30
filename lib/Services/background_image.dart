

class BackgroundImage {
  String? imageBackground;
  BackgroundImage(this.imageBackground);

  BackgroundImage.fromMap(Map<String, dynamic> map) {
    imageBackground = map['imageBackground'];
  }

  Map<String, dynamic> toMap() {
    return {
      
      'imageBackground': imageBackground,
    };
  }
}


