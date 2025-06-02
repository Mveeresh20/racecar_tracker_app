import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/event.dart';
// Import your Event model

class UpcomingEventsContent extends StatelessWidget {
  final Event event;

  const UpcomingEventsContent({Key? key, required this.event})
    : super(key: key);

  Widget _buildEventDetailRow(
    IconData icon,
    String text,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: context.titleSmall?.copyWith(color: Colors.white),
          ), // Use theme text style
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          event.type,
          style: context.bodyMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        _buildEventDetailRow(
          Icons.calendar_today,
          DateFormat('MMM dd, yyyy hh:mm a - hh:mm a').format(event.startDate),
          context,
        ),
        _buildEventDetailRow(Icons.location_on, event.location, context),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              "Racers:",
              style: context.labelLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 8),
            if (event.racerImageUrls != null &&
                event.racerImageUrls!.isNotEmpty)
              ...event.racerImageUrls!.map(
                (url) => Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(url),
                    radius: 12,
                  ),
                ),
              ),
            if (event.totalRacers > (event.racerImageUrls?.length ?? 0))
              Text(
                "+${event.totalRacers - (event.racerImageUrls?.length ?? 0)}",
                style: context.bodySmall?.copyWith(color: Colors.white),
              ),
          ],
        ),
      ],
    );
  }
}
