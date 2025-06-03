import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_deal_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/profile_page.dart';
import 'package:racecar_tracker/Presentation/Pages/sponsers_screen.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/deal_card_item.dart';
import 'package:racecar_tracker/Services/deal_service.dart';
import 'package:racecar_tracker/Services/edit_profile_provider.dart';
import 'package:racecar_tracker/Services/event_service.dart';
import 'package:racecar_tracker/Services/racer_service.dart';
import 'package:racecar_tracker/Services/sponsor_service.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/models/deal_detail_item.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  final _searchController = TextEditingController();
  final _dealService = DealService();
  List<DealItem> _filteredDeals = [];
  bool _isLoading = true;
  String? _error;
  final _racerService = RacerService();
  final _eventService = EventService();
  final _sponsorService = SponsorService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDeals);
    _loadDeals();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditProfileProvider>(
        context,
        listen: false,
      ).fetchUserProfileDetails();
    });
  }

  void _loadDeals() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _error = 'No user logged in';
        _isLoading = false;
      });
      return;
    }

    _dealService
        .streamDeals(userId)
        .listen(
          (deals) {
            if (mounted) {
              setState(() {
                _filteredDeals = deals;
                _isLoading = false;
              });
              _filterDeals();
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _error = error.toString();
                _isLoading = false;
              });
            }
          },
        );
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
        _filteredDeals = List.from(_filteredDeals);
      } else {
        _filteredDeals =
            _filteredDeals.where((deal) {
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

  Future<void> _navigateToAddDealScreen() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      print('Starting navigation to AddNewDealScreen');
      print('Fetching data for user: $userId');

      // Load all required data first using streams
      final racers = await _racerService.getRacersStream(userId).first;
      print('Loaded ${racers.length} racers');

      final events = await _eventService.getUserEvents(userId).first;
      print('Loaded ${events.length} events');

      final sponsors = await _sponsorService.getSponsorsStream(userId).first;
      print('Loaded ${sponsors.length} sponsors');

      if (!mounted) return;

      // Check if we have all required data
      if (racers.isEmpty) {
        throw Exception('No racers available. Please add a racer first.');
      }
      if (events.isEmpty) {
        throw Exception('No events available. Please add an event first.');
      }
      if (sponsors.isEmpty) {
        throw Exception('No sponsors available. Please add a sponsor first.');
      }

      // Navigate to AddNewDealScreen
      final newDeal = await Navigator.push<DealItem>(
        context,
        MaterialPageRoute(
          builder:
              (context) => AddNewDealScreen(
                sponsors: sponsors,
                racers: racers,
                events: events,
              ),
        ),
      );

      if (!mounted) return;

      if (newDeal != null) {
        print('Deal created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal created successfully')),
        );
      }
    } catch (e) {
      print('Error in _navigateToAddDealScreen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<DealDetailItem?> Function(String) _fetchDealDetailItemById(String id) {
    return (String id) async {
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          print('No user logged in when trying to fetch deal detail');
          return null;
        }

        // Get the deal detail from Firebase
        final dealDetail = await _dealService.getDeal(id);
        if (dealDetail == null) {
          print('No deal detail found for id: $id for user: $userId');
          return null;
        }

        return dealDetail;
      } catch (e) {
        print('Error fetching deal detail: $e');
        return null;
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171E45),
      body: SingleChildScrollView(
        child: Column(
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D5586), Color(0xFF171E45)],
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
                                const SizedBox(width: 10),
                                const Text(
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
                                        builder:
                                            (context) => const ProfilePage(),
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
                                    padding: const EdgeInsets.all(2),
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                        ),
                        child: TextFormField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Search Sponsors, Racers...",
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
                            onPressed: _navigateToAddDealScreen,
                            icon: const Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 16,
                            ),
                            label: const Text(
                              "Make a New Deal",
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
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: $_error',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDeals,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_filteredDeals.isEmpty)
              Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? "No deals available."
                      : "No deals found for '${_searchController.text}'.",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _filteredDeals.length,
                itemBuilder: (context, index) {
                  final deal = _filteredDeals[index];
                  return DealCardItem(
                    deal: deal,
                    fetchDealDetail: _fetchDealDetailItemById(deal.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
