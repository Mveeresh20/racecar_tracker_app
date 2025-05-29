import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/event.dart';

class AddNewRacerScreen extends StatefulWidget {
  final List<Event> events;
  const AddNewRacerScreen({Key? key, required this.events}) : super(key: key);

  @override
  State<AddNewRacerScreen> createState() => _AddNewRacerScreenState();
}

class _AddNewRacerScreenState extends State<AddNewRacerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();

  File? _carImage;
  File? _racerImage;
  Event? _selectedEvent;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickImage(bool isCar) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isCar) {
          _carImage = File(picked.path);
        } else {
          _racerImage = File(picked.path);
        }
      });
    }
  }

  void _clearImage(bool isCar) {
    setState(() {
      if (isCar) {
        _carImage = null;
      } else {
        _racerImage = null;
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

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _carImage != null &&
        _selectedEvent != null &&
        _startDate != null &&
        _endDate != null) {
      final name = _nameController.text.trim();
      final initials =
          name.isNotEmpty
              ? name
                  .trim()
                  .split(' ')
                  .map((e) => e[0])
                  .take(2)
                  .join()
                  .toUpperCase()
              : '';

      // Create the racer with local image paths
      final racer = Racer(
        initials: initials,
        vehicleImageUrl: _carImage!.path,
        name: name,
        vehicleModel: _carModelController.text.trim(),
        teamName: _teamNameController.text.trim(),
        currentEvent: _selectedEvent!.title,
        earnings: "\$0",
        contactNumber: _contactNumberController.text.trim(),
        vehicleNumber: _vehicleNumberController.text.trim(),
        activeRaces: 0,
        totalRaces: 0,
        racerImageUrl: _racerImage?.path,
        isLocalImage: true, // Set to true since we're using local images
      );

      Navigator.pop(context, racer);
    }
  }

  Widget _imagePickerBox({
    required File? image,
    required VoidCallback onPick,
    required VoidCallback onClear,
    required String label,
    String? initials,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF13386B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child:
                image != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    )
                    : initials != null
                    ? Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : Center(
                      child: Icon(Icons.add, color: Colors.white, size: 40),
                    ),
          ),
        ),
        if (image != null)
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onClear,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                  _input(_carModelController, "Enter car model"),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Upload Car image",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          SizedBox(height: 6),
                          _imagePickerBox(
                            image: _carImage,
                            onPick: () => _pickImage(true),
                            onClear: () => _clearImage(true),
                            label: "Car",
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Upload Racer Image",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          SizedBox(height: 6),
                          _imagePickerBox(
                            image: _racerImage,
                            onPick: () => _pickImage(false),
                            onClear: () => _clearImage(false),
                            label: "Racer",
                            initials: _racerImage == null ? initials : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  _label("Assign to Event"),
                  DropdownButtonFormField<Event>(
                    value: _selectedEvent,
                    items:
                        widget.events
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.title),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedEvent = val),
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
                    style: TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF13386B),
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
                  SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFCC29),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
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
