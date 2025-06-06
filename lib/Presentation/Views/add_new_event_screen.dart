import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:racecar_tracker/Services/event_provider.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Presentation/Views/view_map_screen.dart';

class AddNewEventScreen extends StatefulWidget {
  final Event? existingEvent;

  const AddNewEventScreen({Key? key, this.existingEvent}) : super(key: key);

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
  void initState() {
    super.initState();
    // Initialize form with existing event data if editing
    if (widget.existingEvent != null) {
      _eventNameController.text = widget.existingEvent!.name;
      _locationController.text = widget.existingEvent!.location;
      _trackNameController.text = widget.existingEvent!.trackName ?? '';
      _maxRacersController.text = widget.existingEvent!.maxRacers.toString();
      _selectedDate = widget.existingEvent!.startDate;
      _startTime = TimeOfDay.fromDateTime(widget.existingEvent!.startDate);
      _endTime = TimeOfDay.fromDateTime(widget.existingEvent!.endDate);
      _registrationCloseDate = widget.existingEvent!.endDate;
      _selectedRaceType = widget.existingEvent!.type;
      _selectedTrack = widget.existingEvent!.trackName;
    }
  }

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

      final event = Event(
        id:
            widget.existingEvent?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: _eventNameController.text,
        type: _selectedRaceType,
        location: _selectedTrack!,
        startDate: startDateTime,
        endDate: endDateTime,
        status:
            widget.existingEvent?.status ?? EventStatusType.registrationOpen,
        description: "${_selectedRaceType} at ${_selectedTrack}",
        totalRacers: int.parse(_maxRacersController.text),
        currentRacers: widget.existingEvent?.currentRacers ?? 0,
        maxRacers: int.parse(_maxRacersController.text),
        totalSponsors: widget.existingEvent?.totalSponsors ?? 0,
        totalPrizeMoney: widget.existingEvent?.totalPrizeMoney ?? 0.0,
        racerImageUrls: widget.existingEvent?.racerImageUrls ?? [],
        createdAt: widget.existingEvent?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        trackName: _selectedTrack,
      );

      if (widget.existingEvent != null) {
        await eventProvider.updateEvent(userId, event);
      } else {
        await eventProvider.createEvent(userId, event);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${widget.existingEvent != null ? "updating" : "creating"} event: $e',
            ),
          ),
        );
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
                value == null ? hint : DateFormat('MMM dd, yyyy').format(value),
                style: TextStyle(
                  color:
                      value == null
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
                  color:
                      time == null
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
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              widget.existingEvent != null
                                  ? "Edit Event"
                                  : "Add New Event",
                              style: const TextStyle(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Stack for Track Name + Clear Button
                                  Expanded(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF13386B),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 12,
                                          ),
                                          child: Text(
                                            "Track: $_selectedTrack",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(color: Colors.white),
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
                                              backgroundColor:
                                                  Colors.red.shade300,
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
                                      if (_selectedTrack != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ViewMapScreen(
                                                  trackName: _selectedTrack!,
                                                  trackImage: _getTrackImage(
                                                    _selectedTrack,
                                                  ),
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFFCC29),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
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
                            child: Text(
                              widget.existingEvent != null
                                  ? "Update Event"
                                  : "+   Create Event",
                              style: const TextStyle(
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
