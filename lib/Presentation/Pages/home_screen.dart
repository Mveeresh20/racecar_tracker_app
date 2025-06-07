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
import 'package:racecar_tracker/Presentation/Pages/track_maps_page.dart';

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
import 'package:racecar_tracker/Utils/Constants/text.dart';
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
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:racecar_tracker/Presentation/Views/add_new_event_screen.dart'; // Import the AddNewEventScreen

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
  void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 270,
                height: 122.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2730),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Title and subtitle
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 18,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 238,
                            child: Text(
                              "Exit App",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                height: 22 / 17,
                                letterSpacing: -0.41,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            width: 238,
                            child: Text(
                              "Are you sure you want to exit app?",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                height: 18 / 13,
                                letterSpacing: -0.08,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Buttons
                    Row(
                      children: [
                        // Not Now
                        SizedBox(
                          width: 134.75,
                          height: 44,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 11,
                                horizontal: 8,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                ),
                              ),
                              foregroundColor: const Color(0xFF007AFF),
                              backgroundColor: Colors.transparent,
                              textStyle: const TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w400,
                                fontSize: 17,
                                letterSpacing: -0.41,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Not Now"),
                          ),
                        ),
                        // Yes
                        SizedBox(
                          width: 134.75,
                          height: 44,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 11,
                                horizontal: 8,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                              foregroundColor: const Color(0xFFF23943),
                              backgroundColor: Colors.transparent,
                              textStyle: const TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w400,
                                fontSize: 17,
                                letterSpacing: -0.41,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              SystemNavigator.pop(); // This will exit the app
                            },
                            child: const Text("Yes"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          // If not on the Home tab, switch to Home tab
          setState(() {
            _currentIndex = 0;
          });
          return false; // Prevent default pop behavior
        } else {
          // If already on the Home tab, show exit dialog
          showExitDialog(context);
          return false;
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: const Color(0xFF13386B),
            ),
            child: _buildBottomNavBar(),
          ),
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
                imageUrl: Images.navBarHome,
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
                imageUrl: Images.navBarImg,

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
                imageUrl: Images.navBarDeal,

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
  final RacerService _racerService = RacerService();

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
    _upcomingEventsSubscription = _eventService
        .streamUpcomingEvents(userId)
        .listen(
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

    print('Updating pending and active deals for user: $userId');
    print('Total deals received: ${deals.length}');

    final now = DateTime.now();
    final pendingOrExpiredThreshold = now.add(Duration(days: 30));

    // Filter deals based on their status and end date
    final List<Deal> pendingDealsList = [];
    final List<DealItem> activeDealsList =
        []; // Use DealItem for active deals list

    for (final deal in deals) {
      print(
        'Processing deal ID: ${deal.id}, Status: ${deal.status}, RenewalDate: ${deal.renewalDate}',
      );

      // Check for pending deals
      if (deal.status == DealStatusType.pending) {
        try {
          final endDate = DateFormat('MMMM yyyy').parse(deal.renewalDate);
          print(
            'Parsed endDate for pending deal ${deal.id}: $endDate. Threshold: $pendingOrExpiredThreshold',
          );
          if (endDate.isBefore(pendingOrExpiredThreshold)) {
            print('Deal ${deal.id} is pending and expiring soon.');
            // Fetch full sponsor and racer details
            final sponsor = await _sponsorService.getSponsor(
              userId,
              deal.sponsorId,
            );
            final racer = await _racerService.getRacer(userId, deal.racerId);

            if (sponsor != null && racer != null) {
              pendingDealsList.add(
                Deal(
                  name: sponsor.name, // Use full sponsor name
                  client: racer.name, // Use full racer name
                  expiryDate: endDate,
                ),
              );
              print('Added deal ${deal.id} to pending deals list.');
            } else {
              print(
                'Sponsor or Racer not found for pending deal ${deal.id}. Sponsor ID: ${deal.sponsorId}, Racer ID: ${deal.racerId}',
              );
            }
          }
        } catch (e) {
          print(
            'Error parsing date or fetching details for pending deal ${deal.id}: $e',
          );
        }
      }

      // Check for active deals
      if (deal.status == DealStatusType.paid) {
        try {
          final endDate = DateFormat('MMMM yyyy').parse(deal.renewalDate);
          print(
            'Parsed endDate for active deal ${deal.id}: $endDate. Current date: $now',
          );
          if (endDate.isAfter(now)) {
            activeDealsList.add(deal); // Add the DealItem directly
            print('Deal ${deal.id} is paid and active.');
          } else {
            print('Deal ${deal.id} is paid but expired.');
          }
        } catch (e) {
          print('Error parsing date for active deal ${deal.id}: $e');
        }
      }
    }

    print(
      'Finished processing deals. Pending deals count: ${pendingDealsList.length}, Active deals count: ${activeDealsList.length}',
    );

    if (mounted) {
      setState(() {
        _pendingDeals = pendingDealsList;
        _activeSponsorshipDeals = activeDealsList;
      });
      print('setState called with updated pending and active deals.');
    }
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
                                    child: Image.network(Images.navBarHome)
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
                                          height: 30,
                                          width: 30,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Image.network(
                                              Images.profileImg,
                                              height: 30,
                                              width: 30,
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
                                  text: "Total\nSponsors",
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
                        text: "New\nDeal",
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
                              builder: (context) => const TrackMapScreen(),
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
                onGoToPressed:
                    _pendingDeals.isNotEmpty
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DealsScreen(),
                            ),
                          );
                        }
                        : null,
                buttonText: _pendingDeals.isNotEmpty ? "Go to Deals" : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Color(0xFF0F2A55),
                  ),
                  child: // Conditionally show Upcoming Events Section or Add Event button
                      _upcomingEvents.isNotEmpty
                          ? UpcomingEventsSection(
                            events: _upcomingEvents,
                            onGoToEventsPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RaceEvetsScreen(),
                                ),
                              );
                            },
                          )
                          : DashboardSectionCard(
                            title: "Upcoming Events", // Use a similar title
                            imagurl:
                                Images
                                    .upcommingEventsImg, // Use an existing image asset
                            innerContent:
                                Container(), // Add required innerContent
                            onGoToPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddNewEventScreen(),
                                ),
                              );
                            },
                            buttonText:
                                "Add New Recent Event", // The new button text
                          ),
                ),
              ),
              // Conditionally show Active Sponsorship Deals Section or a message
              _activeSponsorshipDeals.isNotEmpty
                  ? ActiveSponsorshipDealsSection(
                    deals: _activeSponsorshipDeals,
                    onGoToDealsPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DealsScreen()),
                      );
                    },
                  )
                  : DashboardSectionCard(
                    title: "Active Sponsorship Deals", // Use a similar title
                    imagurl:
                        Images.totalSponsersImg, // Use an existing image asset
                    innerContent: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
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
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              Lorempsum.activeSponsorShipDeals,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ), // Message for no active deals
                    // No onGoToPressed or buttonText when empty
                  ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
