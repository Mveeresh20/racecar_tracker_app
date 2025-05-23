import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/event.dart';
// Import your Event model

class UpcomingEventsContent extends StatelessWidget {
  final Event event; 

  const UpcomingEventsContent({Key? key, required this.event}) : super(key: key);

  Widget _buildEventDetailRow(IconData icon, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Text(text, style: context.titleSmall?.copyWith(color: Colors.white)), // Use theme text style
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(event.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(event.type, style: context.bodyMedium?.copyWith(color: Colors.white)), // Use theme text style
        const SizedBox(height: 8),
        _buildEventDetailRow(Icons.calendar_today, DateFormat('MMM dd, yyyy hh:mm a - hh:mm a').format(event.dateTime), context),
        _buildEventDetailRow(Icons.location_on, event.location, context),
        const SizedBox(height: 8),
       
        Row(
          children: [
             Text("Racers:", style: context.labelLarge?.copyWith(color: Colors.white)), // Use theme text style
        const SizedBox(width: 8),
            
            ...event.racerImageUrls.take(3).map((url) =>
              Padding(
                padding: const EdgeInsets.only(right: 4.0), // 
                child: CircleAvatar(
                  backgroundImage: NetworkImage(url),
                  radius: 12,
                ),
              )
            ).toList(),
            if (event.totalOtherRacers > 0)
              Text(
                "+${event.totalOtherRacers}",
                style: context.bodySmall?.copyWith(color: Colors.white), // Use theme text style
              ),
          ],
        ),
      ],
    );
  }
}