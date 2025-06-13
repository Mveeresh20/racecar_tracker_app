import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Services/track_service.dart';
import 'package:racecar_tracker/Utils/Constants/text.dart';
import 'package:racecar_tracker/models/track.dart';
import 'add_new_map_page.dart'; // Import AddNewMapPage

class TrackMapScreen extends StatefulWidget {
  const TrackMapScreen({Key? key}) : super(key: key);

  @override
  State<TrackMapScreen> createState() => _TrackMapScreenState();
}

class _TrackMapScreenState extends State<TrackMapScreen> {
  final TrackService _trackService = TrackService();
  List<Track> _tracks = [];
  bool _isLoading = true;
  int _currentTrackIndex = 0; // Use index to track current map
  int _currentIndex = 1;
  final List<double> _zoomLevels = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5];
  double _zoom = 1.0;
  final TransformationController _transformationController =
      TransformationController();

  final List<String> _trackImages = [
    Images.track1,
    Images.track2,
    Images.track3,
    Images.track4,
  ];

  final List<String> _trackNames = [
    'Track 1: Drift Track',
    'Track 2: Drift Track',
    'Track 3: Drift Track',
    'Track 4: Drift Track',
  ];

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetchedTracks = await _trackService.fetchTracks();
      setState(() {
        _tracks = fetchedTracks;
        _isLoading = false;
        // Reset index if the list is empty or the current index is out of bounds
        if (_tracks.isEmpty || _currentTrackIndex >= _tracks.length) {
          _currentTrackIndex = 0;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tracks: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
          _tracks = []; // Clear tracks on error
          _currentTrackIndex = 0;
        });
      }
    }
  }

  void _navigateToAddMap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNewMapPage()),
    );
    // Refresh tracks when returning from AddNewMapPage
    _loadTracks();
  }

  void _nextTrack() {
    if (_tracks.isNotEmpty) {
      setState(() {
        _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
        // Reset zoom and pan when changing tracks
        _transformationController.value = Matrix4.identity();
        _zoom = 1.0;
      });
    }
  }

  void _previousTrack() {
    if (_tracks.isNotEmpty) {
      setState(() {
        _currentTrackIndex =
            (_currentTrackIndex - 1 + _tracks.length) % _tracks.length;
        // Reset zoom and pan when changing tracks
        _transformationController.value = Matrix4.identity();
        _zoom = 1.0;
      });
    }
  }

  void _setZoom(double zoom) {
    setState(() {
      _zoom = zoom;
      _transformationController.value = Matrix4.identity()..scale(_zoom);
    });
  }

  void _zoomIn() {
    int currentIndex = _getClosestZoomLevelIndex();
    if (currentIndex < _zoomLevels.length - 1) {
      _setZoom(_zoomLevels[currentIndex + 1]);
    }
  }

  void _zoomOut() {
    int currentIndex = _getClosestZoomLevelIndex();
    if (currentIndex > 0) {
      _setZoom(_zoomLevels[currentIndex - 1]);
    }
  }

  int _getClosestZoomLevelIndex() {
    double minDiff = double.infinity;
    int closestIndex = 0;
    for (int i = 0; i < _zoomLevels.length; i++) {
      double diff = (_zoomLevels[i] - _zoom).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Stack(
            children: [
              Image.network(
                Images.homeScreen,
                height: 118,

                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 118,

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

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 40),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.flag, color: Colors.white, size: 24),
                          SizedBox(width: 4),
                          Text(
                            "Maps", // Keep "Maps" title
                            style: TextStyle(
                              color: Color(0xFFFFCC29),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          _navigateToAddMap, // Link the add button to navigation
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFCC29),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: Icon(Icons.add, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          _isLoading
              ? const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
              : _tracks.isEmpty
              ? Expanded(child: _buildNoMapsUI()) // Show no maps UI
              : Expanded(
                child: _buildTrackView(
                  _tracks[_currentTrackIndex].imagePath,
                  _tracks[_currentTrackIndex].trackName,
                ),
              ), // Show track view
        ],
      ),
    );
  }

  Widget _buildNoMapsUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          Images.noMap,
                                          fit: BoxFit.contain,
                                          height: 280,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "🗺️ No Race Maps Added Yet",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          Lorempsum.noMapText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),

          
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCC29),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            onPressed: _navigateToAddMap,
            child: Text(
              " + Add New Map",
              style: GoogleFonts.montserrat(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackView(String trackImage, String trackName) {
    return Column(
      // Wrap the existing track display content in a Column
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_left,
                  color:
                      _tracks.length > 1
                          ? const Color(0xFFFBA710)
                          : Colors.white.withOpacity(
                            0.5,
                          ), // Dim arrows if only one track
                  size: 32,
                ),
                onPressed:
                    _tracks.length > 1
                        ? _previousTrack
                        : null, // Disable if only one track
              ),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: Colors.white, size: 24),
                      SizedBox(width: 16),
                      Text(
                        trackName, // Use the passed trackName
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              IconButton(
                icon: Icon(
                  Icons.arrow_right,
                  color:
                      _tracks.length > 1
                          ? const Color(0xFFFBA710)
                          : Colors.white.withOpacity(
                            0.5,
                          ), // Dim arrows if only one track
                  size: 32,
                ),
                onPressed:
                    _tracks.length > 1
                        ? _nextTrack
                        : null, 
              ),
            ],
          ),
        ),
      
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate the max size for the image area
              double size =
                  constraints.maxHeight < 400
                      ? constraints.maxHeight * 0.8
                      : 320;
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The zoomable image
                    Container(
                      width: size,
                      height: 390, // Keep the fixed height from original
                      decoration: BoxDecoration(
                        color: const Color(0xFF13386B), // Match theme
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 0.5,
                          maxScale: 3.5,
                          boundaryMargin: const EdgeInsets.all(80),
                          panEnabled: true,
                          scaleEnabled: true,
                          onInteractionEnd: (details) {
                            setState(() {
                              _zoom =
                                  _transformationController.value
                                      .getMaxScaleOnAxis();
                            });
                          },
                          child:
                              trackImage
                                      .isNotEmpty // Use the passed trackImage
                                  ? Image.network(
                                    trackImage,
                                    height: 390, // Keep fixed height
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.error,
                                              size: 80,
                                              color: Colors.redAccent,
                                            ), // Error placeholder
                                  )
                                  : Container(), // Empty container if no image path
                        ),
                      ),
                    ),
                    // The vertical zoom chips
                    Positioned(
                      right: 0,
                      top: 20,
                      bottom: 20,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              _zoomLevels
                                  .map(
                                    (z) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: ChoiceChip(
                                        label: Text(
                                          '${z}x',
                                          style: TextStyle(
                                            color:
                                                (_zoom - z).abs() < 0.01
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                        ),
                                        selected: (_zoom - z).abs() < 0.01,
                                        selectedColor: const Color(0xFFFFCC29),
                                        backgroundColor: const Color(
                                          0xFF13386B,
                                        ),
                                        onSelected: (_) => _setZoom(z),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Zoom controls
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC29), // Match theme
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.zoom_out, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        'Zoom',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.zoom_in, color: Colors.black),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _zoomOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5586), // Match theme
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Min',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _zoomIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5586), // Match theme
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Max',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
