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
  final imageResolvedUrl = imageUrl != null && imageUrl.isNotEmpty
      ? imageUtil.getUrlForUserUploadedImage(imageUrl)
      : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
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
            child: imageResolvedUrl != null
                ? Image.network(
                    imageResolvedUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isProfileImage ? Icons.person : Icons.directions_car,
            color: Colors.white54,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            isProfileImage ? 'Add Profile Photo' : 'Add Vehicle Photo',
            style: TextStyle(color: Colors.white54),
          ),
        ],
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
      backgroundColor: const Color(0xFF0A1A36),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppBar
                      Row(
                        children: [
                          BackButton(color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Add New Racer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      _label("Racer Name"),
                      _input(_nameController, "Enter racer's name"),
                      SizedBox(height: 12),
                      _label("Car Model"),
                      _input(_vehicleModelController, "Enter car model"),
                      SizedBox(height: 12),
                      _label("Team Name"),
                      _input(_teamNameController, "Enter team name"),
                      SizedBox(height: 12),
                      _label("Contact Number"),
                      _input(
                        _contactNumberController,
                        "Enter contact number",
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 12),
                      _label("Vehicle Number"),
                      _input(_vehicleNumberController, "Enter vehicle number"),
                      SizedBox(height: 18),
                     Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    // Racer Image Picker
    Expanded(
      child: _buildImagePicker(_racerImageUrl, true, "Racer Image"),
    ),
    const SizedBox(width: 16),
    // Vehicle Image Picker
    Expanded(
      child: _buildImagePicker(_vehicleImageUrl, false, "Vehicle Image"),
    ),
  ],
),

                      SizedBox(height: 18),
                      _label("Assign to Event"),
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
                        DropdownButtonFormField<Event>(
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
                            filled: true,
                            fillColor: const Color(0xFF13386B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Select Event...",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          dropdownColor: const Color(0xFF13386B),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Please select an event'
                                      : null,
                        ),
                      SizedBox(height: 18),
                      _label("Deal Validity Dates"),
                      Row(
                        children: [
                          Expanded(
                            child: _datePickerBox(
                              context,
                              _startDate,
                              "Start Date",
                              () => _pickDate(true),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _datePickerBox(
                              context,
                              _endDate,
                              "End Date",
                              () => _pickDate(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createRacer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC29),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    "+ Add Racer",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
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
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
    ),
  );

  Widget _input(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
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
      validator:
          (value) => (value == null || value.isEmpty) ? "Required" : null,
    );
  }

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
