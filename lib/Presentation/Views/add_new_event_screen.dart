import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';

class AddNewEventScreen extends StatefulWidget {
  @override
  _AddNewEventScreenState createState() => _AddNewEventScreenState();
}

class _AddNewEventScreenState extends State<AddNewEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _raceTypeController = TextEditingController();
  final TextEditingController _maxRacersController = TextEditingController();
  final TextEditingController _raceNameController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _registrationCloseDate;
  String? _selectedTrack;
  EventStatusType _status = EventStatusType.registrationOpen;

  // For demo, you can use placeholder images
  List<String> _racerImageUrls = [];
  int _currentRacers = 0;

  // Track options
  final List<String> _trackOptions = [
    "Longmilan track",
    "Drift Track",
    "Highland Raceway",
    "Snowy Peaks Course",
  ];

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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStart
              ? (_startTime ?? TimeOfDay.now())
              : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null)
      setState(() {
        if (isStart)
          _startTime = picked;
        else
          _endTime = picked;
      });
  }

  Future<void> _pickRegistrationCloseDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _registrationCloseDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _registrationCloseDate = picked);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _startTime != null &&
        _endTime != null &&
        _selectedTrack != null) {
      // Combine date and time
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      // For this model, we use start time as event time
      final event = Event(
        id: "event1",
        title: _titleController.text,
        type: _raceTypeController.text,
        dateTime: startDateTime,
        location: _selectedTrack!,
        racerImageUrls: _racerImageUrls,
        totalOtherRacers: 0,
        raceType: _raceTypeController.text,
        trackName: _selectedTrack!,
        currentRacers: _currentRacers,
        maxRacers: int.tryParse(_maxRacersController.text) ?? 0,
        status: _status,
        raceName: _raceNameController.text,
      );
      Navigator.pop(context, event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // AppBar
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
                        Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 16),
                        Text(
                          "Add New Event",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    // Space before bottom border
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Event Name
              _buildLabel("Event Name"),
              _buildTextField(_titleController, "Enter sponsor name..."),

              // Date
              _buildLabel("Date"),
              _buildDatePicker(
                context,
                _selectedDate,
                "Select date",
                _pickDate,
              ),

              // Start/End Time
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
                  SizedBox(width: 8),
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

              // Race Category
              _buildLabel("Race Category"),
              _buildTextField(_raceTypeController, "Select race category..."),

              // Maximum Racers
              _buildLabel("Maximum Racers"),
              _buildTextField(
                _maxRacersController,
                "Enter max racers...",
                keyboardType: TextInputType.number,
              ),

              // Registration closes on
              _buildLabel("Registration closes on"),
              _buildDatePicker(
                context,
                _registrationCloseDate,
                "Select date",
                _pickRegistrationCloseDate,
              ),

              // Race Track
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
                  onChanged: (val) => setState(() => _selectedTrack = val),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: Color(0xFF13386B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Select race track...",
                    hintStyle: TextStyle(color: Colors.white),
                  ),

                  style: TextStyle(color: Colors.white),
                  dropdownColor: Color(0xFF13386B),
                  validator:
                      (val) => val == null ? "Please select a track" : null,
                ),
              ),
              SizedBox(height: 12),

              if (_selectedTrack != null)
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


              // Selected Track Image
              // if (_selectedTrack != null)
              //   Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       _buildLabel("Selected Track"),

              //       Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 16),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Container(
              //               decoration: BoxDecoration(
              //                 color: Color(0xFF13386B),
              //                 borderRadius: BorderRadius.circular(8),
              //                 border: Border.all(
              //                   width: 1,
              //                   color: Colors.white.withOpacity(0.2),
              //                 ),
              //               ),
              //               child: Padding(
              //                 padding: const EdgeInsets.symmetric(
              //                   horizontal: 10,
              //                   vertical: 12,
              //                 ),
              //                 child: Text(
              //                   "$_selectedTrack",
              //                   style: context.titleMedium?.copyWith(
              //                     color: Colors.white,
              //                   ),
              //                 ),
              //               ),
              //             ),

              //             ElevatedButton(
              //               onPressed: () {
              //                 print("Add Sponsor button tapped!");
              //               },

              //               style: ElevatedButton.styleFrom(
              //                 backgroundColor: Color(
              //                   0xFFFFCC29,
              //                 ), // Yellow background
              //                 shape: RoundedRectangleBorder(
              //                   borderRadius: BorderRadius.circular(
              //                     8,
              //                   ), // Rounded edges
              //                 ),
              //                 padding: const EdgeInsets.symmetric(
              //                   horizontal: 16,
              //                   vertical: 8,
              //                 ),
              //               ),
              //               child: Text(
              //                 "View Map",
              //                 style: TextStyle(
              //                   color: Colors.black,
              //                   fontWeight: FontWeight.w600,
              //                   fontSize: 12,
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       SizedBox(height: 10),
              //       Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 16),
              //         child: Container(
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(8),
              //             color: Color(0xFF13386B),
              //           ),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               SizedBox(
              //                 height: 500,
              //                 width: double.infinity,
              //                 child: Image.network(
              //                   _getTrackImage(_selectedTrack),
              //                   fit: BoxFit.cover,
              //                   errorBuilder:
              //                       (context, error, stackTrace) => Container(
              //                         color: Colors.grey.shade700,
              //                         child: Icon(
              //                           Icons.map,
              //                           color: Colors.white,
              //                           size: 40,
              //                         ),
              //                       ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),

              SizedBox(height: 20),

              // Create Event Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: Icon(Icons.add, color: Colors.black),
                    label: Text(
                      "Create Event",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCC29),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,

        style: context.titleSmall?.copyWith(color: Colors.white),
      ),
    ),
  );

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
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF13386B),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          labelStyle: TextStyle(color: Colors.white),
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
        validator:
            (value) => (value == null || value.isEmpty) ? "Required" : null,
      ),
    );
  }

  // Widget _buildTextField(
  //   TextEditingController controller,
  //   String hint, {
  //   TextInputType keyboardType = TextInputType.text,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //     child: TextFormField(
  //       controller: controller,
  //       keyboardType: keyboardType,
  //       style: TextStyle(color: Colors.white),
  //       decoration: InputDecoration(
  //         filled: true,
  //         fillColor: Color(0xFF13386B),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(8),
  //           borderSide: BorderSide.none,
  //         ),
  //         hintText: hint,
  //         hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
  //       ),
  //       validator:
  //           (value) => (value == null || value.isEmpty) ? "Required" : null,
  //     ),
  //   );
  // }

  // Widget _buildDatePicker(
  //   BuildContext context,
  //   DateTime? date,
  //   String hint,
  //   Function(BuildContext) onTap,
  // ) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //     child: InkWell(
  //       onTap: () => onTap(context),
  //       child: InputDecorator(
  //         decoration: InputDecoration(
  //           filled: true,
  //           fillColor: Color(0xFF13386B),
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(8),
  //             borderSide: BorderSide.none,
  //           ),
  //           hintText: hint,
  //           hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               date != null ? DateFormat('MM/dd/yyyy').format(date) : hint,
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             Icon(Icons.calendar_today, color: Colors.white),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildDatePicker(
    BuildContext context,
    DateTime? date,
    String hint,
    Function(BuildContext) onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onTap(context),
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF13386B),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null ? DateFormat('MM/dd/yyyy').format(date) : hint,
                style: const TextStyle(color: Colors.white),
              ),
              const Icon(Icons.calendar_today, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    TimeOfDay? time,
    String hint,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF13386B),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time != null ? time.format(context) : hint,
                style: const TextStyle(color: Colors.white),
              ),
              const Icon(Icons.access_time, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  //   Widget _buildTimePicker(
  //     BuildContext context,
  //     TimeOfDay? time,
  //     String hint,
  //     VoidCallback onTap,
  //   ) {
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
  //       child: InkWell(
  //         onTap: onTap,
  //         child: InputDecorator(
  //           decoration: InputDecoration(
  //             filled: true,
  //             fillColor: Color(0xFF13386B),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8),
  //               borderSide: BorderSide.none,
  //             ),
  //             hintText: hint,
  //             hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 time != null ? time.format(context) : hint,
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               Icon(Icons.access_time, color: Colors.white),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }
}
