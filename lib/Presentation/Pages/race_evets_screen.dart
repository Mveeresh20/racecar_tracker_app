import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/profile_page.dart';
import 'package:racecar_tracker/Presentation/Views/add_new_event_screen.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/event_card_item.dart';
import 'package:racecar_tracker/Services/edit_profile_provider.dart';
import 'package:racecar_tracker/Services/event_provider.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/Constants/text.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RaceEvetsScreen extends StatefulWidget {
  const RaceEvetsScreen({super.key});

  @override
  State<RaceEvetsScreen> createState() => _RaceEvetsScreenState();
}

class _RaceEvetsScreenState extends State<RaceEvetsScreen> {
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEvents);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userId = UserService().getCurrentUserId();

    // If we're already initialized for this user, don't reinitialize
    if (_isInitialized && userId == _currentUserId) {
      return;
    }

    // Clear existing data
    setState(() {
      _isInitialized = false;
    });

    if (userId == null) {
      return;
    }

    _currentUserId = userId;

    try {
      // Initialize profile
      await Provider.of<EditProfileProvider>(
        context,
        listen: false,
      ).fetchUserProfileDetails();

      // Initialize events
      await Provider.of<EventProvider>(
        context,
        listen: false,
      ).initUserEvents(userId);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error initializing data: $e')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterEvents);
    _searchController.dispose();
    // Clear events when screen is disposed
    Provider.of<EventProvider>(context, listen: false).logout();
    super.dispose();
  }

  void _filterEvents() {
    if (mounted) {
      setState(() {}); // Trigger rebuild
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventProvider.error != null) {
            return Center(child: Text('Error: ${eventProvider.error}'));
          }

          // Get the current list of events from the provider
          final allEvents = eventProvider.events;

          // Apply filtering based on the search query
          final query = _searchController.text.toLowerCase();
          final displayedEvents =
              query.isEmpty
                  ? allEvents
                  : allEvents.where((event) {
                    final titleMatches = event.name.toLowerCase().contains(
                      query,
                    );
                    final raceTypeMatches = event.type.toLowerCase().contains(
                      query,
                    );
                    final trackNameMatches = event.location
                        .toLowerCase()
                        .contains(query);
                    return titleMatches || raceTypeMatches || trackNameMatches;
                  }).toList();

          return Column(
            children: [
              // Header with background image
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
                        // Header with title and profile
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
                                    child: Image.network(Images.navBarImg),
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

                        SizedBox(height: 20),

                        // Search bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding,
                          ),
                          child: TextFormField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: "Search Events...",
                              hintStyle: TextStyle(
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

                        // Add New Event button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding,
                            vertical: 8.0,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNewEventScreen(),
                                  ),
                                );
                                // Refresh events after returning
                                final userId = UserService().getCurrentUserId();
                                if (userId != null) {
                                  eventProvider.initUserEvents(userId);
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 16,
                              ),
                              label: const Text(
                                "Add New Race Event",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFFCC29),
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

              // Events list or empty state
              Expanded(
                child:
                    displayedEvents.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                          
                                children: [
                                  Image.network(
                                    Images.noRaceEvent,
                                    fit: BoxFit.contain,
                                    height: 280,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "🏁No Race Events Yet!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 12),
                                          
                                  Text(
                                    Lorempsum.noRaceEventText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                          ),
                        )
                        : ListView.builder(
                          itemCount: displayedEvents.length,
                          itemBuilder: (context, index) {
                            return EventCardItem(event: displayedEvents[index]);
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
