import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/deal_detail_screen.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/deal_detail_item.dart';
import 'package:racecar_tracker/models/deal_item.dart'; // Import the new DealItem model

class DealCardItem extends StatelessWidget {
  final DealItem deal;
  final Future<DealDetailItem?> Function(String) fetchDealDetail;

  const DealCardItem({
    Key? key,
    required this.deal,
    required this.fetchDealDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          color: const Color(0xFF13386B),
        ),

        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Deal Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deal.title,
                      style: TextStyle(
                        color: Color(0xFFA8E266),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle long titles
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: deal.statusColor, // Dynamic status color
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      deal.statusText, // Dynamic status text
                      style: context.labelMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Race Type
              Text(
                deal.raceType,
                style: context.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),

              // Deal Value, Commission, Renewal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Deal Value",
                        style: context.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        deal.dealValue,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Commission",
                        style: context.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        deal.commission,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Renewal",
                    style: context.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    deal.renewalDate,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Parts/Categories
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children:
                    deal.parts.map((part) => _buildPartChip(part)).toList(),
              ),
              const SizedBox(height: 12),

              // Action Buttons (View Deal, Log Payment, Edit)
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround, // Distribute buttons
                children: [
                  _buildActionButton(
                    context,
                    "View Deal",
                    Icons.remove_red_eye_outlined,
                    () {
                      // Handle View Deal action
                    },
                  ),
                  _buildActionButton(
                    context,
                    "Log Payment",
                    Icons.remove_red_eye_outlined,
                    () {
                      // Handle Log Payment action
                    },
                  ),
                  _buildActionButton(context, "", Icons.edit, () {
                    // Edit button has no text
                    // Handle Edit action
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartChip(String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xFF1B2953),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (label == "View Deal") {
          try {
            final detail = await fetchDealDetail(deal.id);
            if (!context.mounted) return;

            if (detail != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          DealDetailScreen(deal: detail, dealItem: deal),
                ),
              );
            } else {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No deal detail found.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading deal detail: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          onPressed();
        }
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF27518A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
