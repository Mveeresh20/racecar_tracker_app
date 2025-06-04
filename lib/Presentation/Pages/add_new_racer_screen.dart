import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/Services/racer_provider.dart';
import 'package:racecar_tracker/Services/event_provider.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';
import 'package:racecar_tracker/Services/app_constant.dart';
import 'package:racecar_tracker/Services/racer_service.dart';

class AddNewRacerScreen extends StatefulWidget {
  const AddNewRacerScreen({Key? key}) : super(key: key);

  @override
  State<AddNewRacerScreen> createState() => _AddNewRacerScreenState();
}

class _AddNewRacerScreenState extends State<AddNewRacerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _currentEventController = TextEditingController();

  String? _racerImageUrl;
  String? _vehicleImageUrl;
  bool _isLoading = false;
  final _imagePicker = ImagePickerUtil();

  Event? _selectedEvent;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _initializeEvents();
  }

  Future<void> _initializeEvents() async {
    final userId = UserService().getCurrentUserId();
    if (userId != null) {
      await Provider.of<EventProvider>(
        context,
        listen: false,
      ).initUserEvents(userId);
    }
  }

  Future<void> _pickImage(bool isProfileImage) async {
    ImagePickerUtil().showImageSourceSelection(
      context,
      (String imagePath) {
        setState(() {
          if (isProfileImage) {
            _racerImageUrl = imagePath;
          } else {
            _vehicleImageUrl = imagePath;
          }
        });
      },
      (String error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $error')),
        );
      },
    );
  }

  void _clearImage(bool isProfileImage) {
    setState(() {
      if (isProfileImage) {
        _racerImageUrl = null;
      } else {
        _vehicleImageUrl = null;
      }
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startDate = picked;
        else
          _endDate = picked;
      });
    }
  }

  Future<void> _createRacer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEvent == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an event')));
      return;
    }

    if (_vehicleImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a vehicle image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = UserService.instance.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final racerId = await RacerService().createRacer(
        userId: userId,
        name: _nameController.text.trim(),
        teamName: _teamNameController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        vehicleNumber: _vehicleNumberController.text.trim(),
        currentEvent: _selectedEvent!.name,
        racerImageUrl: _racerImageUrl,
        vehicleImageUrl: _vehicleImageUrl,
        context: context,
      );

      if (mounted) {
        Navigator.pop(context, racerId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating racer: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildImagePicker(
    String? imageUrl,
    bool isProfileImage,
    String label,
  ) {
    final imageUtil = ImagePickerUtil();
    final imageResolvedUrl =
        imageUrl != null && imageUrl.isNotEmpty
            ? imageUtil.getUrlForUserUploadedImage(imageUrl)
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickImage(isProfileImage),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF13386B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  imageResolvedUrl != null
                      ? Image.network(
                        imageResolvedUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildPlaceholder(isProfileImage),
                      )
                      : _buildPlaceholder(isProfileImage),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(bool isProfileImage) {
    return Center(
      child: Icon(
        isProfileImage ? Icons.add : Icons.add,
        color: Colors.white54,
        size: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events;
    final isLoading = eventProvider.isLoading;
    final error = eventProvider.error;

    final initials =
        _nameController.text.isNotEmpty
            ? _nameController.text
                .trim()
                .split(' ')
                .map((e) => e[0])
                .take(2)
                .join()
                .toUpperCase()
            : '';

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 64,
                      bottom: 18,
                      left: 24,
                      right: 24,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D5586), Color(0xFF171E45)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Add New Racer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // AppBar
                  SizedBox(height: 18),

                  _label("Racer Name"),
                  SizedBox(height: 8),
                  _input(_nameController, "Enter racer's name"),
                  SizedBox(height: 14),

                  _label("Car Model"),
                  SizedBox(height: 8),
                  _input(_vehicleModelController, "Enter car model"),
                  SizedBox(height: 14),

                  _label("Team Name"),
                  SizedBox(height: 8),
                  _input(_teamNameController, "Enter team name"),
                  SizedBox(height: 14),

                  _label("Contact Number"),
                  SizedBox(height: 8),
                  _input(
                    _contactNumberController,
                    "Enter contact number",
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 14),

                  _label("Vehicle Number"),
                  SizedBox(height: 8),
                  _input(_vehicleNumberController, "Enter vehicle number"),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Racer Image Picker
                        Expanded(
                          child: _buildImagePicker(
                            _racerImageUrl,
                            true,
                            "Upload Racer Image",
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Vehicle Image Picker
                        Expanded(
                          child: _buildImagePicker(
                            _vehicleImageUrl,
                            false,
                            "Upload Vehicle Image",
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14),
                  _label("Assign to Event"),
                  SizedBox(height: 8),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (error != null)
                    Text(
                      'Error loading events: $error',
                      style: const TextStyle(color: Colors.red),
                    )
                  else if (events.isEmpty)
                    const Text(
                      'No events available. Please create an event first.',
                      style: TextStyle(color: Colors.white70),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<Event>(
                        value: _selectedEvent,
                        items:
                            events
                                .map(
                                  (event) => DropdownMenuItem(
                                    value: event,
                                    child: Text(
                                      event.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _selectedEvent = val),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: const Color(0xFF13386B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),

                          hintText: "Select Event...",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        dropdownColor: const Color(0xFF13386B),
                        validator:
                            (value) =>
                                value == null ? 'Please select an event' : null,
                      ),
                    ),
                  SizedBox(height: 18),
                  _label("Deal Validity Dates"),
                  SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                    
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _datePickerBox(
                                context,
                                _startDate,
                                "mm/dd/yyyy",
                                () => _pickDate(true),
                              ),
                              SizedBox(height: 4,),
                              _label("Start Date"),
                            ],
                          ),
                        ),
                        SizedBox(width: 8,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _datePickerBox(
                                context,
                                _endDate,
                                "mm/dd/yyyy",
                                () => _pickDate(false),
                              ),
                              SizedBox(height: 4,),
                              _label("End Date"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createRacer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC29),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                )
                                : const Text(
                                  "+  Add Racer",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator:
            (value) => (value == null || value.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF13386B),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // Widget _input(
  //   TextEditingController controller,
  //   String hint, {
  //   TextInputType keyboardType = TextInputType.text,
  // }) {
  //   return TextFormField(
  //     controller: controller,
  //     keyboardType: keyboardType,
  //     style: TextStyle(color: Colors.white),
  //     decoration: InputDecoration(
  //       filled: true,
  //       fillColor: const Color(0xFF13386B),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: BorderSide.none,
  //       ),
  //       hintText: hint,
  //       hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
  //     ),
  //     validator:
  //         (value) => (value == null || value.isEmpty) ? "Required" : null,
  //   );
  // }

  Widget _datePickerBox(
    BuildContext context,
    DateTime? date,
    String hint,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF13386B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? DateFormat('MM/dd/yyyy').format(date) : hint,
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.calendar_today, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
