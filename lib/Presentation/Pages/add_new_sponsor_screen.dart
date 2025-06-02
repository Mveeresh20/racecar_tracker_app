import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/Services/sponsor_provider.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Presentation/Pages/make_deal_screen.dart';
import 'package:uuid/uuid.dart';

class AddNewSponsorScreen extends StatefulWidget {
  final SponsorProvider provider;

  const AddNewSponsorScreen({Key? key, required this.provider})
    : super(key: key);

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
  final TextEditingController _sponsorshipAmountController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _logoUploadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 365));
  Set<String> _selectedParts = {};

  final List<String> _availableParts = [
    "Pit Banner",
    "Suit",
    "Car Hood",
    "Car Door",
    "Helmet",
    "Side Skirt",
    "Windshield",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize user ID when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sponsorProvider = Provider.of<SponsorProvider>(
        context,
        listen: false,
      );
      final userId = UserService().getCurrentUserId();
      if (userId != null) {
        sponsorProvider.setCurrentUserId(userId);
        sponsorProvider.initUserSponsors(userId);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userId = widget.provider.currentUserId;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Generate initials from sponsor name
        final initials = _sponsorNameController.text
            .split(' ')
            .where((word) => word.isNotEmpty)
            .map((word) => word[0].toUpperCase())
            .join('');

        // Generate a unique ID for the sponsor
        final sponsorId = const Uuid().v4();

        // Create new sponsor with validated data
        final newSponsor = Sponsor(
          id: sponsorId,
          userId: userId,
          initials: initials,
          name: _sponsorNameController.text.trim(),
          email: _emailController.text.trim(),
          contactPerson: _contactPersonController.text.trim(),
          contactNumber: _contactNumberController.text.trim(),
          industryType: _industryTypeController.text.trim(),
          logoUrl: _logoUploadController.text.trim(),
          parts: _selectedParts.toList(),
          activeDeals: 0,
          endDate: _selectedEndDate,
          status: SponsorStatus.active,
          notes: _notesController.text.trim(),
          sponsorshipAmount: _sponsorshipAmountController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          totalDeals: 0,
          commission: "0%",
        );

        // Save sponsor to database
        await widget.provider.createSponsor(newSponsor);

        // Hide loading indicator and return to sponsors screen
        if (mounted) {
          Navigator.pop(context); // Remove loading indicator
          Navigator.pop(context, newSponsor); // Return to sponsors screen
        }
      } catch (e) {
        // Hide loading indicator and show error
        if (mounted) {
          Navigator.pop(context); // Remove loading indicator
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error creating sponsor: $e')));
        }
      }
    }
  }

  Future<void> _submitAndMakeDeal() async {
    if (_formKey.currentState!.validate()) {
      final userId = widget.provider.currentUserId;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Generate initials from sponsor name
        final initials = _sponsorNameController.text
            .split(' ')
            .where((word) => word.isNotEmpty)
            .map((word) => word[0].toUpperCase())
            .join('');

        // Generate a unique ID for the sponsor
        final sponsorId = const Uuid().v4();

        // Create new sponsor with validated data
        final newSponsor = Sponsor(
          id: sponsorId,
          userId: userId,
          initials: initials,
          name: _sponsorNameController.text.trim(),
          email: _emailController.text.trim(),
          contactPerson: _contactPersonController.text.trim(),
          contactNumber: _contactNumberController.text.trim(),
          industryType: _industryTypeController.text.trim(),
          logoUrl: _logoUploadController.text.trim(),
          parts: _selectedParts.toList(),
          activeDeals: 0,
          endDate: _selectedEndDate,
          status: SponsorStatus.active,
          notes: _notesController.text.trim(),
          sponsorshipAmount: _sponsorshipAmountController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          totalDeals: 0,
          commission: "0%",
        );

        // Save sponsor to database
        await widget.provider.createSponsor(newSponsor);

        // Hide loading indicator and navigate to make deal screen
        if (mounted) {
          Navigator.pop(context); // Remove loading indicator
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MakeDealScreen(sponsor: newSponsor),
            ),
          );
        }
      } catch (e) {
        // Hide loading indicator and show error
        if (mounted) {
          Navigator.pop(context); // Remove loading indicator
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error creating sponsor: $e')));
        }
      }
    }
  }

  @override
  void dispose() {
    _sponsorNameController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _industryTypeController.dispose();
    _sponsorshipAmountController.dispose();
    _notesController.dispose();
    _logoUploadController.dispose();
    _emailController.dispose();
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
              // Header with gradient background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ).copyWith(top: 64, bottom: 18),
                decoration: const BoxDecoration(
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
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Add New Sponsor",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields
              _buildFormField(
                "Sponsor Name",
                _sponsorNameController,
                "Enter Sponsor Name",
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? "Please enter sponsor name"
                            : null,
              ),
              _buildFormField(
                "Contact Person",
                _contactPersonController,
                "Enter Contact Person Name",
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? "Enter Contact Person Name"
                            : null,
              ),
              _buildFormField(
                "Contact Number",
                _contactNumberController,
                "Enter Contact Number",
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? "Please enter contact number"
                            : null,
              ),
              _buildFormField(
                "Email",
                _emailController,
                "Enter Email Address",
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? "Please enter email" : null,
              ),
              _buildFormField(
                "Industry Type",
                _industryTypeController,
                "Enter Industry Type",
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? "Please enter industry type"
                            : null,
              ),
              _buildFormField(
                "Logo Upload",
                _logoUploadController,
                "Upload logo of sponsor's company",
                isOptional: true,
              ),
              _buildDatePicker(),
              _buildFormField(
                "Expected Sponsorship Amount (USD)",
                _sponsorshipAmountController,
                "Enter Amount",
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? "Please enter amount" : null,
              ),
              _buildPartsSelection(),
              _buildNotesField(),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.add, color: Colors.black, size: 16),
                    label: const Text(
                      "Add Sponsor",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC29),
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitAndMakeDeal,
                    child: const Text(
                      "Save & Make Deal",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC29),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hintText, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: context.titleSmall?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: controller,
            validator: isOptional ? null : validator,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF13386B),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              hintText: hintText,
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
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "End Date",
            style: context.titleSmall?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: 'Select Date',
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                fillColor: const Color(0xFF13386B),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    DateFormat('dd/MM/yyyy').format(_selectedEndDate),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPartsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      color: const Color(0xFF27518A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.zero,
                          child: Checkbox(
                            side: const BorderSide(color: Colors.white),
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Additional Notes",
            style: context.titleSmall?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
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
              fillColor: const Color(0xFF13386B),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              hintText: 'Write if any additional notes from sponsor...',
              hintStyle: context.bodyLarge?.copyWith(color: Colors.white),
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
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
