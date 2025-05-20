import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/Constants/ui.dart';

class TotalTrackCards extends StatelessWidget {
  final String imageurl;
  final String text;
  final String total;
  final Color cardColor;
  final Color imgColor;
  const TotalTrackCards({
    super.key,
    required this.imageurl,
    required this.text,
    required this.total,
    required this.cardColor,
    required this.imgColor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: UI.borderRadius10,
          color: cardColor
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Container(
                decoration: BoxDecoration(color: imgColor),
        
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  child: Image.network(imageurl),
                ),
              ),
            ),
        
            SizedBox(height: 15),
        
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Montserrat",
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Text(
                total,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Plus Jakarta Sans",
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
