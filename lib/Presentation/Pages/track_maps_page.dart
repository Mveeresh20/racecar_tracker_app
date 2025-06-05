// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:racecar_tracker/Services/track_service.dart';
// import 'package:racecar_tracker/models/track.dart';
// import 'package:racecar_tracker/Utils/Constants/images.dart';
// import 'add_new_map_page.dart'; // Import the AddNewMapPage

// class TrackMapsPage extends StatefulWidget {
//   const TrackMapsPage({super.key});

//   @override
//   State<TrackMapsPage> createState() => _TrackMapsPageState();
// }

// class _TrackMapsPageState extends State<TrackMapsPage> {
//   final TrackService _trackService = TrackService();
//   List<Track> _tracks = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadTracks();
//   }

//   Future<void> _loadTracks() async {
//     try {
//       final fetchedTracks = await _trackService.fetchTracks();
//       setState(() {
//         _tracks = fetchedTracks;
//         _isLoading = false;
//       });
//     } catch (e) {
//       // Handle error, e.g., show a SnackBar
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load tracks: ${e.toString()}')),
//         );
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _navigateToAddMap() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AddNewMapPage()),
//     );
//     // Refresh tracks when returning from AddNewMapPage
//     _loadTracks();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new_outlined,
//             color: Colors.white,
//             size: 16,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Track Maps",
//           style: GoogleFonts.montserrat(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         backgroundColor: const Color(0xFF2D5586),
//         elevation: 0,
//       ),
//       body:
//           _isLoading
//               ? const Center(
//                 child: CircularProgressIndicator(),
//               ) // Show loading indicator
//               : _tracks.isEmpty
//               ? _buildNoMapsUI() // Show UI for no maps
//               : _buildTrackList(), // Show the list of tracks
//     );
//   }

//   Widget _buildNoMapsUI() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // You can add a map icon or image here
//           Icon(Icons.map, size: 80, color: Colors.white.withOpacity(0.5)),
//           const SizedBox(height: 24),
//           Text(
//             "No tracks added yet!",
//             style: GoogleFonts.montserrat(
//               color: Colors.white.withOpacity(0.7),
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 40),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFFCC29),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(60),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//             ),
//             onPressed: _navigateToAddMap,
//             child: Text(
//               "Add New Map",
//               style: GoogleFonts.montserrat(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTrackList() {
//     return ListView.builder(
//       itemCount: _tracks.length,
//       itemBuilder: (context, index) {
//         final track = _tracks[index];
//         // Using a Card to display each track, similar to other elements in the app
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           color: const Color(0xFF13386B), // Match the dark blue theme
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Track Image
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(
//                     8,
//                   ), // Rounded corners for image
//                   child:
//                       track.imagePath.isNotEmpty
//                           ? Image.network(
//                             track.imagePath,
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                             errorBuilder:
//                                 (context, error, stackTrace) => const Icon(
//                                   Icons.error,
//                                   size: 80,
//                                   color: Colors.redAccent,
//                                 ), // Error placeholder
//                           )
//                           : Container(
//                             width: 80,
//                             height: 80,
//                             color: Colors.white.withOpacity(
//                               0.1,
//                             ), // Placeholder color
//                             child: const Icon(
//                               Icons.map_outlined,
//                               size: 40,
//                               color: Colors.white54,
//                             ), // Placeholder icon
//                           ),
//                 ),
//                 const SizedBox(width: 16),
//                 // Track Details
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         track.trackName,
//                         style: GoogleFonts.montserrat(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Track Number: ${track.trackNumber}',
//                         style: GoogleFonts.montserrat(
//                           color: Colors.white.withOpacity(0.7),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       // Add more track details here if needed
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
