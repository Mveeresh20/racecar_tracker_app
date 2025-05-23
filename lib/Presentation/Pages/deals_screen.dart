import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/deal_car_item.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/models/deal_item.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  int _currentIndex = 4;

   final TextEditingController _searchController = TextEditingController();
  List<DealItem> _allDeals = []; // Your full list of deals
  List<DealItem> _filteredDeals = []; // The list shown in the UI

  @override
  void initState() {
    super.initState();
    _allDeals = _getSampleDeals(); // Initialize with sample data
    _filteredDeals = _allDeals; // Initially, show all deals
    _searchController.addListener(_filterDeals); // Listen for search bar changes
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
          final raceTypeMatches = deal.raceType.toLowerCase().contains(query);
          final partsMatches = deal.parts.any((part) => part.toLowerCase().contains(query));
          return titleMatches || raceTypeMatches || partsMatches;
        }).toList();
      }
    });
  }

  // --- Sample Deal Data (Replace with your actual data source) ---
  List<DealItem> _getSampleDeals() {
    return [
      DealItem(
        title: "ABC Motors X Sarah White",
        raceType: "Summer Race",
        dealValue: "\$1500",
        commission: "10%",
        renewalDate: "June 2026",
        parts: ["Car Doors", "Suit"],
        status: DealStatusType.pending,
      ),
      DealItem(
        title: "DC Auto X Jonathan Meave",
        raceType: "Drift Race",
        dealValue: "\$8000",
        commission: "15%",
        renewalDate: "August 2026",
        parts: ["Hood", "Suit", "Side Doors"],
        status: DealStatusType.paid,
      ),
      DealItem(
        title: "Formula One Corp X Max Speed",
        raceType: "Grand Prix",
        dealValue: "\$12000",
        commission: "20%",
        renewalDate: "July 2027",
        parts: ["Aerodynamics", "Engine"],
        status: DealStatusType.pending,
      ),
      DealItem(
        title: "Turbo Chargers Inc X Alice Race",
        raceType: "Circuit Race",
        dealValue: "\$5000",
        commission: "12%",
        renewalDate: "April 2026",
        parts: ["Turbo Kit", "Exhaust"],
        status: DealStatusType.paid,
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
                                fillColor: Colors.white, // Search bar background
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _filteredDeals.length,
                        itemBuilder: (context, index) {
                          final deal = _filteredDeals[index];
                          return DealCardItem(deal: deal);
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
