import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/Constants/ui.dart';

class SignInButton extends StatelessWidget {
   final String text;
  final IconData icon;
  final bool iconFirst;
 
  const SignInButton({super.key, required this.text, required this.icon, this.iconFirst = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: UI.borderRadius60,

        color: Colors.white
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: iconFirst?[
             Icon(icon, size: 16, color: Colors.black),
             SizedBox(width: 8),
             Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: "Plus Jakarta Sans",
              ),
            ),
          ]:[
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: "Plus Jakarta Sans",
              ),
            ),
            SizedBox(width: 8),
            Icon(icon, size: 22, color: Colors.black,),
            
          ] 
        ),
      ),
    );
  }
}