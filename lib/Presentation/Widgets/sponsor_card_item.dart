import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:racecar_tracker/Presentation/Pages/sponser_detail_screen.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/sponsor.dart'; // Import the Sponsor model
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Services/sponsor_provider.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_sponsor_screen.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';

class SponsorCardItem extends StatelessWidget {
  final Sponsor sponsor;
  final Stream<List<DealItem>> Function(String sponsorName)
  getDealItemsForSponsor;

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
                  // Logo or Initials Circle
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
                    child:
                        sponsor.logoUrl != null && sponsor.logoUrl!.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: ImagePickerUtil()
                                    .getUrlForUserUploadedImage(
                                      sponsor.logoUrl!,
                                    ),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFFFFCC29),
                                            ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Text(
                                      sponsor.initials,
                                      style: const TextStyle(
                                        color: Color(0xFFFFCC29),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                              ),
                            )
                            : Text(
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
                        // Get the stream of deals for this sponsor
                        final dealsStream = getDealItemsForSponsor(
                          sponsor.name,
                        );

                        // Navigate to detail screen with a StreamBuilder
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StreamBuilder<List<DealItem>>(
                                  stream: dealsStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      print(
                                        'Error fetching deals: ${snapshot.error}',
                                      );
                                      return SponsorDetailScreen(
                                        sponsor: sponsor,
                                        sponsorDealItems: [],
                                      );
                                    }

                                    final deals = snapshot.data ?? [];
                                    final mostRecentDeal =
                                        deals.isNotEmpty ? deals.first : null;

                                    return SponsorDetailScreen(
                                      sponsor: sponsor,
                                      sponsorDealItems: deals,
                                      dealItem: mostRecentDeal,
                                    );
                                  },
                                ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(Icons.sync, () {
                        // Handle Sync/Renew action
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(Icons.edit, () async {
                        // Navigate to AddNewSponsorScreen with existing sponsor data
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AddNewSponsorScreen(
                                  provider: Provider.of<SponsorProvider>(
                                    context,
                                    listen: false,
                                  ),
                                  existingSponsor: sponsor,
                                ),
                          ),
                        );

                        // Refresh sponsors after returning if needed
                        if (result != null) {
                          final userId = UserService().getCurrentUserId();
                          if (userId != null) {
                            Provider.of<SponsorProvider>(
                              context,
                              listen: false,
                            ).initUserSponsors(userId);
                          }
                        }
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
