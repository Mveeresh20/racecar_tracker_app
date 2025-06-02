import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_sponsor_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/profile_page.dart';

import 'package:racecar_tracker/Presentation/Widgets/sponsor_card_item.dart';
import 'package:racecar_tracker/Services/edit_profile_provider.dart';
import 'package:racecar_tracker/Services/sponsor_provider.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SponsorsScreen extends StatefulWidget {
  const SponsorsScreen({super.key});

  @override
  State<SponsorsScreen> createState() => _SponsorsScreenState();
}

class _SponsorsScreenState extends State<SponsorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Sponsor> _filteredSponsors = [];
  bool _isInitialized = false;
  String? _currentUserId;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view sponsors')),
        );
      }
      return;
    }

    // If we're already initialized for this user, don't reinitialize
    if (_isInitialized && userId == _currentUserId) {
      return;
    }

    setState(() {
      _filteredSponsors = [];
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
          _filteredSponsors = sponsorProvider.sponsors;
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
    _searchController.removeListener(_filterSponsors);
    _searchController.dispose();
    // Clear sponsors when screen is disposed
    Provider.of<SponsorProvider>(context, listen: false).logout();
    super.dispose();
  }

  void _filterSponsors() {
    if (!mounted) return;

    final query = _searchController.text.toLowerCase();
    final sponsors =
        Provider.of<SponsorProvider>(context, listen: false).sponsors;

    setState(() {
      if (query.isEmpty) {
        _filteredSponsors = sponsors;
      } else {
        _filteredSponsors =
            sponsors.where((sponsor) {
              final nameMatches = sponsor.name.toLowerCase().contains(query);
              final emailMatches = sponsor.email.toLowerCase().contains(query);
              final industryMatches =
                  sponsor.industryType?.toLowerCase().contains(query) ?? false;
              return nameMatches || emailMatches || industryMatches;
            }).toList();
      }
    });
  }

  // Function to get deal items for a sponsor
  List<DealItem> _getDealItemsForSponsor(String sponsorName) {
    // TODO: Implement actual deal items fetching from your service
    // For now, return an empty list
    return [];
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

          // Update filtered sponsors when provider data changes
          if (_filteredSponsors.isEmpty) {
            _filteredSponsors = sponsorProvider.sponsors;
          }

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
                                    child: Icon(
                                      Icons.business,
                                      size: 20,
                                      color: Colors.white,
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
                                          height: 24,
                                          width: 24,
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
                    _filteredSponsors.isEmpty
                        ? Center(
                          child: Text(
                            'No sponsors available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _filteredSponsors.length,
                          itemBuilder: (context, index) {
                            return SponsorCardItem(
                              sponsor: _filteredSponsors[index],
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
