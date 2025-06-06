import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewMapScreen extends StatefulWidget {
  final String trackName;
  final String trackImage;

  const ViewMapScreen({
    Key? key,
    required this.trackName,
    required this.trackImage,
  }) : super(key: key);

  @override
  State<ViewMapScreen> createState() => _ViewMapScreenState();
}

class _ViewMapScreenState extends State<ViewMapScreen> {
  final List<double> _zoomLevels = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5];
  double _zoom = 1.0;
  final TransformationController _transformationController =
      TransformationController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 24,
            ).copyWith(top: 64, bottom: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D5586), Color(0xFF171E45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),

                    const SizedBox(width: 30),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.flag, color: Colors.white, size: 24),
                          const SizedBox(width: 4),
                          Text(
                            widget.trackName,
                            style: const TextStyle(
                              color: Color(0xFFFFCC29),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Space before bottom border
              ],
            ),
          ),
          // Header
         
          const SizedBox(height: 16),

          // Track View
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
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
                          color: const Color(0xFF13386B),
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
                            child: Image.network(
                              widget.trackImage,
                              height: 390,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.error,
                                    size: 80,
                                    color: Colors.redAccent,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      // Zoom level chips
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
                                          selectedColor: const Color(
                                            0xFFFFCC29,
                                          ),
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
                    color: const Color(0xFFFFCC29),
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
                        backgroundColor: const Color(0xFF2D5586),
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
                        backgroundColor: const Color(0xFF2D5586),
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
      ),
    );
  }
}
