import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/sponsor.dart'; // Import your Sponsor model
import 'package:intl/intl.dart'; // For date formatting (if you add a date picker)

class AddNewSponsorScreen extends StatefulWidget {
  @override
  _AddNewSponsorScreenState createState() => _AddNewSponsorScreenState();
}

class _AddNewSponsorScreenState extends State<AddNewSponsorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sponsorNameController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _industryTypeController = TextEditingController();
  final TextEditingController _expectedAmountController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _logoUploadController = TextEditingController();
  final TextEditingController _sponsorshipAmountController =
      TextEditingController();

  DateTime _selectedEndDate = DateTime.now().add(
    Duration(days: 365),
  ); // Default to 1 year from now
  Set<String> _selectedParts = {}; // For checkboxes

  // Example list of available parts (can be moved to a constants file)
  final List<String> _availableParts = [
    "Pit Banner",
    "Suit",
    "Car Hood",
    "Car Door",
    "Helmet",
    "Side Skirt",
    "Windshield",
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Get data from controllers
      final String sponsorName = _sponsorNameController.text;
      final String contactPerson = _contactPersonController.text;
      final String contactNumber = _contactNumberController.text;
      final String industryType = _industryTypeController.text;

      final String logoUpload = _logoUploadController.text;
      final String sponsorshipAmount = _sponsorshipAmountController.text;

      // final String expectedAmount = _expectedAmountController.text; // Use if making a deal immediately

      // Generate initials
      final String initials = Sponsor.generateInitials(sponsorName);

      // Create the new Sponsor object
      final newSponsor = Sponsor(
        id: "sponsor1",
        initials: initials,
        name: sponsorName,
        email:
            "default@email.com", // You might want to add an email field to the form
        contactPerson: contactPerson,
        contactNumber: contactNumber,
        industryType: industryType,
        // logoUrl: null, // Handle logo upload separately
        parts: _selectedParts.toList(),
        activeDeals: 0, // New sponsors start with 0 active deals
        endDate: _selectedEndDate,
        status: SponsorStatus.active, // New sponsors are active
        notes: _notesController.text,
      );

      // Navigate back to the Sponsors screen and pass the new sponsor
      Navigator.pop(context, newSponsor);
    }
  }

  @override
  void dispose() {
    _sponsorNameController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _industryTypeController.dispose();
    _expectedAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 16),
                        Text(
                          "Add New Sponsor",
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Sponsor Name",
                  style: context.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _sponsorNameController,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter sponsor name";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,

                    fillColor: Color(0xFF13386B),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

                    hintText: 'Enter Sponsor Name',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),

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
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Contact Person",
                  style: context.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _contactPersonController,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Contact Person Name";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,

                    fillColor: Color(0xFF13386B),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

                    labelStyle: context.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    hintText: 'Enter Contact Person Name',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),

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
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Contact Number",
                  style: context.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _contactNumberController,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter contact number";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,

                    fillColor: Color(0xFF13386B),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

                    labelStyle: context.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    hintText: 'Enter Contact Number..',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),

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
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Industry Type",
                  style: context.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _industryTypeController,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter industry type";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,

                    fillColor: Color(0xFF13386B),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

                    labelStyle: context.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    hintText: 'Enter Industry Type..',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),

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
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "logo upload",
                  style: context.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _logoUploadController,

                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return "Please enter logo upload";
                  //   }
                  //   return null;
                  // },
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,

                    fillColor: Color(0xFF13386B),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

                    labelStyle: context.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    hintText: 'upload logo of sponsors company',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),

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
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Date Picker for End Date (optional, but good for Sponsor model)
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "End Date",
                  style: context.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Select Date',
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      fillColor: Color(0xFF13386B),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedEndDate),
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(Icons.calendar_today, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Expected  Sponsorship Amount(USD)",
                  style: context.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _sponsorshipAmountController,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter amount";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,

                    fillColor: Color(0xFF13386B),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

                    labelStyle: context.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    hintText: 'Enter Amount',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),

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
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Preferred Branding Locations:",
                  style: context.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children:
                      _availableParts.map((part) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF27518A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.zero,
                                child: Checkbox(
                                  side: BorderSide(color: Colors.white),

                                  value: _selectedParts.contains(part),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedParts.add(part);
                                      } else {
                                        _selectedParts.remove(part);
                                      }
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Text(
                                  part,
                                  style: context.labelLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: Wrap(
              //     spacing: 8.0,
              //     children:
              //         _availableParts.map((part) {
              //           return FilterChip(
              //             label: Text(part),
              //             selected: _selectedParts.contains(part),
              //             onSelected: (selected) {
              //               setState(() {
              //                 if (selected) {
              //                   _selectedParts.add(part);
              //                 } else {
              //                   _selectedParts.remove(part);
              //                 }
              //               });
              //             },
              //           );
              //         }).toList(),
              //   ),
              // ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Additional Notes",
                  style: context.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 5,

                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    filled: true,

                    fillColor: Color(0xFF13386B),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

                    hintText: 'Write if any additional notes from sponsor...',
                    hintStyle: context.bodyLarge?.copyWith(color: Colors.white),

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
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _submitForm();
                      // Handle Add Sponsor button tap
                      print("Add Sponsor button tapped!");
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 16,
                    ), // Add icon
                    label: const Text(
                      "Add Sponsor", // Button text
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(
                        0xFFFFCC29,
                      ), // Use your yellow button color
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
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity, // Expand to full width
                  child: ElevatedButton(
                    onPressed: () {
                      print("Add Sponsor button tapped!");
                    },
                    child: Text(
                      "Save & Make Deal",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCC29), // Yellow background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          60,
                        ), // Rounded edges
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
}
