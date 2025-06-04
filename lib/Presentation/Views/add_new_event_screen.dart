import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:racecar_tracker/Services/event_provider.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';

class AddNewEventScreen extends StatefulWidget {
  @override
  _AddNewEventScreenState createState() => _AddNewEventScreenState();
}

class _AddNewEventScreenState extends State<AddNewEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _trackNameController = TextEditingController();
  final TextEditingController _maxRacersController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _registrationCloseDate;
  String _selectedRaceType = 'Circuit Race';
  String? _selectedTrack;
  bool _isLoading = false;
  bool _isDisposed = false;

  final List<String> _trackOptions = [
    "Longmilan track",
    "Drift Track",
    "Highland Raceway",
    "Snowy Peaks Course",
  ];

  @override
  void dispose() {
    _isDisposed = true;
    _eventNameController.dispose();
    _locationController.dispose();
    _trackNameController.dispose();
    _maxRacersController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  String _getTrackImage(String? trackName) {
    switch (trackName?.toLowerCase()) {
      case "longmilan track":
        return Images.longmilanTrackLayout;
      case "drift track":
        return Images.driftTrackLayout;
      default:
        return Images.genericTrackLayout;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) _safeSetState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStart
              ? (_startTime ?? TimeOfDay.now())
              : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      _safeSetState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _pickRegistrationCloseDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _registrationCloseDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _selectedDate ?? DateTime(2100),
    );
    if (picked != null) _safeSetState(() => _registrationCloseDate = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        _registrationCloseDate == null ||
        _selectedTrack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    _safeSetState(() => _isLoading = true);

    try {
      final userId = UserService().getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Create start and end date times
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Create a unique ID (you might want to use Firebase's push ID in production)
      final eventId = DateTime.now().millisecondsSinceEpoch.toString();

      final event = Event(
        id: eventId,
        userId: userId,
        name: _eventNameController.text,
        type: _selectedRaceType,
        location: _selectedTrack!,
        startDate: startDateTime,
        endDate: endDateTime,
        status: EventStatusType.registrationOpen,
        description: "${_selectedRaceType} at ${_selectedTrack}",
        totalRacers: int.parse(_maxRacersController.text),
        currentRacers: 0,
        maxRacers: int.parse(_maxRacersController.text),
        totalSponsors: 0,
        totalPrizeMoney: 0.0,
        racerImageUrls: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        trackName: _selectedTrack,
      );

      await eventProvider.createEvent(userId, event);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating event: $e')));
      }
    } finally {
      _safeSetState(() => _isLoading = false);
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        if (keyboardType == TextInputType.number &&
            int.tryParse(value) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
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


  // Widget _buildTextField(
  //   TextEditingController controller,
  //   String hint, {
  //   TextInputType keyboardType = TextInputType.text,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: TextFormField(
  //       controller: controller,
  //       style: const TextStyle(color: Colors.white),
  //       keyboardType: keyboardType,
  //       validator: (value) {
  //         if (value == null || value.trim().isEmpty) {
  //           return 'Required';
  //         }
  //         if (keyboardType == TextInputType.number &&
  //             int.tryParse(value) == null) {
  //           return 'Enter a valid number';
  //         }
  //         return null;
  //       },
  //       decoration: InputDecoration(
  //         filled: true,
  //         fillColor: const Color(0xFF13386B),
  //         hintText: hint,
  //         hintStyle: const TextStyle(color: Colors.white60),
  //         contentPadding: const EdgeInsets.symmetric(
  //           horizontal: 12,
  //           vertical: 10,
  //         ),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(8),
  //           borderSide: BorderSide.none,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildDatePicker(
  //   BuildContext context,
  //   DateTime? value,
  //   String hint,
  //   VoidCallback onTap,
  // ) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: GestureDetector(
  //       onTap: onTap,
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFF13386B),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               value == null ? hint : DateFormat('MMM dd, yyyy').format(value),
  //               style: const TextStyle(color: Colors.white),
  //             ),
  //             const Icon(Icons.calendar_today, color: Colors.white, size: 20),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDatePicker(
  BuildContext context,
  DateTime? value,
  String hint,
  VoidCallback onTap,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF13386B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value == null
                  ? hint
                  : DateFormat('MMM dd, yyyy').format(value),
              style: TextStyle(
                color: value == null
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.white, size: 20),
          ],
        ),
      ),
    ),
  );
}


  // Widget _buildTimePicker(
  //   BuildContext context,
  //   TimeOfDay? time,
  //   String label,
  //   VoidCallback onTap,
  // ) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: GestureDetector(
  //       onTap: onTap,
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFF13386B),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               time == null ? label : time.format(context),
  //               style: const TextStyle(color: Colors.white),
  //             ),
  //             const Icon(Icons.access_time, color: Colors.white),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildTimePicker(
  BuildContext context,
  TimeOfDay? time,
  String label,
  VoidCallback onTap,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF13386B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time == null ? label : time.format(context),
              style: TextStyle(
                color: time == null
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white,
              ),
            ),
            const Icon(Icons.access_time, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                          children:  [
                            GestureDetector(
                              onTap: (){
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
                              'Add New Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel("Event Name"),
                      _buildTextField(
                        _eventNameController,
                        "Enter event name...",
                      ),
                      _buildLabel("Date"),
                      _buildDatePicker(
                        context,
                        _selectedDate,
                        "Select date",
                        () => _pickDate(context),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Start Time"),
                                _buildTimePicker(
                                  context,
                                  _startTime,
                                  "Start time",
                                  () => _pickTime(context, true),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("End Time"),
                                _buildTimePicker(
                                  context,
                                  _endTime,
                                  "End time",
                                  () => _pickTime(context, false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildLabel("Race Category"),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRaceType,
                          items:
                              [
                                    'Circuit Race',
                                    'Drift Race',
                                    'Grand Prix',
                                    'Charity Run',
                                  ]
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) =>
                                  _safeSetState(() => _selectedRaceType = val!),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF13386B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            hintText: "Select race type...",
                            
                            hintStyle: const TextStyle(color: Colors.white),
                          ),
                          dropdownColor: const Color(0xFF13386B),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      _buildLabel("Maximum Racers"),
                      _buildTextField(
                        _maxRacersController,
                        "Enter max racers...",
                        keyboardType: TextInputType.number,
                      ),
                      _buildLabel("Registration closes on"),
                      _buildDatePicker(
                        context,
                        _registrationCloseDate,
                        "Select close date",
                        () => _pickRegistrationCloseDate(context),
                      ),
                      _buildLabel("Race Track"),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonFormField<String>(
                          value: _selectedTrack,
                          items:
                              _trackOptions
                                  .map(
                                    (track) => DropdownMenuItem(
                                      value: track,
                                      child: Text(track),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) =>
                                  _safeSetState(() => _selectedTrack = val),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF13386B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            hintText: "Select race track...",
                            hintStyle: const TextStyle(color: Colors.white),
                          ),
                          dropdownColor: const Color(0xFF13386B),
                          style: const TextStyle(color: Colors.white),
                          validator:
                              (val) =>
                                  val == null ? "Please select a track" : null,
                        ),
                      ),
                      if (_selectedTrack != null) ...[
                        Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel("Selected Track"),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Stack for Track Name + Clear Button
            Expanded(
              child: Stack(
                clipBehavior: Clip.none, children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF13386B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 1,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Text(
                      "Track: $_selectedTrack",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Positioned(

                    right: -2,
                    top: -2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTrack = null;
                        });
                      },
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red.shade300,
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // View Map Button
            ElevatedButton(
              onPressed: () {
                print("View Map button tapped!");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFCC29),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                "View Map",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 10),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xFF13386B),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 500,
                width: double.infinity,
                child: Image.network(
                  _getTrackImage(_selectedTrack),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade700,
                    child: Icon(
                      Icons.map,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),






                        // const SizedBox(height: 10),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       color: const Color(0xFF13386B),
                        //       borderRadius: BorderRadius.circular(8),
                        //     ),
                        //     height: 200,
                        //     width: double.infinity,
                        //     child: Image.network(
                        //       _getTrackImage(_selectedTrack),
                        //       fit: BoxFit.cover,
                        //       errorBuilder:
                        //           (_, __, ___) => const Icon(
                        //             Icons.map,
                        //             color: Colors.white,
                        //             size: 40,
                        //           ),
                        //     ),
                        //   ),
                        // ),
                      ],
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCC29),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60),
                              ),
                            ),
                            child: const Text(
                              " +   Create Event",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:racecar_tracker/Services/event_provider.dart';
// import 'package:racecar_tracker/models/event.dart';
// import 'package:racecar_tracker/Utils/Constants/images.dart';
// import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
// import 'package:racecar_tracker/Utils/theme_extensions.dart';
// import 'package:provider/provider.dart';

// import 'package:racecar_tracker/Services/user_service.dart';

// class AddNewEventScreen extends StatefulWidget {
//   @override
//   _AddNewEventScreenState createState() => _AddNewEventScreenState();
// }

// class _AddNewEventScreenState extends State<AddNewEventScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _eventNameController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _trackNameController = TextEditingController();
//   final _maxRacersController = TextEditingController();

//   DateTime? _selectedDate;
//   TimeOfDay? _startTime;
//   TimeOfDay? _endTime;
//   DateTime? _registrationCloseDate;
//   String _selectedRaceType = 'Circuit Race';
//   bool _isLoading = false;
//   bool _isDisposed = false;

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _eventNameController.dispose();
//     _locationController.dispose();
//     _trackNameController.dispose();
//     _maxRacersController.dispose();
//     super.dispose();
//   }

//   // Safe setState wrapper
//   void _safeSetState(VoidCallback fn) {
//     if (!_isDisposed && mounted) {
//       setState(fn);
//     }
//   }

//   Future<void> _pickDate(BuildContext context) async {
//     if (!mounted) return;
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null && picked != _selectedDate && mounted) {
//       _safeSetState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _pickTime(BuildContext context, bool isStartTime) async {
//     if (!mounted) return;
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime:
//           isStartTime
//               ? (_startTime ?? TimeOfDay.now())
//               : (_endTime ?? TimeOfDay.now()),
//     );
//     if (picked != null && mounted) {
//       _safeSetState(() {
//         if (isStartTime) {
//           _startTime = picked;
//         } else {
//           _endTime = picked;
//         }
//       });
//     }
//   }

//   Future<void> _pickRegistrationCloseDate(BuildContext context) async {
//     if (!mounted) return;
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _registrationCloseDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: _selectedDate ?? DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null && picked != _registrationCloseDate && mounted) {
//       _safeSetState(() {
//         _registrationCloseDate = picked;
//       });
//     }
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedDate == null ||
//         _startTime == null ||
//         _endTime == null ||
//         _registrationCloseDate == null) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in all required fields')),
//       );
//       return;
//     }

//     _safeSetState(() => _isLoading = true);

//     try {
//       final userId = UserService().getCurrentUserId();
//       if (userId == null) {
//         throw Exception('User not logged in');
//       }

//       // Get provider before async operation
//       final eventProvider = Provider.of<EventProvider>(context, listen: false);

//       // Verify we're working with the correct user
//       if (eventProvider.events.isNotEmpty &&
//           eventProvider.events.first.userId != userId) {
//         throw Exception('User session mismatch. Please log in again.');
//       }

//       // Combine date and time
//       final dateTime = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//         _startTime!.hour,
//         _startTime!.minute,
//       );

//       final event = Event(
//         id: '', // Will be set by Firebase
//         raceName: _eventNameController.text,
//         type: _selectedRaceType,
//         location: _locationController.text,
//         title: _eventNameController.text,
//         raceType: _selectedRaceType,
//         dateTime: dateTime,
//         trackName: _trackNameController.text,
//         currentRacers: 0,
//         maxRacers: int.parse(_maxRacersController.text),
//         status: EventStatusType.registrationOpen,
//         racerImageUrls: [],
//         totalOtherRacers: 0,
//         userId: userId,
//       );

//       // Create event
//       await eventProvider.createEvent(userId, event);

//       // Check if still mounted before navigation
//       if (!mounted) return;

//       // Navigate back and refresh events
//       Navigator.of(
//         context,
//       ).pop(true); // Pass true to indicate successful creation
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error creating event: $e')));
//     } finally {
//       _safeSetState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_isLoading) return false;
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Add New Event'),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
  //           ),
  //         ),
//         body:
//             _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         TextFormField(
//                           controller: _eventNameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Event Name',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter an event name';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _locationController,
//                           decoration: const InputDecoration(
//                             labelText: 'Location',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a location';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _trackNameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Track Name',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a track name';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonFormField<String>(
//                           value: _selectedRaceType,
//                           decoration: const InputDecoration(
//                             labelText: 'Race Type',
//                             border: OutlineInputBorder(),
//                           ),
//                           items:
//                               [
//                                     'Circuit Race',
//                                     'Drift Race',
//                                     'Grand Prix',
//                                     'Charity Run',
//                                   ]
//                                   .map(
//                                     (type) => DropdownMenuItem(
//                                       value: type,
//                                       child: Text(type),
//                                     ),
//                                   )
//                                   .toList(),
//                           onChanged: (value) {
//                             if (value != null) {
//                               _safeSetState(() => _selectedRaceType = value);
//                             }
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _maxRacersController,
//                           decoration: const InputDecoration(
//                             labelText: 'Maximum Racers',
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter maximum number of racers';
//                             }
//                             final number = int.tryParse(value);
//                             if (number == null) {
//                               return 'Please enter a valid number';
//                             }
//                             if (number <= 0) {
//                               return 'Number must be greater than 0';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         ListTile(
//                           title: Text(
//                             _selectedDate == null
//                                 ? 'Select Date'
//                                 : 'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
//                           ),
//                           trailing: const Icon(Icons.calendar_today),
//                           onTap: () => _pickDate(context),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   _startTime == null
//                                       ? 'Start Time'
//                                       : 'Start: ${_startTime!.format(context)}',
//                                 ),
//                                 trailing: const Icon(Icons.access_time),
//                                 onTap: () => _pickTime(context, true),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListTile(
//                                 title: Text(
//                                   _endTime == null
//                                       ? 'End Time'
//                                       : 'End: ${_endTime!.format(context)}',
//                                 ),
//                                 trailing: const Icon(Icons.access_time),
//                                 onTap: () => _pickTime(context, false),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         ListTile(
//                           title: Text(
//                             _registrationCloseDate == null
//                                 ? 'Registration Close Date'
//                                 : 'Close: ${DateFormat('MMM dd, yyyy').format(_registrationCloseDate!)}',
//                           ),
//                           trailing: const Icon(Icons.calendar_today),
//                           onTap: () => _pickRegistrationCloseDate(context),
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: _isLoading ? null : _submitForm,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFFFCC29),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'Create Event',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
  //       ),
  //     );
  //   }
  // }
