import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/deal.dart';
 // Import your Deal model

class PendingDealsContent extends StatelessWidget {
  final List<Deal> deals;

  const PendingDealsContent({Key? key, required this.deals}) : super(key: key);

  Widget _buildDealRow(Deal deal, BuildContext context) {
    String statusText;
    Color statusColor;
    if (deal.expiryDate.isBefore(DateTime.now())) {
      statusText = "Expired: ${DateFormat('MMM dd').format(deal.expiryDate)}";
      
    } else {
      statusText = "Expiring: ${DateFormat('MMM dd').format(deal.expiryDate)}";
     
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${deal.name} \u2192 ${deal.client}",
            style: context.titleSmall?.copyWith(color: Colors.white),
          ),
          
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white), // Use theme text style and override color
          ),
         
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) {
      return Center(
        child: Text("No pending or expired deals.", style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    return Column(
      children: deals.map((deal) => _buildDealRow(deal, context)).toList(),
    );
  }
}