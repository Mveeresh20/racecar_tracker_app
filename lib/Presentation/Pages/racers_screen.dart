import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_racer_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/racer_details_screen.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/race_card_item.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/models/deal_item.dart';

import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/event.dart';

class RacersScreen extends StatefulWidget {
  const RacersScreen({super.key});

  @override
  State<RacersScreen> createState() => _RacersScreenState();
}

class _RacersScreenState extends State<RacersScreen> {
  int _currentIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  List<Racer> _allRacers = []; // Your full list of racers
  List<Racer> _filteredRacers = []; // The list shown in the UI

  // Add a static sample events list for the dropdown
  final List<Event> _sampleEvents = [
    Event(
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
    Event(
      raceName: "Drift Race",
      type: "Drift",
      location: "Drift Track",
      title: "Jersey Annual Series",
      raceType: "Drift Race",
      dateTime: DateTime(2025, 6, 29, 11, 0),
      trackName: "Drift Track",
      currentRacers: 7,
      maxRacers: 18,
      status: EventStatusType.registrationOpen,
      racerImageUrls: [],
      totalOtherRacers: 11,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _allRacers = _getSampleRacers(); // Initialize with sample data
    _filteredRacers = _allRacers; // Initially, show all racers
    _searchController.addListener(
      _filterRacers,
    ); // Listen for search bar changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRacers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterRacers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRacers = _allRacers;
      } else {
        _filteredRacers =
            _allRacers.where((racer) {
              // Search by name, vehicle model, team, or current event
              final nameMatches = racer.name.toLowerCase().contains(query);
              final vehicleMatches = racer.vehicleModel.toLowerCase().contains(
                query,
              );
              final teamMatches = racer.teamName.toLowerCase().contains(query);
              final eventMatches = racer.currentEvent.toLowerCase().contains(
                query,
              );
              return nameMatches ||
                  vehicleMatches ||
                  teamMatches ||
                  eventMatches;
            }).toList();
      }
    });
  }

  List<Racer> _getSampleRacers() {
    return [
      Racer(
        contactNumber: "+88 1234567890", // Example data
        vehicleNumber: "WB 22 F2004", // Example data
        activeRaces: 2,
        totalRaces: 15,

        initials: "WB",
        vehicleImageUrl: Images.raceCar1, // Example Blue Car
        name: "Wayne Brotzký",
        vehicleModel: "Ferrari F2004",
        teamName: "Speed Rebels",
        currentEvent: "Summer GP 2025",
        earnings: "\$5,200",
      ),
      Racer(
        contactNumber: "+88 1545246988", // Matches Racer Detail screen
        vehicleNumber: "MJ 25 GT 1205", // Matches Racer Detail screen
        activeRaces: 2, // Matches Racer Detail screen
        totalRaces: 12,
        initials: "JM",
        vehicleImageUrl: Images.raceCar2, // Example Yellow Car
        name: "Jonathan Lauren",
        vehicleModel: "Ferrari F2004",
        teamName: "Speed Rebels",
        currentEvent: "Summer GP 2025",
        earnings: "\$2,700",
      ),
      Racer(
        contactNumber: "+88 9876543210",
        vehicleNumber: "SA 07 MW11",
        activeRaces: 1,
        totalRaces: 8,
        initials: "AH",
        vehicleImageUrl: Images.raceCar1,
        name: "Alice Hiller",
        vehicleModel: "McLaren MP4",
        teamName: "Velocity Vipers",
        currentEvent: "Drift Challenge",
        earnings: "\$3,500",
      ),
      Racer(
        contactNumber: "+88 9876543210",
        vehicleNumber: "SA 07 MW11",
        activeRaces: 1,
        totalRaces: 8,
        initials: "MS",
        vehicleImageUrl: Images.raceCar2,
        name: "Max Speed",
        vehicleModel: "Porsche 911",
        teamName: "Turbo Titans",
        currentEvent: "Circuit Race",
        earnings: "\$7,800",
      ),
      Racer(
        contactNumber: "+88 9876543210",
        vehicleNumber: "SA 07 MW11",
        activeRaces: 1,
        totalRaces: 8,
        initials: "MS",
        vehicleImageUrl: Images.raceCar1, // Example Red Car
        name: "Max Speed",
        vehicleModel: "Porsche 911",
        teamName: "Turbo Titans",
        currentEvent: "Circuit Race",
        earnings: "\$7,800",
      ),
      // Add more sample racers as needed
    ];
  }

  List<DealItem> _getDealItemsForRacer(String racerName) {
    switch (racerName) {
      case "Wayne Brotzký":
        return [
          DealItem(
            id: "1",

            title: "Wayne Brotzký X DC Autos", // Matches screenshot
            raceType: "Summer Race", // Matches screenshot
            dealValue: "\$1500", // Matches screenshot
            commission: "30", // No commission shown in screenshot for this deal
            renewalDate: "June 2026", // Matches screenshot
            parts: [], // No parts shown in screenshot for this deal
            status: DealStatusType.pending, // Matches screenshot
          ),
          DealItem(
            id: "2",

            title: "Wayne Brotzký X Sarah White", // Matches screenshot
            raceType: "Summer Race", // Matches screenshot
            dealValue: "\$1500", // Matches screenshot
            commission: "20%", // Matches screenshot
            renewalDate: "June 2026", // Matches screenshot
            parts: [], // No parts shown in screenshot for this deal
            status: DealStatusType.pending, // Matches screenshot
          ),
          // Add more deals for John Maeve if necessary
        ];
      case "Alice Hiller":
        return [
          DealItem(
            id: "3",

            title: "Wayne Brotzký X Speedy Sponsors",
            raceType: "Winter Rally",
            dealValue: "\$2500",
            commission: "12%",
            renewalDate: "Jan 2026",
            parts: ["Engine Parts"],
            status: DealStatusType.paid,
          ),
        ];
      default:
        return []; // No deals found for other racers
    }
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
                                        Images.helmet,
                                        color: Colors.white,
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Racers",
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
                                    "Search Racers...", // Search hint text
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
                                onPressed: () async {
                                  // Add New Racer and refresh list
                                  final newRacer = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddNewRacerScreen(
                                            events: _sampleEvents,
                                          ),
                                    ),
                                  );
                                  if (newRacer != null && newRacer is Racer) {
                                    setState(() {
                                      _allRacers.add(newRacer);
                                      _filterRacers();
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 16,
                                ), // Add icon
                                label: const Text(
                                  "Add New Racer", // Button text
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

                SizedBox(height: 16),

                _filteredRacers.isEmpty
                    ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? "No racers available."
                            : "No racers found for '${_searchController.text}'.",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    )
                    : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 0,
                      ), // Adjust padding for grid
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0, // Spacing between columns
                        mainAxisSpacing: 10, // Spacing between rows
                        childAspectRatio:
                            0.48, // Adjust to fit card content (width/height ratio)
                      ),
                      itemCount: _filteredRacers.length,
                      itemBuilder: (context, index) {
                        final racer = _filteredRacers[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to RacerDetailsScreen with racer data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RacerDetailsScreen(
                                      racer: racer,
                                      racerDealItems: _getDealItemsForRacer(
                                        racer.name,
                                      ),
                                    ),
                              ),
                            );
                          },
                          child: RacerCardItem(
                            racer: racer,
                            getDealItemsForRacer: _getDealItemsForRacer,
                          ),
                        );
                      },
                    ),
                SizedBox(height: 100),
              ],
            ),
          ],
        ),
      ),
    
    );
  }

  
}
