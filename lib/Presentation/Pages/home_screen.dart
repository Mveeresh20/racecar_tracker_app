import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_deal_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_racer_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_sponsor_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/deals_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/profile_page.dart';
import 'package:racecar_tracker/Presentation/Pages/race_evets_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/racers_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/sponsers_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/sponsors_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/track_map_screen.dart';

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
import 'package:racecar_tracker/Services/sponsor_provider.dart';
import 'package:racecar_tracker/Services/event_provider.dart';
import 'package:racecar_tracker/Services/racer_provider.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Services/deal_service.dart';
import 'package:racecar_tracker/Services/sponsor_service.dart';
import 'package:racecar_tracker/Services/event_service.dart';
import 'package:racecar_tracker/Services/racer_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Import for StreamSubscription
import 'package:racecar_tracker/models/sponsor.dart'; // Import Sponsor model

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final UserService _userService = UserService();
  final DealService _dealService = DealService();
  final SponsorService _sponsorService = SponsorService();
  final EventService _eventService = EventService();
  final RacerService _racerService = RacerService();

  int _totalDeals = 0;
  int _totalSponsors = 0;
  double _totalCommissionEarned = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeHomeData();
  }

  void _initializeHomeData() async {
    final userId = _userService.getCurrentUserId();
    if (userId == null) return; // Handle not logged in

    // Stream total deals
    _dealService.streamDeals(userId).listen((deals) {
      if (mounted) {
        setState(() {
          _totalDeals = deals.length;
          _totalCommissionEarned =
              (deals?.fold<double>(0.0, (double sum, deal) {
                    try {
                      final dealValue =
                          double.tryParse(
                            deal.dealValue.replaceAll(RegExp(r'[^0-9.]'), ''),
                          ) ??
                          0.0;
                      final commissionPercentage =
                          double.tryParse(
                            deal.commission.replaceAll('%', ''),
                          ) ??
                          0.0;
                      return sum + (dealValue * (commissionPercentage / 100));
                    } catch (e) {
                      print(
                        'Error calculating commission for deal ${deal.id}: $e',
                      );
                      return sum;
                    }
                  }) ??
                  0.0);
        });
      }
    });

    // Stream total sponsors
    _sponsorService.getSponsorsStream(userId).listen((sponsors) {
      if (mounted) {
        setState(() {
          _totalSponsors = sponsors.length;
        });
      }
    });
  }

  final List<Widget> _screens = [
    HomeContent(),
    RaceEvetsScreen(),
    RacersScreen(),
    SponsorsScreen(),
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
      userId: "478",
      id: "event1",
      name: "Circuit Race",
      type: "Formula 1",
      location: "Silverstone Circuit",
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      status: EventStatusType.registrationOpen,
      description: "British Grand Prix",
      totalRacers: 20,
      totalSponsors: 10,
      totalPrizeMoney: 100000,
      currentRacers: 15,
      maxRacers: 20,
      racerImageUrls: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Event(
      userId: "478",
      id: "event2",
      name: "Winter Rally 2025",
      type: "Rally",
      location: "Monte Carlo Rally",
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      status: EventStatusType.registrationOpen,
      description: "Monte Carlo Rally",
      totalRacers: 30,
      totalSponsors: 15,
      totalPrizeMoney: 150000,
      currentRacers: 25,
      maxRacers: 30,
      racerImageUrls: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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

class HomeContent extends StatefulWidget {
  HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Define variables to hold streamed data
  int _totalDeals = 0;
  int _totalSponsors = 0;
  double _totalCommissionEarned = 0.0;
  List<CommissionDetail> _commissionDetails = [];
  List<Deal> _pendingDeals = [];
  List<Event> _upcomingEvents = [];
  List<DealItem> _activeSponsorshipDeals = [];

  // Service instances
  final DealService _dealService = DealService();
  final SponsorService _sponsorService = SponsorService();
  final EventService _eventService = EventService();

  // Stream subscriptions
  StreamSubscription? _dealsSubscription;
  StreamSubscription? _sponsorsSubscription;
  StreamSubscription?
  _commissionSummarySubscription; // Will need a stream for this
  StreamSubscription? _pendingDealsSubscription; // Will need a stream for this
  StreamSubscription? _upcomingEventsSubscription;
  StreamSubscription?
  _activeSponsorshipDealsSubscription; // Will need a stream for this

  @override
  void initState() {
    super.initState();
    _initializeHomeContentData();
  }

  @override
  void dispose() {
    _dealsSubscription?.cancel();
    _sponsorsSubscription?.cancel();
    _commissionSummarySubscription?.cancel();
    _pendingDealsSubscription?.cancel();
    _upcomingEventsSubscription?.cancel();
    _activeSponsorshipDealsSubscription?.cancel();
    super.dispose();
  }

  void _initializeHomeContentData() async {
    final userId = UserService().getCurrentUserId();
    if (userId == null) {
      print('User not logged in');
      return;
    }

    // Stream total deals and commission
    _dealsSubscription = _dealService
        .streamDeals(userId)
        .listen(
          (deals) {
            if (mounted) {
              setState(() {
                _totalDeals = deals?.length ?? 0;
                _totalCommissionEarned =
                    (deals?.fold<double>(0.0, (double sum, deal) {
                          try {
                            final dealValue =
                                double.tryParse(
                                  deal.dealValue.replaceAll(
                                    RegExp(r'[^0-9.]'),
                                    '',
                                  ),
                                ) ??
                                0.0;
                            final commissionPercentage =
                                double.tryParse(
                                  deal.commission.replaceAll('%', ''),
                                ) ??
                                0.0;
                            return sum +
                                (dealValue * (commissionPercentage / 100));
                          } catch (e) {
                            print(
                              'Error calculating commission for deal ${deal.id}: $e',
                            );
                            return sum;
                          }
                        }) ??
                        0.0);
              });
              _updateCommissionSummary(userId, deals, null);
              _updatePendingAndActiveDeals(userId, deals ?? []);
            }
          },
          onError: (error) {
            print('Error fetching deals: $error');
            if (mounted) {
              setState(() {
                _totalDeals = 0;
                _totalCommissionEarned = 0.0;
                _commissionDetails = [
                  CommissionDetail(
                    label: "This Month Earned:",
                    value: "\$0.00",
                  ),
                  CommissionDetail(label: "Total Sponsors Active:", value: "0"),
                  CommissionDetail(label: "Total Deals Running:", value: "0"),
                ];
                _pendingDeals = [];
                _activeSponsorshipDeals = [];
              });
            }
          },
        );

    // Stream total sponsors
    _sponsorsSubscription = _sponsorService
        .getSponsorsStream(userId)
        .listen(
          (sponsors) {
            if (mounted) {
              setState(() {
                _totalSponsors = sponsors?.length ?? 0;
              });
              _updateCommissionSummary(userId, null, sponsors);
            }
          },
          onError: (error) {
            print('Error fetching sponsors: $error');
            if (mounted) {
              setState(() {
                _totalSponsors = 0;
                // Update commission details to reflect no active sponsors
                _updateCommissionSummary(userId, null, []);
              });
            }
          },
        );

    // Stream upcoming events
    _upcomingEventsSubscription = _eventService.streamUpcomingEvents().listen(
      (events) {
        if (mounted) {
          setState(() {
            _upcomingEvents = events ?? [];
          });
        }
      },
      onError: (error) {
        print('Error fetching upcoming events: $error');
        if (mounted) {
          setState(() {
            _upcomingEvents = [];
          });
        }
      },
    );
  }

  // Helper function to update Commission Summary data
  void _updateCommissionSummary(
    String userId,
    List<DealItem>? deals,
    List<Sponsor>? sponsors,
  ) async {
    if (!mounted) return;

    try {
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      // Calculate This Month Earned
      final thisMonthEarned =
          (deals
                  ?.where((deal) {
                    if (deal.renewalDate == null || deal.renewalDate.isEmpty)
                      return false;
                    try {
                      final endDate = DateFormat(
                        'MMMM yyyy',
                      ).parse(deal.renewalDate);
                      return endDate.month == currentMonth &&
                          endDate.year == currentYear;
                    } catch (e) {
                      print('Error parsing date for deal ${deal.id}: $e');
                      return false;
                    }
                  })
                  .fold<double>(0.0, (double sum, deal) {
                    try {
                      final commissionPercentage =
                          double.tryParse(
                            deal.commission.replaceAll('%', ''),
                          ) ??
                          0.0;
                      final dealValue =
                          double.tryParse(
                            deal.dealValue.replaceAll(RegExp(r'[^0-9.]'), ''),
                          ) ??
                          0.0;
                      return sum + (dealValue * (commissionPercentage / 100));
                    } catch (e) {
                      print(
                        'Error calculating commission for deal ${deal.id}: $e',
                      );
                      return sum;
                    }
                  }) ??
              0.0);

      // Calculate Total Sponsors Active
      final totalSponsorsActive =
          sponsors
              ?.where((sponsor) => sponsor.status == SponsorStatus.active)
              .length ??
          0;

      // Calculate Total Deals Running
      final now = DateTime.now();
      final totalDealsRunning =
          deals?.where((deal) {
            if (deal.renewalDate == null || deal.renewalDate.isEmpty)
              return false;
            try {
              final endDate = DateFormat('MMMM yyyy').parse(deal.renewalDate);
              return endDate.isAfter(now);
            } catch (e) {
              print('Error parsing date for deal ${deal.id}: $e');
              return false;
            }
          }).length ??
          0;

      if (mounted) {
        setState(() {
          _commissionDetails = [
            CommissionDetail(
              label: "This Month Earned:",
              value:
                  "\$${NumberFormat.decimalPattern().format(thisMonthEarned)}",
            ),
            CommissionDetail(
              label: "Total Sponsors Active:",
              value: "$totalSponsorsActive",
            ),
            CommissionDetail(
              label: "Total Deals Running:",
              value: "$totalDealsRunning",
            ),
          ];
        });
      }
    } catch (e) {
      print('Error updating commission summary: $e');
      if (mounted) {
        setState(() {
          _commissionDetails = [
            CommissionDetail(label: "This Month Earned:", value: "\$0.00"),
            CommissionDetail(label: "Total Sponsors Active:", value: "0"),
            CommissionDetail(label: "Total Deals Running:", value: "0"),
          ];
        });
      }
    }
  }

  // Helper function to update Pending and Active Deals data
  void _updatePendingAndActiveDeals(String userId, List<DealItem> deals) async {
    if (!mounted) return;
    // Implement logic to filter deals for pending renewals/expired and active sponsorships
    final now = DateTime.now();
    final pendingOrExpiredThreshold = now.add(
      Duration(days: 30),
    ); // Deals expiring in the next 30 days or expired

    final pendingDealsList =
        deals
            .where((deal) {
              // Check if renewalDate is not null or empty before parsing
              if (deal.renewalDate == null || deal.renewalDate.isEmpty)
                return false;

              try {
                final endDate = DateFormat('MMMM yyyy').parse(
                  deal.renewalDate,
                ); // Assuming renewalDate is in 'MMMM yyyy' format
                return endDate.isBefore(now) ||
                    (endDate.isAfter(now) &&
                        endDate.isBefore(pendingOrExpiredThreshold));
              } catch (e) {
                print('Error parsing date for deal ${deal.id}: $e');
                return false; // Exclude deals with invalid dates
              }
            })
            .map(
              (dealItem) => Deal(
                name:
                    dealItem
                        .sponsorInitials, // Assuming sponsor initials can be used as name
                client:
                    dealItem
                        .racerInitials, // Assuming racer initials can be used as client
                expiryDate: DateFormat('MMMM yyyy').parse(
                  dealItem.renewalDate,
                ), // Assuming renewalDate is in 'MMMM yyyy' format
              ),
            )
            .toList();

    final activeDealsList =
        deals.where((deal) {
          // Check if renewalDate is not null or empty before parsing
          if (deal.renewalDate == null || deal.renewalDate.isEmpty)
            return false;

          try {
            final endDate = DateFormat('MMMM yyyy').parse(
              deal.renewalDate,
            ); // Assuming renewalDate is in 'MMMM yyyy' format
            return endDate.isAfter(
              now,
            ); // Deals with end date in the future are active
          } catch (e) {
            print('Error parsing date for deal ${deal.id}: $e');
            return false; // Exclude deals with invalid dates
          }
        }).toList();

    setState(() {
      _pendingDeals = pendingDealsList;
      _activeSponsorshipDeals = activeDealsList;
    });
  }

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
                                  total: "$_totalDeals",
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
                                  total: "$_totalSponsors",
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
                                      "\$${NumberFormat.decimalPattern().format(_totalCommissionEarned)}",
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
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddNewRacerScreen(),
                            ),
                          );

                          if (result == true) {
                            // Refresh racers list if needed
                            final userId = UserService().getCurrentUserId();
                            if (userId != null) {
                              await Provider.of<RacerProvider>(
                                context,
                                listen: false,
                              ).initializeRacers(userId);
                            }
                          }
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
                              builder:
                                  (context) => AddNewSponsorScreen(
                                    provider: Provider.of<SponsorProvider>(
                                      context,
                                      listen: false,
                                    ),
                                  ),
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
                              builder:
                                  (context) => AddNewDealScreen(
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
                  details: _commissionDetails,
                ),
              ),
              DashboardSectionCard(
                title: "Pending Renewals/Expired Deals",
                imagurl: Images.totalDealsCrackedImg,
                innerContent: PendingDealsContent(deals: _pendingDeals),
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
                    events: _upcomingEvents,
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
                deals: _activeSponsorshipDeals,
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
