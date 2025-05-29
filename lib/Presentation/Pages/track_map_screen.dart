import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';

class TrackMapScreen extends StatefulWidget {
  const TrackMapScreen({Key? key}) : super(key: key);

  @override
  State<TrackMapScreen> createState() => _TrackMapScreenState();
}

class _TrackMapScreenState extends State<TrackMapScreen> {
  int _currentIndex = 1;
  int _currentTrack = 0;
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
  void dispose() {
    _transformationController.dispose();
    super.dispose();
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

  // void _zoomIn() {
  //   int idx = _zoomLevels.indexWhere((z) => z > _zoom);
  //   if (idx != -1) _setZoom(_zoomLevels[idx]);
  // }

  // void _zoomOut() {
  //   int idx = _zoomLevels.lastIndexWhere((z) => z < _zoom);
  //   if (idx != -1) _setZoom(_zoomLevels[idx]);
  // }

  @override
  Widget build(BuildContext context) {
    final trackImage = _trackImages[_currentTrack];
    final trackName = _trackNames[_currentTrack];

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
                    Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    SizedBox(width: 40),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.flag, color: Colors.white, size: 24),
                          SizedBox(width: 4),
                          Text(
                            "Maps",
                            style: TextStyle(
                              color: Color(0xFFFFCC29),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFCC29),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              // Positioned(
              //   left: 16,
              //   top: 40,
              //   child: Icon(Icons.arrow_back, color: Colors.white),
              // ),
              // Positioned(
              //   left: 60,
              //   top: 50,
              //   child: Text(
              //     "Maps",
              //     style: TextStyle(
              //       color: Color(0xFFFFCC29),
              //       fontWeight: FontWeight.bold,
              //       fontSize: 22,
              //     ),
              //   ),
              // ),
              // Positioned(
              //   right: 16,
              //   top: 40,
              //   child: Icon(Icons.add, color: Colors.black),
              // ),
            ],
          ),
          SizedBox(height: 16),
          // Track name and arrows
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_left,
                    color: Color(0xFFFBA710),
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentTrack =
                          (_currentTrack - 1 + _trackImages.length) %
                          _trackImages.length;
                    });
                  },
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
                          trackName,
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
                    color: Color(0xFFFBA710),
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentTrack = (_currentTrack + 1) % _trackImages.length;
                    });
                  },
                ),
              ],
            ),
          ),
          // VIP/EDIT Button (optional, as in your screenshot)
          // Padding(
          //   padding: const EdgeInsets.only(left: 24, top: 8, bottom: 4),
          //   child: Align(
          //     alignment: Alignment.centerLeft,
          //     child: ElevatedButton.icon(
          //       onPressed: () {},
          //       icon: Icon(Icons.edit, color: Colors.black),
          //       label: Text("Edit", style: TextStyle(color: Colors.black)),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Color(0xFFFFCC29),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Zoomable, pannable image
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
                        height: 390,
                        decoration: BoxDecoration(
                          color: Color(0xFF13386B),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: 0.5,
                            maxScale: 3.5,
                            boundaryMargin: EdgeInsets.all(80),
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
                                trackImage.startsWith('http')
                                    ? Image.network(
                                      height: 390,
                                      trackImage,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      trackImage,
                                      fit: BoxFit.contain,
                                    ),
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
                                          selectedColor: Color(0xFFFFCC29),
                                          backgroundColor: Color(0xFF13386B),
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
                    color: Color(0xFFFFCC29),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_out, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'Zoom',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.zoom_in, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _zoomOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Min', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 8),

                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _zoomIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Max', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
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
