import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_sponsor_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/profile_page.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Presentation/Widgets/sponsor_card_item.dart';
import 'package:racecar_tracker/Services/deal_service.dart';
import 'package:racecar_tracker/Services/edit_profile_provider.dart';
import 'package:racecar_tracker/Services/sponsor_provider.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/Constants/text.dart';
import 'package:racecar_tracker/Utils/snackbar_helper.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class SponsorsScreen extends StatefulWidget {
  const SponsorsScreen({super.key});

  @override
  State<SponsorsScreen> createState() => _SponsorsScreenState();
}

class _SponsorsScreenState extends State<SponsorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;
  String? _currentUserId;
  final DealService _dealService = DealService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSponsors);
    // Initialize data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when dependencies change, like when the provider updates
    if (!_isInitialized) {
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    final userId = UserService().getCurrentUserId();
    if (userId == null) {
      if (mounted) {
        SnackbarHelper.showInfo(context, 'Please log in to view sponsors');
      }
      return;
    }

    // If we're already initialized for this user, don't reinitialize
    if (_isInitialized && userId == _currentUserId) {
      return;
    }

    setState(() {
      _isInitialized = false;
    });

    _currentUserId = userId;

    try {
      // Initialize profile
      await Provider.of<EditProfileProvider>(
        context,
        listen: false,
      ).fetchUserProfileDetails();

      // Initialize sponsors
      final sponsorProvider = Provider.of<SponsorProvider>(
        context,
        listen: false,
      );
      await sponsorProvider.initUserSponsors(userId);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Unable to load sponsors. Please try again.',
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSponsors);
    _searchController.dispose();
    // Clear sponsors when screen is disposed
    Provider.of<SponsorProvider>(context, listen: false).logout();
    super.dispose();
  }

  void _filterSponsors() {
    if (mounted) {
      setState(() {});
    }
  }

  // Function to get deal items for a sponsor
  Stream<List<DealItem>> _getDealItemsForSponsor(String sponsorName) {
    final userId = UserService().getCurrentUserId();
    if (userId == null) {
      print('No user logged in when trying to get deals');
      return Stream.value([]);
    }

    // Find the sponsor ID from the name
    final sponsorProvider = Provider.of<SponsorProvider>(
      context,
      listen: false,
    );
    final sponsor = sponsorProvider.sponsors.firstWhere(
      (s) => s.name == sponsorName,
      orElse: () => throw Exception('No sponsor found with name: $sponsorName'),
    );

    // Return the stream of deals for this sponsor
    return _dealService.streamDealsBySponsor(userId, sponsor.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SponsorProvider>(
        builder: (context, sponsorProvider, child) {
          if (!_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sponsorProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sponsorProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${sponsorProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Get the current list of sponsors from the provider
          final allSponsors = sponsorProvider.sponsors;

          // Apply filtering based on the search query
          final query = _searchController.text.toLowerCase();
          final displayedSponsors =
              query.isEmpty
                  ? allSponsors
                  : allSponsors.where((sponsor) {
                    final nameMatches = sponsor.name.toLowerCase().contains(
                      query,
                    );
                    final emailMatches = sponsor.email.toLowerCase().contains(
                      query,
                    );
                    final industryMatches =
                        sponsor.industryType?.toLowerCase().contains(query) ??
                        false;
                    return nameMatches || emailMatches || industryMatches;
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
                                    child: Image.network(
                                      Images.sponser1,
                                      height: 30,
                                      width: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Sponsors",
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
                              hintText: "Search Sponsors...",
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

                        // Add New Sponsor button
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
                                    builder:
                                        (context) => AddNewSponsorScreen(
                                          provider: sponsorProvider,
                                        ),
                                  ),
                                );
                                // Refresh sponsors after returning
                                final userId = UserService().getCurrentUserId();
                                if (userId != null) {
                                  sponsorProvider.initUserSponsors(userId);
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 16,
                              ),
                              label: const Text(
                                "Add New Sponsor",
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

              // Sponsors list or empty state
              Expanded(
                child:
                    displayedSponsors.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Image.network(
                                  Images.noSponsor,
                                  fit: BoxFit.contain,
                                  height: 280,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "💼 No Sponsors Added Yet!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),

                                Text(
                                  Lorempsum.noSponsorText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: displayedSponsors.length,
                          itemBuilder: (context, index) {
                            return SponsorCardItem(
                              sponsor: displayedSponsors[index],
                              getDealItemsForSponsor: _getDealItemsForSponsor,
                            );
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
