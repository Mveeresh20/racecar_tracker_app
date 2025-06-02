import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:racecar_tracker/Presentation/Pages/sponser_detail_screen.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/sponsor.dart'; // Import the Sponsor model
import 'package:cached_network_image/cached_network_image.dart';

class SponsorCardItem extends StatelessWidget {
  final Sponsor sponsor;
  final List<DealItem> Function(String sponsorName) getDealItemsForSponsor;

  const SponsorCardItem({
    Key? key,
    required this.sponsor,
    required this.getDealItemsForSponsor,
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
              // Top Row: Initials, Name, Email
              Row(
                children: [
                  // Initials Circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF252D38),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      sponsor.initials,
                      style: const TextStyle(
                        color: Color(0xFFFFCC29),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sponsor.name,
                        style: const TextStyle(
                          color: Color(0xFFA8E266),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        sponsor.email,
                        style: context.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 7),

              // Parts/Categories
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children:
                    sponsor.parts.map((part) => _buildPartChip(part)).toList(),
              ),
              const SizedBox(height: 12),

              // Active Deals and End Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Active Deals: ${sponsor.activeDeals}",
                    style: context.titleSmall?.copyWith(color: Colors.white),
                  ),
                  Text(
                    "Ends: ${DateFormat('dd/MM/yyyy').format(sponsor.endDate)}",
                    style: context.bodySmall?.copyWith(color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sponsor.statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sponsor.statusText,
                      style: context.labelLarge?.copyWith(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Row(
                    children: [
                      // Action Icons
                      _buildActionButton(Icons.remove_red_eye_outlined, () {
                        final dealsForThisSponsor = getDealItemsForSponsor(
                          sponsor.name,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SponsorDetailScreen(
                                  sponsor: sponsor,
                                  sponsorDealItems: dealsForThisSponsor,
                                ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(Icons.sync, () {
                        // Handle Sync/Renew action
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(Icons.edit, () {
                        // Handle Edit action
                      }),
                    ],
                  ),
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
        color: const Color(0xFF1B2953),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B6AD2), Color(0xFF211E83)],
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
