import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/Constants/ui.dart';

class OnboardingNextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
 
  const OnboardingNextButton({
    super.key,
    required this.text,
    required this.icon,
     this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: UI.borderRadius40,

        color: Color(0xFFFFCC29)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: "Montserrat",
              ),
            ),
            SizedBox(width: 8),
            Icon(icon, size: 16, color: Colors.black),
            
          ],
        ),
      ),
    );
  }
}
