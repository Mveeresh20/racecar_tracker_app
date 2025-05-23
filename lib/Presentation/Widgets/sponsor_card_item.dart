import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/sponsor.dart'; // Import the Sponsor model

class SponsorCardItem extends StatelessWidget {
  final Sponsor sponsor;

  const SponsorCardItem({Key? key, required this.sponsor}) : super(key: key);

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
      
       // Rounded corners for cards
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
                      color: Color(0xFF252D38),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ), // Placeholder color for initials background
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
                        style: TextStyle(
                          color: Color(0xFFA8E266),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ), // Sponsor Name
                      ),
                      Text(
                        sponsor.email,
                        style: context.bodyMedium?.copyWith(color: Colors.white),
                        // Sponsor Email
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 7),
      
              // Parts/Categories
              Wrap(
                spacing: 8.0, // horizontal space between chips
                runSpacing: 4.0, // vertical space between lines of chips
                children:
                    sponsor.parts.map((part) => _buildPartChip(part)).toList(),
              ),
              const SizedBox(height: 12),
      
              // Active Deals, Ends Date, and Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Active Deals: ${sponsor.activeDeals}", // Active Deals
                    style:context.titleSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ends: ${DateFormat('dd/MM/yyyy').format(sponsor.endDate)}", // End Date
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
                    padding: const EdgeInsets.all(8
                      
                    ),
                    decoration: BoxDecoration(
                      color: sponsor.statusColor, // Dynamic status color
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Rounded corners for status button
                    ),
                    child: Text(
                      sponsor.statusText, // Dynamic status text
                      style: context.labelLarge?.copyWith(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 8),
      
                  Row(
                    children: [
                      // Action Icons
                      _buildActionButton(Icons.remove_red_eye_outlined, () {
                        // Handle View action
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
        color: Color(0xFF1B2953),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white,),),
      ));
  }

  // Widget _buildPartChip(String text) {
  //   return Chip(
  //     label: Text(
  //       text,
  //       style: const TextStyle(color: Colors.white, fontSize: 12), // Chip text color
  //     ),
  //     backgroundColor: const Color(0xFF32487C), // Chip background color
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //   );
  // }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20), // For ripple effect
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          gradient: LinearGradient(
            colors: [Color(0xFF8B6AD2), Color(0xFF211E83)],
          ),

          // Action button background color
        ),
        child: Icon(icon, color: Colors.white, size: 20), // Action icon color
      ),
    );
  }
}
