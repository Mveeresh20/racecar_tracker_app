import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';

class BuildActionCard extends StatelessWidget {
  const BuildActionCard({
    super.key,
    required this.imageUrl,
    required this.text,
    required this.onTap,
  });
  final String imageUrl;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 60,

              decoration: BoxDecoration(
                color: Color(0xFF13386B),
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: Color(0xFFFFCC29)),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.network(imageUrl),
                ),
              ),
            ),
            Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
