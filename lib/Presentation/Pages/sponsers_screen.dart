import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/sponsor_card_item.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/models/sponsor.dart';

class SponsersScreen extends StatefulWidget {
  const SponsersScreen({super.key});

  @override
  State<SponsersScreen> createState() => _SponsersScreenState();
}

class _SponsersScreenState extends State<SponsersScreen> {
  int _currentIndex = 3;
  final TextEditingController _searchController = TextEditingController();
  List<Sponsor> _allSponsors = []; // Your full list of sponsors
  List<Sponsor> _filteredSponsors = []; // The list shown in the UI

  @override
  void initState() {
    super.initState();
    _allSponsors = _getSampleSponsors(); // Initialize with sample data
    _filteredSponsors = _allSponsors; // Initially, show all sponsors
    _searchController.addListener(
      _filterSponsors,
    ); // Listen for search bar changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSponsors);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSponsors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSponsors = _allSponsors;
      } else {
        _filteredSponsors =
            _allSponsors.where((sponsor) {
              // Search by name, email, or parts
              final nameMatches = sponsor.name.toLowerCase().contains(query);
              final emailMatches = sponsor.email.toLowerCase().contains(query);
              final partsMatches = sponsor.parts.any(
                (part) => part.toLowerCase().contains(query),
              );
              return nameMatches || emailMatches || partsMatches;
            }).toList();
      }
    });
  }

  // --- Sample Sponsor Data (Replace with your actual data source) ---
  List<Sponsor> _getSampleSponsors() {
    return [
      Sponsor(
        initials: "DC",
        name: "DC Autos",
        email: "john@dcauto.com",
        parts: ["Car Doors", "Rear Bumper", "Suit"],
        activeDeals: 2,
        endDate: DateTime(2025, 6, 15),
        status: SponsorStatus.active,
      ),
      Sponsor(
        initials: "AB",
        name: "ABC Motors",
        email: "abcmotors@gmail.com",
        parts: ["Car Hood", "Side Doors", "Front Wing"],
        activeDeals: 1,
        endDate: DateTime(2025, 6, 23),
        status: SponsorStatus.renewSoon,
      ),
      Sponsor(
        initials: "KA",
        name: "Kane Automobiles",
        email: "kane@am.com",
        parts: ["Car Doors", "Suit"],
        activeDeals: 2,
        endDate: DateTime(2025, 6, 15),
        status: SponsorStatus.renewSoon,
      ),
      Sponsor(
        initials: "GT",
        name: "Grand Touring Solutions",
        email: "info@gt.com",
        parts: ["Tires", "Suspension", "Brakes"],
        activeDeals: 3,
        endDate: DateTime(2026, 1, 1),
        status: SponsorStatus.active,
      ),
      Sponsor(
        initials: "SP",
        name: "Speed Parts Co.",
        email: "sales@speedparts.com",
        parts: ["Engine Blocks", "Turbo Chargers"],
        activeDeals: 1,
        endDate: DateTime(2025, 9, 30),
        status: SponsorStatus.active,
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
                                      child: Image.network(
                                        Images.sponser1,
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Sponsers",
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
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: TextFormField(
                  
                  
                  
                  controller: _searchController, // Link controller to search bar
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    
                    hintText: "Search Sponsors...", // Search hint text
                    hintStyle: TextStyle(fontSize: 12,fontWeight: FontWeight.w600,color: Colors.black),
                    prefixIcon: const Icon(Icons.search, color: Colors.black,size: 16,), // Search icon
                    filled: true,
                    fillColor: Colors.white, // Search bar background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle Add Sponsor button tap
                  print("Add Sponsor button tapped!");
                },
                icon: const Icon(Icons.add, color: Colors.black,size: 16,), // Add icon
                label: const Text(
                  "Add Sponsor", // Button text
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700,fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFCC29), // Use your yellow button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60), // Rounded button
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                 _filteredSponsors.isEmpty
                     ? Center(
                         child: Text(
                           _searchController.text.isEmpty
                               ? "No sponsors available."
                               : "No sponsors found for '${_searchController.text}'.",
                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                         ),
                       )
                     : ListView.builder(
                       shrinkWrap: true,
                       physics: NeverScrollableScrollPhysics(),
                         padding: EdgeInsets.zero, // Remove default ListView padding
                         itemCount: _filteredSponsors.length,
                         itemBuilder: (context, index) {
                           final sponsor = _filteredSponsors[index];
                           return SponsorCardItem(sponsor: sponsor);
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
