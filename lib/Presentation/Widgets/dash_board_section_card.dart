import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/text.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';

class DashboardSectionCard extends StatelessWidget {
  final String? title;
  final String? imagurl;
  final Widget innerContent;
  final VoidCallback? onGoToPressed;
  final String? buttonText;
  final Color? cardColor;

  const DashboardSectionCard({
    Key? key,
    this.title,
    this.imagurl,
    required this.innerContent,
    this.onGoToPressed,
    this.buttonText,
    this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor ?? Color(0xFF0F2A55),

      margin: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 8,
      ),

      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && imagurl != null) ...[
              Row(
                children: [
                  Image.network(imagurl!, height: 20, width: 20),
                  const SizedBox(width: 8),
                  Text(
                    title!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: "Montserrat",
                    ), // Use theme text style
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],

            SizedBox(height: 12),
            innerContent,

            if (onGoToPressed != null && buttonText != null) ...[
              const SizedBox(height: 12),

              // 👉 Informational Text - Not a button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "🗓️ No Upcoming Race Events",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    Lorempsum.noNewRaceEvent,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 👉 Action Button (only for navigation or actions)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onGoToPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kButtonColor,
                    foregroundColor: kButtonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        buttonText!,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          fontFamily: "Montserrat",
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.play_arrow, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
