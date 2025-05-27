import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/event_card_item.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/models/event.dart';

class RaceEvetsScreen extends StatefulWidget {
  const RaceEvetsScreen({super.key});

  @override
  State<RaceEvetsScreen> createState() => _RaceEvetsScreenState();
}

class _RaceEvetsScreenState extends State<RaceEvetsScreen> {
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  List<Event> _allEvents = []; // Your full list of events
  List<Event> _filteredEvents = []; // The list shown in the UI

  @override
  void initState() {
    super.initState();
    _allEvents = _getSampleEvents(); // Initialize with sample data
    _filteredEvents = _allEvents; // Initially, show all events
    _searchController.addListener(
      _filterEvents,
    ); // Listen for search bar changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterEvents);
    _searchController.dispose();
    super.dispose();
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEvents = _allEvents;
      } else {
        _filteredEvents =
            _allEvents.where((event) {
              // Search by title, race type, or track name
              final titleMatches = event.title.toLowerCase().contains(query);
              final raceTypeMatches = event.raceType.toLowerCase().contains(
                query,
              );
              final trackNameMatches = event.trackName.toLowerCase().contains(
                query,
              );
              return titleMatches || raceTypeMatches || trackNameMatches;
            }).toList();
      }
    });
  }

  // --- Sample Event Data (Replace with your actual data source) ---
  List<Event> _getSampleEvents() {
    return [
      Event(
        raceName: "Circuit Race",
        type: "Summer Race",
        location: "Longmilan track",
        title: "Summer GP Thunder Series",
        raceType: "Summer Race",
        dateTime: DateTime(2025, 6, 20, 22, 0), // 10:00 PM
        trackName: "Longmilan track",
        currentRacers: 10,
        maxRacers: 16,
        status: EventStatusType.registrationOpen,
        racerImageUrls: [
          'https://via.placeholder.com/50/FF0000',
          'https://via.placeholder.com/50/0000FF',
          'https://via.placeholder.com/50/00FF00',
          'https://via.placeholder.com/50/FFFF00',
          'https://via.placeholder.com/50/FFFF00',

          'https://via.placeholder.com/50/FFFF00',
          'https://via.placeholder.com/50/FFFF00',
          'https://via.placeholder.com/50/FFFF00',
          'https://via.placeholder.com/50/FFFF00',
          'https://via.placeholder.com/50/FFFF00',
          'https://via.placeholder.com/50/FFFF00',
          'https://via.placeholder.com/50/FFFF00',
        ],
        totalOtherRacers: 6, // 10 current + 6 others = 16 max
      ),
      Event(
        raceName: "Drift Race",
        type: "Summer Race",
        location: "Longmilan track",
        title: "Jersey Annual Series",
        raceType: "Drift Race",
        dateTime: DateTime(2025, 6, 29, 11, 0), // 11:00 AM
        trackName: "Drift Track",
        currentRacers: 7,
        maxRacers: 18,
        status: EventStatusType.registrationOpen, // Example: this one is open
        racerImageUrls: [
          'https://via.placeholder.com/50/FFC0CB',
          'https://via.placeholder.com/50/800080',
          'https://via.placeholder.com/50/00FFFF',
        ],
        totalOtherRacers: 11, // 7 current + 11 others = 18 max
      ),
      Event(
        raceName: "Circuit Race",
        type: "Summer Race",
        location: "Longmilan track",
        title: "Autumn Speed Fest",
        raceType: "Grand Prix",
        dateTime: DateTime(2025, 9, 10, 14, 0), // 2:00 PM
        trackName: "Highland Raceway", // Assuming another track
        currentRacers: 5,
        maxRacers: 10,
        status:
            EventStatusType.registrationClosed, // Example: this one is closed
        racerImageUrls: [
          'https://via.placeholder.com/50/FFD700',
          'https://via.placeholder.com/50/ADFF2F',
        ],
        totalOtherRacers: 5,
      ),
      Event(
        raceName: "Circuit Race",
        type: "Summer Race",
        location: "Longmilan track",
        title: "Winter Endurance Challenge",
        raceType: "Charity Run",
        dateTime: DateTime(2025, 12, 5, 9, 30), // 9:30 AM
        trackName: "Snowy Peaks Course", // Assuming another track
        currentRacers: 15,
        maxRacers: 20,
        status: EventStatusType.registrationOpen,
        racerImageUrls: [
          'https://via.placeholder.com/50/FF4500',
          'https://via.placeholder.com/50/4682B4',
          'https://via.placeholder.com/50/9932CC',
          'https://via.placeholder.com/50/DAA520',
        ],
        totalOtherRacers: 5,
      ),
    ];
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
                                      child: Icon(
                                        Icons.flag,
                                        size: 20,
                                        color: Colors.white,
                                      )
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Events",
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
                                    "Search Events...", // Search hint text
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
                                onPressed: () {
                                  // Handle Add Sponsor button tap
                                  print("Add Sponsor button tapped!");
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 16,
                                ), // Add icon
                                label: const Text(
                                  "Add New Race Event", // Button text
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
                const SizedBox(height: 16),

                _filteredEvents.isEmpty
                    ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? "No race events available."
                            : "No race events found for '${_searchController.text}'.",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        return EventCardItem(event: event);
                      },
                    ),
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
