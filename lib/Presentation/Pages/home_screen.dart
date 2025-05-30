import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_deal_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_racer_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/deals_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/profile_page.dart';
import 'package:racecar_tracker/Presentation/Pages/race_evets_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/racers_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/sponsers_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/track_map_screen.dart';
import 'package:racecar_tracker/Presentation/Views/add_new_sponsor_screen.dart';
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
import 'package:racecar_tracker/models/deal_item.dart';

import 'package:racecar_tracker/Services/edit_profile_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    RaceEvetsScreen(),
    RacersScreen(),
    SponsersScreen(),
    DealsScreen(),
  ];
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

  List<Event> upcomingEvents = [
    Event(
      id: "event1",
      title: "Summer GP 2025",
      raceType: "Formula 1",
      dateTime: DateTime(2025, 6, 15),
      trackName: "Silverstone Circuit",
      raceName: "British Grand Prix",
      location: "Silverstone, UK",
      type: "Formula 1",
      currentRacers: 15,
      maxRacers: 20,
      status: EventStatusType.registrationOpen,
      racerImageUrls: [],
      totalOtherRacers: 14,
    ),
    Event(
      id: "event2",
      title: "Winter Rally 2025",
      raceType: "Rally",
      dateTime: DateTime(2025, 1, 20),
      trackName: "Monte Carlo Rally",
      raceName: "Monte Carlo Rally",
      location: "Monte Carlo, Monaco",
      type: "Rally",
      currentRacers: 25,
      maxRacers: 30,
      status: EventStatusType.registrationOpen,
      racerImageUrls: [],
      totalOtherRacers: 24,
    ),
  ];

  final List<DealItem> activeSponsorshipDeals = [
    DealItem(
      id: "home_deal1",
      sponsorId: "sponsor1",
      racerId: "racer1",
      eventId: "event1",
      title: "DC Autos X Sarah White",
      raceType: "Summer Race",
      dealValue: "\$1500",
      commission: "20%",
      renewalDate: "June 2026",
      parts: ["Car Doors", "Suit"],
      status: DealStatusType.pending,
      sponsorInitials: "DA",
      racerInitials: "SW",
    ),
    DealItem(
      id: "home_deal2",
      sponsorId: "sponsor2",
      racerId: "racer2",
      eventId: "event2",
      title: "Nitro Fuel X Team Alpha",
      raceType: "Circuit Race",
      dealValue: "\$3000",
      commission: "15%",
      renewalDate: "Dec 2025",
      parts: ["Engine", "Tyres"],
      status: DealStatusType.paid,
      sponsorInitials: "NF",
      racerInitials: "TA",
    ),
    DealItem(
      id: "home_deal3",
      sponsorId: "sponsor3",
      racerId: "racer3",
      eventId: "event3",
      title: "Speed Gear Inc. X Max Racer",
      raceType: "Grand Prix",
      dealValue: "\$2500",
      commission: "10%",
      renewalDate: "Jan 2026",
      parts: ["Helmet", "Suit"],
      status: DealStatusType.pending,
      sponsorInitials: "SG",
      racerInitials: "MR",
    ),
  ];
  int commissionAmount = 100000;

  @override
  void initState() {
    super.initState();
    // Initialize profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditProfileProvider>(
        context,
        listen: false,
      ).fetchUserProfileDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
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

class HomeContent extends StatelessWidget {
  HomeContent({Key? key}) : super(key: key);

  final int commissionAmount = 100000;
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
      id: "event1",
      title: "Summer GP 2025",
      raceType: "Formula 1",
      dateTime: DateTime(2025, 6, 15),
      trackName: "Silverstone Circuit",
      raceName: "British Grand Prix",
      location: "Silverstone, UK",
      type: "Formula 1",
      currentRacers: 15,
      maxRacers: 20,
      status: EventStatusType.registrationOpen,
      racerImageUrls: [],
      totalOtherRacers: 14,
    ),
    Event(
      id: "event2",
      title: "Winter Rally 2025",
      raceType: "Rally",
      dateTime: DateTime(2025, 1, 20),
      trackName: "Monte Carlo Rally",
      raceName: "Monte Carlo Rally",
      location: "Monte Carlo, Monaco",
      type: "Rally",
      currentRacers: 25,
      maxRacers: 30,
      status: EventStatusType.registrationOpen,
      racerImageUrls: [],
      totalOtherRacers: 24,
    ),
  ];

  final List<DealItem> activeSponsorshipDeals = [
    DealItem(
      id: "home_deal1",
      sponsorId: "sponsor1",
      racerId: "racer1",
      eventId: "event1",
      title: "DC Autos X Sarah White",
      raceType: "Summer Race",
      dealValue: "\$1500",
      commission: "20%",
      renewalDate: "June 2026",
      parts: ["Car Doors", "Suit"],
      status: DealStatusType.pending,
      sponsorInitials: "DA",
      racerInitials: "SW",
    ),
    DealItem(
      id: "home_deal2",
      sponsorId: "sponsor2",
      racerId: "racer2",
      eventId: "event2",
      title: "Nitro Fuel X Team Alpha",
      raceType: "Circuit Race",
      dealValue: "\$3000",
      commission: "15%",
      renewalDate: "Dec 2025",
      parts: ["Engine", "Tyres"],
      status: DealStatusType.paid,
      sponsorInitials: "NF",
      racerInitials: "TA",
    ),
    DealItem(
      id: "home_deal3",
      sponsorId: "sponsor3",
      racerId: "racer3",
      eventId: "event3",
      title: "Speed Gear Inc. X Max Racer",
      raceType: "Grand Prix",
      dealValue: "\$2500",
      commission: "10%",
      renewalDate: "Jan 2026",
      parts: ["Helmet", "Suit"],
      status: DealStatusType.pending,
      sponsorInitials: "SG",
      racerInitials: "MR",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                              Consumer<EditProfileProvider>(
                                builder: (context, provider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfilePage(),
                                        ),
                                      );
                                    },
                                    child: Container(
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
                                          provider.getProfileImageUrl(),
                                          height: 24,
                                          width: 24,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Image.network(
                                              Images.profileImg,
                                              height: 24,
                                              width: 24,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 26),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<EditProfileProvider>(
                            builder: (context, provider, child) {
                              return Text(
                                "Hello ${provider.profileDetails?.userName ?? 'User'}",
                                style: TextStyle(
                                  color: Color(0xFFFFCC29),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Montserrat",
                                ),
                              );
                            },
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddNewRacerScreen(events: []),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: BuildActionCard(
                        imageUrl: Images.totalSponsersImg,
                        text: "Add\nSponsor",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNewSponsorScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: BuildActionCard(
                        imageUrl: Images.totalDealsCrackedImg,
                        text: "New\n Deal",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNewDealScreen(
                                sponsors: [],
                                racers: [],
                                events: [],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: BuildActionCard(
                        imageUrl: Images.viewMaps,
                        text: "View\nMaps",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackMapScreen(),
                            ),
                          );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DealsScreen()),
                  );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RaceEvetsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              ActiveSponsorshipDealsSection(
                deals: activeSponsorshipDeals,
                onGoToDealsPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DealsScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
