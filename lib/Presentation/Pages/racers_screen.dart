import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_racer_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/racer_details_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/profile_page.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/racer_card_item.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/Constants/text.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/Services/racer_provider.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Services/edit_profile_provider.dart';
import 'package:racecar_tracker/Services/event_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RacersScreen extends StatefulWidget {
  const RacersScreen({super.key});

  @override
  State<RacersScreen> createState() => _RacersScreenState();
}

class _RacersScreenState extends State<RacersScreen> {
  int _currentIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRacers);
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRacers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final currentUserId = _userService.getCurrentUserId();
    if (currentUserId == null) {
      print('No user ID found');
      return;
    }

    // Initialize racers
    await Provider.of<RacerProvider>(
      context,
      listen: false,
    ).initializeRacers(currentUserId);

    // Initialize events
    await Provider.of<EventProvider>(
      context,
      listen: false,
    ).initUserEvents(currentUserId);

    setState(() {
      _isInitialized = true;
    });
  }

  void _filterRacers() {
    if (mounted) {
      setState(() {}); // Trigger rebuild
    }
  }

  List<DealItem> _getDealItemsForRacer(String racerName) {
    // TODO: Implement real deal items from DealService
    // For now, return empty list as we'll implement this next
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<RacerProvider, EventProvider>(
        builder: (context, racerProvider, eventProvider, child) {
          if (!_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (racerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (racerProvider.error != null) {
            return Center(
              child: Text(
                'Error: ${racerProvider.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          // Get the current list of racers from the provider
          final allRacers = racerProvider.racers;

          // Apply filtering based on the search query
          final query = _searchController.text.toLowerCase();
          final displayedRacers =
              query.isEmpty
                  ? allRacers
                  : allRacers.where((racer) {
                    final nameMatches = racer.name.toLowerCase().contains(
                      query,
                    );
                    final vehicleMatches = racer.vehicleModel
                        .toLowerCase()
                        .contains(query);
                    final teamMatches = racer.teamName.toLowerCase().contains(
                      query,
                    );
                    final eventMatches = racer.currentEvent
                        .toLowerCase()
                        .contains(query);
                    return nameMatches ||
                        vehicleMatches ||
                        teamMatches ||
                        eventMatches;
                  }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
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
                                  const Color(0xFF2D5586).withOpacity(0.4),
                                  const Color(0xFF171E45).withOpacity(0.4),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Image.network(
                                            Images.helmet,
                                            color: Colors.white,
                                            height: 30,
                                            width: 30,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
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
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              provider.getProfileImageUrl(),
                                          height: 30,
                                          width: 30,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Container(
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.person,
                                                      size: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                                    
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding,
                                ),
                                child: TextFormField(
                                  controller: _searchController,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: "Search Racers...",
                                    hintStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
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
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const AddNewRacerScreen(),
                                        ),
                                      );
                                      if (result == true) {
                                        // The racer will be automatically added to the list
                                        // through the real-time stream
                                        _filterRacers();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      "Add New Racer",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFCC29),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(60),
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
                    displayedRacers.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child:
                                _searchController.text.isEmpty
                                    ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          Images.noRacer,
                                          fit: BoxFit.contain,
                                          height: 280,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "🏎️ No Racers Added Yet!",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          Lorempsum.noRaceEventText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )
                                    : Text(
                                      "No racers found for '${_searchController.text}'.",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.white70),
                                      textAlign: TextAlign.center,
                                    ),
                          ),
                        )
                        : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 0,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.48,
                              ),
                          itemCount: displayedRacers.length,
                          itemBuilder: (context, index) {
                            final racer = displayedRacers[index];
                            return GestureDetector(
                              onTap: () {
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
                    const SizedBox(height: 100),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
