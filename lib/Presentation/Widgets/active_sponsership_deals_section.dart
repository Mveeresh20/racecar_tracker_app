import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Widgets/dash_board_section_card.dart'; // Ensure correct import
import 'package:racecar_tracker/Presentation/Widgets/active_sponsorship_deals_content.dart'; // Ensure correct import
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // Ensure correct import
import 'package:racecar_tracker/Utils/Constants/images.dart'; // Ensure correct import for image asset
import 'package:racecar_tracker/Utils/Constants/text.dart';
import 'package:racecar_tracker/models/deal_item.dart'; // Ensure correct import

class ActiveSponsorshipDealsSection extends StatelessWidget {
  final List<DealItem> deals;
  final VoidCallback onGoToDealsPressed; // Callback for the single button

  const ActiveSponsorshipDealsSection({
    Key? key,
    required this.deals,
    required this.onGoToDealsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(
          0xFF0F2A55,
        ), // Background color for the whole section
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The main section heading
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(
                      Images.totalSponsersImg,
                      height: 20,
                      width: 20,
                    ), // Use appropriate image
                    const SizedBox(width: 8),
                    Text(
                      "Active Sponsorship Deals",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: "Montserrat",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Space after heading row
                // Border below the main heading
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
            ),
          ),
          SizedBox(
            height: 190,
            child:
                deals.isEmpty
                    ? Center(
                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          
                          
                          Text(
                            "🗓️ No Active Sponsorship Deals",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            Lorempsum.activeSponsorShipDeals,
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
                      itemCount: deals.length,
                      itemBuilder: (context, index) {
                        final deal = deals[index];
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.96,
                          child: DashboardSectionCard(
                            innerContent: ActiveSponsorshipDealsContent(
                              deal: deal,
                            ),
                            cardColor: Color(0xFF13386B),
                          ),
                        );
                      },
                    ),
          ),

          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onGoToDealsPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  foregroundColor: kButtonTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Go to Deals",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: "Montserrat",
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.play_arrow, size: 20),
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
