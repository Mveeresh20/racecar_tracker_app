import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/Presentation/Widgets/active_sponsership_deals_section.dart';
import 'package:racecar_tracker/Presentation/Widgets/active_sponsorship_deals_content.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_nav_bar.dart';
import 'package:racecar_tracker/Presentation/Widgets/build_action_card.dart';
import 'package:racecar_tracker/Presentation/Widgets/commission_summary_content.dart';
import 'package:racecar_tracker/Presentation/Widgets/dash_board_section_card.dart';
import 'package:racecar_tracker/Presentation/Widgets/pending_details_content.dart';
import 'package:racecar_tracker/Presentation/Widgets/total_track_cards.dart';
import 'package:racecar_tracker/Presentation/Widgets/up_coming_events_section.dart';
import 'package:racecar_tracker/Presentation/Widgets/upcomming_events_content.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/models/commission_detail.dart';
import 'package:racecar_tracker/models/deal.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/models/sponser_ship_deal.dart';
import 'package:racecar_tracker/models/summary_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<SummaryItem> summaryItems = [
    SummaryItem(
      title: "Total Deals Tracked",
      value: "22",
      icon: Icons.tag_faces,
    ),
    SummaryItem(title: "Total Sponsors", value: "13", icon: Icons.group),
    SummaryItem(
      title: "Commission",
      value: "\$1,00,000",
      icon: Icons.attach_money,
    ),
  ];

  final List<CommissionDetail> commissionDetails = [
    CommissionDetail(label: "This Month Earned:", value: "\$20,000"),
    CommissionDetail(label: "Total Sponsors Active:", value: "06"),
    CommissionDetail(label: "Total Deals Running:", value: "05"),
  ];

  final List<Deal> pendingDeals = [
    Deal(
      name: "GearX",
      client: "Alex Nitro",
      expiryDate: DateTime(2025, 6, 15),
    ),
    Deal(
      name: "Speedbank",
      client: "Sarah Jones",
      expiryDate: DateTime(2025, 5, 12),
    ),
    Deal(
      name: "TurboBoost",
      client: "Mark Davis",
      expiryDate: DateTime(2025, 7, 20),
    ),
  ];

  final List<Event> upcomingEvents = [
    Event(
      raceType: "race",
      trackName: "Thunderstruck Circuit B",
      currentRacers: 10,
      maxRacers: 20,
      status: EventStatusType.registrationOpen,
      title: "Summer GP Thunder Series",
      type: "Summer Race",
      dateTime: DateTime(2025, 6, 30, 22, 0),
      location: "Thunderstruck Circuit B",
      racerImageUrls: [
        'https://via.placeholder.com/150/FF0000', // Red placeholder
        'https://via.placeholder.com/150/0000FF', // Blue placeholder
        'https://via.placeholder.com/150/00FF00', // Green placeholder
      ],
      totalOtherRacers: 5,
    ),
    Event(
      raceType: "race",
      trackName: "Highland Raceway",
      currentRacers: 5,
      maxRacers: 10,
      status: EventStatusType.registrationOpen,
      title: "Autumn Speed Fest",
      type: "Grand Prix",
      dateTime: DateTime(2025, 9, 10, 14, 0),
      location: "Highland Raceway",
      racerImageUrls: [
        'https://via.placeholder.com/150/FFFF00', // Yellow
        'https://via.placeholder.com/150/00FFFF', // Cyan
      ],
      totalOtherRacers: 3,
    ),
    Event(
      raceType: "race",
      trackName: "Snowy Peaks Course",
      currentRacers: 10,
      maxRacers: 20,
      status: EventStatusType.registrationOpen,
      title: "Winter Endurance Challenge",
      type: "Charity Run",
      dateTime: DateTime(2025, 12, 5, 9, 30),
      location: "Snowy Peaks Course",
      racerImageUrls: [
        'https://via.placeholder.com/150/FF00FF', // Magenta
        'https://via.placeholder.com/150/FFC0CB', // Pink
      ],
      totalOtherRacers: 10,
    ),
  ];

  final List<SponsorshipDeal> activeSponsorshipDeals = [
    SponsorshipDeal(
      title: "DC Autos X Sarah White",
      dealValue: "\$1500",
      commission: "20%",
      renewalDate: "June 2026",
      status: DealStatus.pending,
    ),
    SponsorshipDeal(
      title: "Nitro Fuel X Team Alpha",
      dealValue: "\$3000",
      commission: "15%",
      renewalDate: "Dec 2025",
      status: DealStatus.active,
    ),
    SponsorshipDeal(
      title: "Speed Gear Inc. X Max Racer",
      dealValue: "\$2500",
      commission: "10%",
      renewalDate: "Jan 2026",
      status: DealStatus.completed,
    ),
  ];
  int commissionAmount = 100000;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        Images.homeScreen,
                        height: 330,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 330,

                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF2D5586).withOpacity(0.4),
                              Color(0xFF171E45).withOpacity(0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ).copyWith(top: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Icon(
                                        Icons.home,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Home",
                                      style: TextStyle(
                                        color: Color(0xFFFFCC29),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "Montserrat",
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 3,
                                      color: Colors.white,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(2),
                                  child: ClipOval(
                                    child: Image.network(
                                      Images.profile,
                                      height: 24,
                                      width: 24,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 26),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Hello Admin",
                              style: TextStyle(
                                color: Color(0xFFFFCC29),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Montserrat",
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ).copyWith(bottom: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TotalTrackCards(
                                    imageurl: Images.totalDealsCrackedImg,
                                    text: "Total Deals\ncracked",
                                    total: "22",
                                    cardColor: Color(0xFF455000),
                                    imgColor: Color(0xFFD0F500),
                                    fontSize: 24,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TotalTrackCards(
                                    imageurl: Images.totalSponsersImg,
                                    text: "Toatal\nSponsers",
                                    total: "22",
                                    cardColor: Color(0xFF4B3B00),
                                    imgColor: Color(0xFFFFA203),
                                    fontSize: 24,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TotalTrackCards(
                                    imageurl: Images.totalCommissionEarnedImg,
                                    text: "Commission\nEarned",
                                    total:
                                        "\$${NumberFormat.decimalPattern().format(commissionAmount)}",
                                    cardColor: Color(0xFF3B130E),
                                    imgColor: Color(0xFFFF393C),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: BuildActionCard(
                          imageUrl: Images.addRacerImg,
                          text: "Add\nRacer",
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: BuildActionCard(
                          imageUrl: Images.totalSponsersImg,
                          text: "Add\nRacer",
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: BuildActionCard(
                          imageUrl: Images.totalDealsCrackedImg,
                          text: "New\n Deal",
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: BuildActionCard(
                          imageUrl: Images.viewMaps,
                          text: "View\nMaps",
                          onTap: () {
                            print("Button Clicked");
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                DashboardSectionCard(
                  title: "Commission Summary",
                  imagurl: Images.totalCommissionEarnedImg,
                  innerContent: CommissionSummaryContent(
                    details: commissionDetails,
                  ),
                ),

                DashboardSectionCard(
                  title: "Pending Renewals/Expired Deals",
                  imagurl: Images.totalDealsCrackedImg,
                  innerContent: PendingDealsContent(
                    deals: pendingDeals,
                  ), // Pass the dynamic list
                  onGoToPressed: () {
                    print("Go to Pending Deals tapped!");
                  },
                  buttonText: "Go to Deals",
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color(0xFF0F2A55),
                    ),

                    child: UpcomingEventsSection(
                      events: upcomingEvents,
                      onGoToEventsPressed: () {
                        print("Go to ALL Events tapped!");
                      },
                    ),
                  ),
                ),

                ActiveSponsorshipDealsSection(
                  deals: activeSponsorshipDeals,
                  onGoToDealsPressed: () {
                    print("Go to ALL Active Deals tapped!");
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Color(0xFF13386B),
          ),
          child: _buildBottomNavBar(),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Color(0xFF13386B),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),

        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Color(0xFF13386B),

          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: BottomIcons(
                iconData: Icons.home,
                isSelected: _currentIndex == 0,
                defaultColor: Colors.grey,
                selectedColor: Colors.green,
                selectedBorderColor:
                    _currentIndex == 4 ? Color(0xFF0E5BC5) : Color(0xFF134A97),
                unselectedBorderColor: Color(0xFF134A97),
                // Pass selected color
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: BottomIcons(
                iconData: Icons.flag,
                isSelected: _currentIndex == 1,
                defaultColor: Colors.grey,
                selectedColor: Colors.green,
                selectedBorderColor:
                    _currentIndex == 4 ? Color(0xFF0E5BC5) : Color(0xFF134A97),
                unselectedBorderColor: Color(0xFF134A97),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: BottomIcons(
                imageUrl: Images.headIcon,
                isSelected: _currentIndex == 2,

                defaultColor: Colors.grey,
                selectedColor: Colors.green,
                selectedBorderColor:
                    _currentIndex == 4 ? Color(0xFF0E5BC5) : Color(0xFF134A97),
                unselectedBorderColor: Color(0xFF134A97),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: BottomIcons(
                imageUrl: Images.sponsorIcon,
                isSelected: _currentIndex == 3,
                defaultColor: Colors.grey,
                selectedColor: Colors.green,
                selectedBorderColor:
                    _currentIndex == 4 ? Color(0xFF0E5BC5) : Color(0xFF134A97),
                unselectedBorderColor: Color(0xFF134A97),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: BottomIcons(
                iconData: Icons.handshake,
                isSelected: _currentIndex == 4,
                defaultColor: Colors.grey,
                selectedColor: Colors.green,
                selectedBorderColor:
                    _currentIndex == 4 ? Color(0xFF0E5BC5) : Color(0xFF134A97),
                unselectedBorderColor: Color(0xFF134A97),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
//   Widget _buildInfoRow(String label, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4.0),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: TextStyle(color: Colors.white70)),
//         Text(value, style: TextStyle(color: Colors.white)),
//       ],
//     ),
//   );
// }

// Widget _buildDealRow(String dealName, String client, String status) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("$dealName \u2192 $client", style: TextStyle(color: Colors.white)),
//         Text(status, style: TextStyle(color: Colors.white70, fontSize: 12)),
//         const SizedBox(height: 4),
//       ],
//     ),
//   );
// }

// Widget _buildEventDetailRow(IconData icon, String text) {
//   return Padding(
//     padding: const EdgeInsets.only(top: 4.0),
//     child: Row(
//       children: [
//         Icon(icon, color: Colors.white54, size: 16),
//         const SizedBox(width: 8),
//         Text(text, style: TextStyle(color: Colors.white70, fontSize: 12)),
//       ],
//     ),
//   );
// }

// Widget _buildSponsorshipDeal(String title, String dealValue, String commission, String renewal, String status) {
//   // This helper method builds the specific complex layout for a sponsorship deal
//   return Card(
//     color: const Color(0xFF3B487A), // Slightly different shade for inner card
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     margin: const EdgeInsets.symmetric(vertical: 8.0),
//     child: Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.orange,
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Text(status, style: const TextStyle(color: Colors.black, fontSize: 12)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Deal Value", style: TextStyle(color: Colors.white70, fontSize: 12)),
//                   Text(dealValue, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Commission", style: TextStyle(color: Colors.white70, fontSize: 12)),
//                   Text(commission, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Renewal", style: TextStyle(color: Colors.white70, fontSize: 12)),
//                   Text(renewal, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
