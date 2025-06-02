// import 'package:flutter/material.dart';
// import 'package:racecar_tracker/Presentation/Views/add_new_sponsor_screen.dart';
// import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
// import 'package:racecar_tracker/Presentation/Widgets/sponsor_card_item.dart';
// import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
// import 'package:racecar_tracker/Utils/Constants/images.dart';
// import 'package:racecar_tracker/models/deal_item.dart';
// import 'package:racecar_tracker/Services/edit_profile_provider.dart';
// import 'package:provider/provider.dart';

// import 'package:racecar_tracker/models/sponsor.dart';
// import 'package:racecar_tracker/models/racer.dart';
// import 'package:racecar_tracker/models/event.dart';

// class SponsersScreen extends StatefulWidget {
//   const SponsersScreen({super.key});

//   @override
//   State<SponsersScreen> createState() => _SponsersScreenState();
// }

// class _SponsersScreenState extends State<SponsersScreen> {
//   int _currentIndex = 3;
//   final TextEditingController _searchController = TextEditingController();
//   List<Sponsor> _allSponsors = []; // Your full list of sponsors
//   List<Sponsor> _filteredSponsors = []; // The list shown in the UI

//   @override
//   void initState() {
//     super.initState();
//     _allSponsors = getSampleSponsors(); // Initialize with sample data
//     _filteredSponsors = _allSponsors; // Initially, show all sponsors
//     _searchController.addListener(
//       _filterSponsors,
//     );
//     // Listen for search bar changes
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_filterSponsors);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _filterSponsors() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       if (query.isEmpty) {
//         _filteredSponsors = _allSponsors;
//       } else {
//         _filteredSponsors = _allSponsors.where((sponsor) {
//           // Search by name, email, or parts
//           final nameMatches = sponsor.name.toLowerCase().contains(query);
//           final emailMatches = sponsor.email.toLowerCase().contains(query);
//           final partsMatches = sponsor.parts.any(
//             (part) => part.toLowerCase().contains(query),
//           );
//           return nameMatches || emailMatches || partsMatches;
//         }).toList();
//       }
//     });
//   }

//   // In your Sponsors screen, when the "Add Sponsor" button is tapped:
//   void _navigateToAddSponsorScreen() async {
//     final newSponsor = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddNewSponsorScreen(),
//       ), // Replace with your AddNewSponsorScreen
//     );

//     if (newSponsor != null && newSponsor is Sponsor) {
//       setState(() {
//         _allSponsors.add(newSponsor); // Add the new sponsor to your list
//         _filterSponsors(); // Re-filter if search is active
//       });
//     }
//   }

//   // --- Sample Sponsor Data (Replace with your actual data source) ---
//   List<Sponsor> getSampleSponsors() {
//     return [
//       Sponsor(
//         id: "sponsor1",
//         initials: "DC",
//         name: "DC Autos",
//         email: "john@dcauto.com",
//         parts: ["Car Doors", "Rear Bumper", "Suit"],
//         activeDeals: 2,
//         endDate: DateTime(2025, 6, 15),
//         status: SponsorStatus.active,
//       ),
//       Sponsor(
        

//         id: "sponsor2",
//         initials: "AM",
//         name: "ABC Motors",
//         email: "contact@abcmotors.com",
//         parts: ["Car Doors", "Suit"],
//         activeDeals: 1,
//         endDate: DateTime(2026, 6, 1),
//         status: SponsorStatus.active,
//       ),
//       Sponsor(
//         id: "sponsor3",
//         initials: "KA",
//         name: "Kane Automobiles",
//         email: "info@kaneauto.com",
//         parts: ["Front Wing", "Tyres", "Spoiler"],
//         activeDeals: 2,
//         endDate: DateTime(2025, 11, 1),
//         status: SponsorStatus.active,
//       ),
//     ];
//   }

//   List<Racer> getSampleRacers() {
//     return [
//       Racer(
//         id: "racer1",
//         initials: "JM",
//         vehicleImageUrl: "https://via.placeholder.com/50/0000FF",
//         name: "Jonathan Meave",
//         vehicleModel: "Toyota Supra",
//         teamName: "Drift Kings",
//         currentEvent: "Drift Championship 2025",
//         earnings: "\$8,000",
//         contactNumber: "+88 9876543210",
//         vehicleNumber: "JM 42 SUPRA",
//         activeRaces: 1,
//         totalRaces: 8,
//       ),
//       Racer(
//         id: "racer2",
//         initials: "SW",
//         vehicleImageUrl: "https://via.placeholder.com/50/00FF00",
//         name: "Sarah White",
//         vehicleModel: "Honda Civic",
//         teamName: "Speed Queens",
//         currentEvent: "Summer GP 2025",
//         earnings: "\$1,500",
//         contactNumber: "+88 8765432109",
//         vehicleNumber: "SW 11 CIVIC",
//         activeRaces: 1,
//         totalRaces: 5,
//       ),
//     ];
//   }

//   List<Event> getSampleEvents() {
//     return [
//       Event(
//         userId: "478",

//         id: "event1",
//         raceName: "Drift Championship",
//         type: "Drift Race",
//         location: "Tokyo Drift Track",
//         title: "Drift Championship 2025",
//         raceType: "Drift Race",
//         dateTime: DateTime(2025, 8, 15, 20, 0),
//         trackName: "Tokyo Drift Track",
//         currentRacers: 8,
//         maxRacers: 16,
//         status: EventStatusType.registrationOpen,
//         racerImageUrls: [],
//         totalOtherRacers: 7,
//       ),
//       Event(
//         userId: "478",
//         id: "event2",
//         raceName: "Summer GP",
//         type: "Summer Race",
//         location: "Summer Circuit",
//         title: "Summer GP 2025",
//         raceType: "Summer Race",
//         dateTime: DateTime(2025, 6, 1, 15, 0),
//         trackName: "Summer Circuit",
//         currentRacers: 12,
//         maxRacers: 20,
//         status: EventStatusType.registrationOpen,
//         racerImageUrls: [],
//         totalOtherRacers: 11,
//       ),
//     ];
//   }

//   List<DealItem> _getDealItemsForSponsor(String sponsorName) {
//     switch (sponsorName) {
//       case "DC Autos":
//         return [
//           DealItem(
//             id: "2",
//             sponsorId: "sponsor1",
//             racerId: "racer1",
//             eventId: "event1",
//             title: "DC Autos X Jonathan Meave",
//             raceType: "Drift Race",
//             dealValue: "\$8000",
//             commission: "15%",
//             renewalDate: "August 2026",
//             parts: ["Hood", "Suit", "Side Doors"],
//             status: DealStatusType.paid,
//             sponsorInitials: "DA",
//             racerInitials: "JM",
//           ),
//         ];
//       case "ABC Motors":
//         return [
//           DealItem(
//             id: "3",
//             sponsorId: "sponsor2",
//             racerId: "racer2",
//             eventId: "event2",
//             title: "ABC Motors X Sarah White",
//             raceType: "Summer Race",
//             dealValue: "\$1500",
//             commission: "10%",
//             renewalDate: "June 2026",
//             parts: ["Car Doors", "Suit"],
//             status: DealStatusType.pending,
//             sponsorInitials: "AM",
//             racerInitials: "SW",
//           ),
//         ];
//       case "Kane Automobiles":
//         return [
//           DealItem(
//             id: "4",
//             sponsorId: "sponsor3",
//             racerId: "racer3",
//             eventId: "event3",
//             title: "Kane Automobiles X Racer One",
//             raceType: "Circuit Race",
//             dealValue: "\$2500",
//             commission: "18%",
//             renewalDate: "October 2025",
//             parts: ["Front Wing"],
//             status: DealStatusType.paid,
//             sponsorInitials: "KA",
//             racerInitials: "RO",
//           ),
//           DealItem(
//             id: "5",
//             sponsorId: "sponsor3",
//             racerId: "racer4",
//             eventId: "event4",
//             title: "Kane Automobiles X Racer Two",
//             raceType: "Rally Event",
//             dealValue: "\$3000",
//             commission: "22%",
//             renewalDate: "November 2025",
//             parts: ["Tyres", "Spoiler"],
//             status: DealStatusType.pending,
//             sponsorInitials: "KA",
//             racerInitials: "RT",
//           ),
//         ];
//       default:
//         return [];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(0),
//                     bottomRight: Radius.circular(0),
//                   ),
//                   child: Stack(
//                     children: [
//                       Image.network(
//                         Images.homeScreen,
//                         height: 240,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                       Container(
//                         height: 240,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.2),
//                             width: 1,
//                           ),
//                           gradient: LinearGradient(
//                             colors: [
//                               Color(0xFF2D5586).withOpacity(0.4),
//                               Color(0xFF171E45).withOpacity(0.4),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomLeft,
//                           ),
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 16,
//                             ).copyWith(top: 50),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                       ),
//                                       child: Image.network(
//                                         Images.sponser1,
//                                         height: 24,
//                                         width: 24,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     Text(
//                                       "Sponsers",
//                                       style: TextStyle(
//                                         color: Color(0xFFFFCC29),
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w700,
//                                         fontFamily: "Montserrat",
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       width: 3,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   padding: EdgeInsets.all(2),
//                                   child: ClipOval(
//                                     child: Consumer<EditProfileProvider>(
//                                       builder: (context, provider, child) {
//                                         return Image.network(
//                                           provider.getProfileImageUrl(),
//                                           height: 24,
//                                           width: 24,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (
//                                             context,
//                                             error,
//                                             stackTrace,
//                                           ) {
//                                             return Image.network(
//                                               Images.profileImg,
//                                               height: 24,
//                                               width: 24,
//                                               fit: BoxFit.cover,
//                                             );
//                                           },
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 20),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: kDefaultPadding,
//                             ),
//                             child: TextFormField(
//                               controller:
//                                   _searchController, // Link controller to search bar
//                               style: const TextStyle(color: Colors.black),
//                               decoration: InputDecoration(
//                                 hintText:
//                                     "Search Sponsors...", // Search hint text
//                                 hintStyle: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black,
//                                 ),
//                                 prefixIcon: const Icon(
//                                   Icons.search,
//                                   color: Colors.black,
//                                   size: 16,
//                                 ), // Search icon
//                                 filled: true,
//                                 fillColor:
//                                     Colors.white, // Search bar background
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(60),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 10,
//                                   horizontal: 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: kDefaultPadding,
//                               vertical: 8.0,
//                             ),
//                             child: Align(
//                               alignment: Alignment.centerRight,
//                               child: ElevatedButton.icon(
//                                 onPressed: () {
//                                   _navigateToAddSponsorScreen();
//                                   // Handle Add Sponsor button tap
//                                   print("Add Sponsor button tapped!");
//                                 },
//                                 icon: const Icon(
//                                   Icons.add,
//                                   color: Colors.black,
//                                   size: 16,
//                                 ), // Add icon
//                                 label: const Text(
//                                   "Add Sponsor", // Button text
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Color(
//                                     0xFFFFCC29,
//                                   ), // Use your yellow button color
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       60,
//                                     ), // Rounded button
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 20,
//                                     vertical: 12,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 _filteredSponsors.isEmpty
//                     ? Center(
//                         child: Text(
//                           _searchController.text.isEmpty
//                               ? "No sponsors available."
//                               : "No sponsors found for '${_searchController.text}'.",
//                           style: Theme.of(
//                             context,
//                           )
//                               .textTheme
//                               .bodyMedium
//                               ?.copyWith(color: Colors.white70),
//                         ),
//                       )
//                     : ListView.builder(
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         padding:
//                             EdgeInsets.zero, // Remove default ListView padding
//                         itemCount: _filteredSponsors.length,
//                         itemBuilder: (context, index) {
//                           final sponsor = _filteredSponsors[index];
//                           return SponsorCardItem(
//                             sponsor: sponsor,
//                             getDealItemsForSponsor: _getDealItemsForSponsor,
//                           );
//                         },
//                       ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
