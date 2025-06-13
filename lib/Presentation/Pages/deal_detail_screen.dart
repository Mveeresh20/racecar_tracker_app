import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/deal_detail_item.dart'; // Import the specific detail model
// Import shared enum extension
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/models/deal_item.dart'; // Assuming this exists for back button
import 'package:racecar_tracker/Services/image_picker_util.dart';

class DealDetailScreen extends StatelessWidget {
  final DealDetailItem deal;
  final DealItem dealItem;
  final _imagePicker = ImagePickerUtil();

  DealDetailScreen({required this.dealItem, Key? key, required this.deal})
    : super(key: key);

  // Helper widget to build the "Branding" chips (Assigned Branding Locations)
  Widget _buildBrandingChip(String text, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF27518A), // Dark blue chip background
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          text,
          style: context.labelMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                  ).copyWith(top: 64, bottom: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2D5586), Color(0xFF171E45)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 16),
                          Text(
                            "Deal Detail",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      // Space before bottom border
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Initials/Logos for Sponsor and Racer with handshake
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(
                          0xFF252D38,
                        ), // Dark background for initials
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Text(
                          deal.sponsorInitials, // Dynamic Sponsor Initials
                          style: const TextStyle(
                            color: Color(0xFFFFCC29),
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    Image.network(
                      Images.totalDealsCrackedImg,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),

                    const SizedBox(width: 8),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(
                          0xFF252D38,
                        ), // Dark background for initials
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Text(
                          deal.racerInitials, // Dynamic Racer Initials
                          style: const TextStyle(
                            color: Color(0xFFFFCC29),
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  deal.title, // Dynamic Deal Title
                  style: context.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  deal.raceType, // Dynamic Race Type/Event
                  style: context.titleMedium?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // --- Deal Terms & Commission Section ---
            _buildSectionHeader("Deal Terms & Commission", context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                children: [
                  _buildInfoRow(
                    "Total Deal Amount:",
                    dealItem.dealValue,
                    context,
                  ),
                  _buildInfoRow(
                    "Your Commission:",
                    dealItem.commission,
                    context,
                  ),
                  _buildInfoRow("Your Earn:", deal.yourEarn, context),
                  _buildInfoRow(
                    "Payment Status:",
                    dealItem.statusText,
                    context,
                    valueColor: dealItem.statusColor,
                  ), // Use extension for text and color
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 1,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Branding Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Text(
                "Branding",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Assigned Branding locations:",
                    style: context.labelLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        deal.parts
                            .map((part) => _buildBrandingChip(part, context))
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Branding images:",
                    style: context.labelLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: deal.brandingImageUrls.length,
                      itemBuilder: (context, index) {
                        final imagePath = deal.brandingImageUrls[index];
                        final imageUrl = _imagePicker
                            .getUrlForUserUploadedImage(imagePath);
                        print(
                          'Loading branding image at index $index: $imageUrl',
                        );
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading branding image: $error');
                                print('Image URL: $imageUrl');
                                return Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 1,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    "Deal Duration & Renewal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                children: [
                  _buildInfoRow(
                    "Start Date:",
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(deal.startDate), // Dynamic Start Date
                    context,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    "End Date:",
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(deal.endDate), // Dynamic End Date
                    context,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    "Renewal Reminder:",
                    deal.renewalReminder,
                    context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 20,
      ),
      child: Row(
        children: [
          Text(
            '\$',

            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(width: 8),
          Text(
            title,

            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for general info rows (Label: Value)
  Widget _buildInfoRow(
    String label,
    String value,
    BuildContext context, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(label, style: context.labelLarge?.copyWith(color: Colors.white)),
        SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color:
                valueColor ??
                Colors.white, 
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
