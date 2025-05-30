import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_deal_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/profile_page.dart';
import 'package:racecar_tracker/Presentation/Pages/sponsers_screen.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/deal_card_item.dart';
import 'package:racecar_tracker/Services/edit_profile_provider.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/models/deal_detail_item.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/sponsor.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  List<Racer> getSampleRacers() {
    return [
      Racer(
        id: "racer1",
        initials: "WB",
        vehicleImageUrl: "https://via.placeholder.com/50/FF0000",
        name: "Wayne Brotzký",
        vehicleModel: "Ferrari F2004",
        teamName: "Speed Rebels",
        currentEvent: "Summer GP 2025",
        earnings: "\$5,200",
        contactNumber: "+88 1234567890",
        vehicleNumber: "WB 22 F2004",
        activeRaces: 2,
        totalRaces: 15,
      ),
      // ... more racers
    ];
  }

  List<Sponsor> getSampleSponsors() {
    return [
      Sponsor(
        id: "sponsor1",
        initials: "DC",
        name: "DC Autos",
        email: "john@dcauto.com",
        parts: ["Car Doors", "Rear Bumper", "Suit"],
        activeDeals: 2,
        endDate: DateTime(2025, 6, 15),
        status: SponsorStatus.active,
      ),
      // ... more sponsors
    ];
  }

  List<Event> getSampleEvents() {
    return [
      Event(
        id: "event1",
        raceName: "Circuit Race",
        type: "Summer Race",
        location: "Longmilan track",
        title: "Summer GP Thunder Series",
        raceType: "Summer Race",
        dateTime: DateTime(2025, 6, 20, 22, 0),
        trackName: "Longmilan track",
        currentRacers: 10,
        maxRacers: 16,
        status: EventStatusType.registrationOpen,
        racerImageUrls: [],
        totalOtherRacers: 6,
      ),
      // ... more events
    ];
  }

  List<Sponsor> sponsors = []; // Your full list of sponsors
  List<Racer> racers = []; // Your full list of racers
  List<Event> events = [];
  int _currentIndex = 4;

  final TextEditingController _searchController = TextEditingController();
  List<DealItem> _allDeals = []; // Your full list of deals
  List<DealItem> _filteredDeals = []; // The list shown in the UI

  @override
  void initState() {
    super.initState();
    _allDeals = _getSampleDeals(); // Initialize with sample data
    _filteredDeals = _allDeals;
    racers = getSampleRacers();
    events = getSampleEvents();
    sponsors = getSampleSponsors(); // Initially, show all deals
    _searchController.addListener(
      _filterDeals,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditProfileProvider>(
        context,
        listen: false,
      ).fetchUserProfileDetails();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDeals);
    _searchController.dispose();
    super.dispose();
  }

  void _filterDeals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDeals = _allDeals;
      } else {
        _filteredDeals = _allDeals.where((deal) {
          // Search by title, race type, or parts
          final titleMatches = deal.title.toLowerCase().contains(query);
          final raceTypeMatches = deal.raceType.toLowerCase().contains(
                query,
              );
          final partsMatches = deal.parts.any(
            (part) => part.toLowerCase().contains(query),
          );
          return titleMatches || raceTypeMatches || partsMatches;
        }).toList();
      }
    });
  }

  void _navigateToAddDealScreen() async {
    final newDeal = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewDealScreen(
          sponsors: sponsors,
          racers: racers,
          events: events,
        ),
      ),
    );

    if (newDeal != null && newDeal is DealItem) {
      setState(() {
        _allDeals.add(newDeal);
        _filterDeals();
      });
    }
  }

  // --- Sample Deal Data (Replace with your actual data source) ---
  List<DealItem> _getSampleDeals() {
    return [
      DealItem(
        id: "1",
        sponsorId: "sponsor1",
        racerId: "racer1",
        eventId: "event1",
        title: "ABC Motors X Sarah White",
        raceType: "Summer Race",
        dealValue: "\$1500",
        commission: "10%",
        renewalDate: "June 2026",
        parts: ["Car Doors", "Suit"],
        status: DealStatusType.pending,
        sponsorInitials: "AM",
        racerInitials: "SW",
      ),
      DealItem(
        id: "2",
        sponsorId: "sponsor2",
        racerId: "racer2",
        eventId: "event2",
        title: "DC Auto X Jonathan Meave",
        raceType: "Drift Race",
        dealValue: "\$8000",
        commission: "15%",
        renewalDate: "August 2026",
        parts: ["Hood", "Suit", "Side Doors"],
        status: DealStatusType.paid,
        sponsorInitials: "DA",
        racerInitials: "JM",
      ),
      DealItem(
        id: "3",
        sponsorId: "sponsor3",
        racerId: "racer3",
        eventId: "event3",
        title: "Formula One Corp X Max Speed",
        raceType: "Grand Prix",
        dealValue: "\$12000",
        commission: "20%",
        renewalDate: "July 2027",
        parts: ["Aerodynamics", "Engine"],
        status: DealStatusType.pending,
        sponsorInitials: "FC",
        racerInitials: "MS",
      ),
      DealItem(
        id: "4",
        sponsorId: "sponsor4",
        racerId: "racer4",
        eventId: "event4",
        title: "Turbo Chargers Inc X Alice Race",
        raceType: "Circuit Race",
        dealValue: "\$5000",
        commission: "12%",
        renewalDate: "April 2026",
        parts: ["Turbo Kit", "Exhaust"],
        status: DealStatusType.paid,
        sponsorInitials: "TC",
        racerInitials: "AR",
      ),
    ];
  }

  DealDetailItem? _fetchDealDetailItemById(String id) {
    // Try to find a matching detail for existing deals
    if (id == "1") {}
    // Fallback for new deals
    DealItem? deal;
    for (final d in _allDeals) {
      if (d.id == id) {
        deal = d;
        break;
      }
    }
    if (deal != null) {
      return DealDetailItem(
        sponsorId: deal.sponsorId,
        racerId: deal.racerId,
        eventId: deal.eventId,

        id: deal.id,
        title: deal.title,
        raceType: deal.raceType,
        dealValue: double.tryParse(deal.dealValue) ?? 0.0,
        commissionAmount: double.tryParse(deal.commission) ?? 0.0,

        commissionPercentage: 0, // You can calculate or add this field
        renewalReminder: "1 Day Before",
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        parts: deal.parts,
        brandingImageUrls: [],
        status: deal.status,
        sponsorInitials:
            deal.title.split(" ").first.substring(0, 2).toUpperCase(),
        racerInitials: deal.title.split(" ").last.substring(0, 2).toUpperCase(),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        Images.homeScreen,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 240,
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
                                      child: Image.network(
                                        Images.sponser1,
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Deals",
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
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding,
                            ),
                            child: TextFormField(
                              controller:
                                  _searchController, // Link controller to search bar
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText:
                                    "Search Sponsors, Racers...", // Search hint text
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.black,
                                  size: 16,
                                ), // Search icon
                                filled: true,
                                fillColor:
                                    Colors.white, // Search bar background
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(60),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding,
                              vertical: 8.0,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: _navigateToAddDealScreen,
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 16,
                                ), // Add icon
                                label: const Text(
                                  "Make a New Deal", // Button text
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(
                                    0xFFFFCC29,
                                  ), // Use your yellow button color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      60,
                                    ), // Rounded button
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _filteredDeals.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? "No deals available."
                              : "No deals found for '${_searchController.text}'.",
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _filteredDeals.length,
                        itemBuilder: (context, index) {
                          final deal = _filteredDeals[index];
                          return DealCardItem(
                            deal: deal,
                            fetchDealDetail: _fetchDealDetailItemById,
                          );
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
