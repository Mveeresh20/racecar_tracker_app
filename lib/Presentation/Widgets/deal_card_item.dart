import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/deal_detail_screen.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/deal_detail_item.dart';
import 'package:racecar_tracker/models/deal_item.dart'; // Import the new DealItem model
import 'package:racecar_tracker/Services/sponsor_service.dart';
import 'package:racecar_tracker/Services/deal_service.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:racecar_tracker/Services/user_service.dart'; // Import UserService
import 'package:racecar_tracker/Presentation/Pages/add_new_deal_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:racecar_tracker/Services/racer_service.dart';
import 'package:racecar_tracker/Services/event_service.dart';

class DealCardItem extends StatelessWidget {
  final DealItem deal;
  final Future<DealDetailItem?> Function(String) fetchDealDetail;
  final SponsorService sponsorService;
  final DealService dealService;

  const DealCardItem({
    Key? key,
    required this.deal,
    required this.fetchDealDetail,
    required this.sponsorService,
    required this.dealService,
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
                      _showLogPaymentBottomSheet(context);
                    },
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B6AD2), Color(0xFF211E83)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () async {
                        try {
                          // Fetch the deal detail to get all necessary data
                          final detail = await fetchDealDetail(deal.id);
                          if (detail != null) {
                            // Get current user ID
                            final userId =
                                FirebaseAuth.instance.currentUser?.uid;
                            if (userId == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User not logged in'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            // Load all required data
                            final racerService = RacerService();
                            final eventService = EventService();
                            final sponsorService = SponsorService();

                            // Load data using streams
                            final racers =
                                await racerService
                                    .getRacersStream(userId)
                                    .first;
                            final events =
                                await eventService.getUserEvents(userId).first;
                            final sponsors =
                                await sponsorService
                                    .getSponsorsStream(userId)
                                    .first;

                            if (!context.mounted) return;

                            // Navigate to AddNewDealScreen with existing deal data and loaded lists
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddNewDealScreen(
                                      existingDeal: detail,
                                      sponsors: sponsors,
                                      racers: racers,
                                      events: events,
                                    ),
                              ),
                            );

                            // If the deal was updated, refresh the deals list
                            if (result == true) {
                              // The deals list will automatically update through the stream
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Deal updated successfully'),
                                  ),
                                );
                              }
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error loading deal details'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          print('Error preparing edit screen: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
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
    return Container(
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B6AD2), Color(0xFF211E83)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton.icon(
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
          } else if (label == "Log Payment") {
            onPressed();
          } else {
            onPressed();
          }
        },
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _showLogPaymentBottomSheet(BuildContext context) async {
    // Fetch sponsor details to get the name
    final userId = UserService().getCurrentUserId(); // Use UserService directly
    Sponsor? sponsor;
    if (userId != null) {
      try {
        sponsor = await sponsorService.getSponsor(userId, deal.sponsorId);
      } catch (e) {
        print('Error fetching sponsor for payment confirmation: $e');
        // Optionally show an error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading sponsor details.')),
          );
        }
        return; // Exit if sponsor cannot be fetched
      }
    }
    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250, // Adjust height as needed
          padding: const EdgeInsets.all(kDefaultPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF13386B), // Dark blue background
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Log Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Have you received the payment from ${sponsor?.name ?? deal.sponsorInitials}?', // Use sponsor name or initials
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 30), // Space before the button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Log payment logic here
                    print('Logging payment for deal ID: ${deal.id}');
                    try {
                      // Update deal status to 'paid'
                      await dealService.updateDeal(
                        deal.id,
                        userId: userId!, // Pass the userId
                        status: DealStatusType.paid,
                        context:
                            context, // Pass context if needed by updateDeal
                      );
                      print(
                        'Deal status updated to Paid for deal ID: ${deal.id}',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment logged successfully!'),
                          ),
                        );
                        Navigator.pop(context); // Close the bottom sheet
                      }
                    } catch (e) {
                      print('Error logging payment for deal ${deal.id}: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to log payment: $e')),
                        );
                        Navigator.pop(
                          context,
                        ); // Close the bottom sheet even on error
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC29), // Yellow button
                    foregroundColor: Colors.black, // Black text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60), // Rounded shape
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Yes, Log payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.play_arrow, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
