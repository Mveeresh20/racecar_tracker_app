import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:racecar_tracker/Services/track_service.dart';
import 'package:racecar_tracker/models/track.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';

class AddNewMapPage extends StatefulWidget {
  const AddNewMapPage({super.key});

  @override
  State<AddNewMapPage> createState() => _AddNewMapPageState();
}

class _AddNewMapPageState extends State<AddNewMapPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _trackNumberController = TextEditingController();
  String? _selectedTrackName;
  String? _selectedImagePath;
  final TrackService _trackService = TrackService();

  final List<String> _trackNames = [
    'Drift Track',
    'Longmilan Track',
    'Highland Track',
    'Snowy Peaks Course',
  ];

  final Map<String, String> _trackImages = {
    'Preset_A': Images.track1,
    'Preset_B': Images.track2,
    'Preset_C': Images.track3,
    'Preset_D': Images.track4,
  };

  bool _isLoading = false;

  void _handleSaveMap(BuildContext context) async {
    if (_formKey.currentState?.validate() ??
        false && _selectedImagePath != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final track = Track(
          trackNumber: int.parse(_trackNumberController.text.trim()),
          trackName: _selectedTrackName!,
          imagePath: _selectedImagePath!,
        );
        await _trackService.saveTrack(track);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Track added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back after saving
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add track: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a track preset image.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _trackNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add New Map",
          style: TextStyle(
            fontFamily: "Plus Jakarta Sans",
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(
          0xFF2D5586,
        ), // Adjust color to match the design
        elevation: 0,
      ),
      body: Builder(
        builder: (BuildContext innerContext) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Track Number Input
                    Text(
                      "Track number",
                      style: TextStyle(
                        fontFamily: "Plus Jakarta Sans",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF13386B,
                        ), // Darker blue for input field
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: _trackNumberController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                          hintText: "Enter track number (1-4)",
                          hintStyle: TextStyle(
                            fontFamily: "Plus Jakarta Sans",
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a track number';
                          }
                          final number = int.tryParse(value);
                          if (number == null || number <= 0 || number > 4) {
                            return 'Please enter a number between 1 and 4';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Track Name Dropdown
                    Text(
                      "Track name",
                      style: TextStyle(
                        fontFamily: "Plus Jakarta Sans",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF13386B,
                        ), // Darker blue for input field
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ), // Padding for dropdown
                      child: DropdownButtonFormField<String>(
                        value: _selectedTrackName,
                        hint: Text(
                          "Select track name",
                          style: TextStyle(
                            fontFamily: "Plus Jakarta Sans",
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        dropdownColor: const Color(
                          0xFF13386B,
                        ), // Background color of dropdown menu
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        items:
                            _trackNames.map((String name) {
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(name),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedTrackName = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a track name';
                          }
                          return null;
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ), // Dropdown arrow color
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Select Race Track Preset
                    Text(
                      "Select Race Track Preset",
                      style: TextStyle(
                        fontFamily: "Plus Jakarta Sans",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable gridview scrolling
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 images per row
                            crossAxisSpacing:
                                16, // Spacing between images horizontally
                            mainAxisSpacing:
                                16, // Spacing between images vertically
                            childAspectRatio: 1, // Make items square
                          ),
                      itemCount: _trackImages.length,
                      itemBuilder: (context, index) {
                        final presetName = _trackImages.keys.elementAt(index);
                        final imagePath = _trackImages.values.elementAt(index);
                        final isSelected = _selectedImagePath == imagePath;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImagePath = imagePath;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? const Color(0xFFFFCC29)
                                        : Colors.white.withOpacity(0.2),
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  // Allow image to take available space
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ), // Rounded corners for image
                                    child: Image.network(
                                      imagePath,
                                      fit:
                                          BoxFit
                                              .cover, // Cover the available space
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  presetName, // Display Preset name below the image
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Save Map Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFFCC29,
                          ), // Yellow color from design
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              60,
                            ), // Rounded button
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed:
                            _isLoading
                                ? null
                                : () => _handleSaveMap(innerContext),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator() // Show loading indicator when saving
                                : Text(
                                  "Save Map",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
