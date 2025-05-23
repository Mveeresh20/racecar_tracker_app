import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/commission_detail.dart';
 

class CommissionSummaryContent extends StatelessWidget {
  final List<CommissionDetail> details;

  const CommissionSummaryContent({Key? key, required this.details}) : super(key: key);

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.titleSmall?.copyWith(color: Colors.white)), // Use
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((detail) => _buildInfoRow(detail.label, detail.value, context)).toList(),
    );
  }
}