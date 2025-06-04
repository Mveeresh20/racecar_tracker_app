import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Widgets/dash_board_section_card.dart';
import 'package:racecar_tracker/Presentation/Widgets/upcomming_events_content.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/Constants/text.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/event.dart';

class UpcomingEventsSection extends StatelessWidget {
  final List<Event> events;
  final VoidCallback onGoToEventsPressed; // Callback for the single button

  const UpcomingEventsSection({
    Key? key,
    required this.events,
    required this.onGoToEventsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xFF0F2A55),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The main section heading
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: 8.0,
            ),
            child: Row(
              // Row to include icon next to heading
              children: [
                Image.network(
                  Images.upcommingEventsImg,
                  height: 20,
                  width: 20,
                ), // Icon from your screenshot
                const SizedBox(width: 8),
                Text(
                  "Upcoming Events",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: "Montserrat",
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
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
          ),

          
          SizedBox(
            height: 200,
            child:
                events.isEmpty
                    ? Center(
                      child: Column(
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
                          ),
                          const SizedBox(height: 6),
                          Text(
                            Lorempsum.upCommingEvents,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w500
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          // Spacing between cards
                          child: DashboardSectionCard(
                            cardColor: Color(0xFF13386B),
                            innerContent: UpcomingEventsContent(event: event),
                          ),
                        );
                      },
                    ),
          ),
          
          // The single "Go to Events" button below the horizontal list
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: 8.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onGoToEventsPressed,
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
                  children: [
                    Text(
                      "Go to Events",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: "Montserrat",
                      ),
                    ), // The text for the single button
                    const SizedBox(width: 8),
                    const Icon(Icons.play_arrow, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
