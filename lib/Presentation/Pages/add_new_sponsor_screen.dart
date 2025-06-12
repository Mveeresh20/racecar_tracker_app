import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_deal_screen.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/Services/sponsor_provider.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Presentation/Pages/make_deal_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:racecar_tracker/Services/racer_service.dart';
import 'package:racecar_tracker/Services/event_service.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/Services/sponsor_service.dart';
import 'package:racecar_tracker/Presentation/Pages/deals_screen.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/Presentation/Pages/add_new_racer_screen.dart';
import 'package:racecar_tracker/Presentation/Views/add_new_event_screen.dart';
import 'package:racecar_tracker/Services/racer_provider.dart';
import 'package:racecar_tracker/Services/event_provider.dart';

class AddNewSponsorScreen extends StatefulWidget {
  final SponsorProvider provider;
  final Sponsor? existingSponsor;

  const AddNewSponsorScreen({
    Key? key,
    required this.provider,
    this.existingSponsor,
  }) : super(key: key);

  @override
  _AddNewSponsorScreenState createState() => _AddNewSponsorScreenState();
}

class _AddNewSponsorScreenState extends State<AddNewSponsorScreen> {
  String? _validateEmail(String? value) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (value == null || value.isEmpty) return "Email is required";
    if (!regex.hasMatch(value)) return "Enter a valid email address";
    return null;
  }

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

  DateTime _selectedEndDate = DateTime.now();
  bool _hasDateSelected = false;
  Set<String> _selectedParts = {};

  String? _companyLogo;

  // Add currency formatter for sponsorship amount
  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    // Remove any non-digit characters except decimal point
    String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleanValue.isEmpty) return '';

    // Ensure only one decimal point
    List<String> parts = cleanValue.split('.');
    if (parts.length > 2) {
      cleanValue = parts[0] + '.' + parts.sublist(1).join('');
    }

    // Add dollar sign
    return '\$$cleanValue';
  }

  void _onSponsorshipAmountChanged(String value) {
    String formatted = _formatCurrency(value);
    if (formatted != value) {
      _sponsorshipAmountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _pickImage(bool isProfileImage) async {
    ImagePickerUtil().showImageSourceSelection(
      context,
      (String imagePath) {
        setState(() {
          // Store just the filename, the full URL will be constructed when displaying
          _companyLogo = imagePath;
          debugPrint('Logo path saved: $_companyLogo'); // Debug log
        });
      },
      (String error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $error')),
        );
      },
    );
  }

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
    // Initialize form with existing sponsor data if editing
    if (widget.existingSponsor != null) {
      _sponsorNameController.text = widget.existingSponsor!.name;
      _contactPersonController.text =
          widget.existingSponsor!.contactPerson ?? '';
      _contactNumberController.text =
          widget.existingSponsor!.contactNumber ?? '';
      _industryTypeController.text = widget.existingSponsor!.industryType ?? '';
      _sponsorshipAmountController.text =
          '\$${widget.existingSponsor!.sponsorshipAmount ?? ''}';
      _notesController.text = widget.existingSponsor!.notes ?? '';
      _companyLogo = widget.existingSponsor!.logoUrl ?? '';
      // _logoUploadController.text = widget.existingSponsor!.logoUrl ?? '';
      _emailController.text = widget.existingSponsor!.email;
      // Ensure end date is not in the past when editing
      final existingEndDate = widget.existingSponsor!.endDate;
      _selectedEndDate =
          existingEndDate.isBefore(DateTime.now())
              ? DateTime.now().add(const Duration(days: 365))
              : existingEndDate;
      _selectedParts = Set<String>.from(widget.existingSponsor!.parts);
    }

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
        final initials = Sponsor.generateInitials(
          _sponsorNameController.text.trim(),
        );

        // Create sponsor with validated data
        final sponsor = Sponsor(
          id: widget.existingSponsor?.id ?? const Uuid().v4(),
          userId: userId,
          initials: initials,
          name: _sponsorNameController.text.trim(),
          email: _emailController.text.trim(),
          contactPerson: _contactPersonController.text.trim(),
          contactNumber: _contactNumberController.text.trim(),
          industryType: _industryTypeController.text.trim(),
          logoUrl: _companyLogo, // This will be just the filename
          parts: _selectedParts.toList(),
          activeDeals: widget.existingSponsor?.activeDeals ?? 0,
          endDate: _selectedEndDate,
          status: widget.existingSponsor?.status ?? SponsorStatus.active,
          notes: _notesController.text.trim(),
          sponsorshipAmount: _sponsorshipAmountController.text.trim(),
          createdAt: widget.existingSponsor?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          totalDeals: widget.existingSponsor?.totalDeals ?? 0,
          commission: widget.existingSponsor?.commission ?? "0%",
          lastDealAmount: widget.existingSponsor?.lastDealAmount,
        );

        debugPrint(
          'Saving sponsor with logo URL: ${sponsor.logoUrl}',
        ); // Debug log

        // Save sponsor to database
        if (widget.existingSponsor != null) {
          await widget.provider.updateSponsor(sponsor);
        } else {
          await widget.provider.createSponsor(sponsor);
        }

        // Hide loading indicator and return to sponsors screen
        if (mounted) {
          Navigator.pop(context); // Remove loading indicator
          Navigator.pop(context, sponsor); // Return to sponsors screen
        }
      } catch (e) {
        // Hide loading indicator and show error
        if (mounted) {
          Navigator.pop(context); // Remove loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error ${widget.existingSponsor != null ? "updating" : "creating"} sponsor: $e',
              ),
            ),
          );
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
        final initials = Sponsor.generateInitials(
          _sponsorNameController.text.trim(),
        );

        // Always generate a new UUID for the sponsor
        final sponsorId = const Uuid().v4();

        // Create new sponsor with validated data
        final newSponsor = Sponsor(
          id: sponsorId, // Always use the generated ID
          userId: userId,
          initials: initials,
          name: _sponsorNameController.text.trim(),
          email: _emailController.text.trim(),
          contactPerson: _contactPersonController.text.trim(),
          contactNumber: _contactNumberController.text.trim(),
          industryType: _industryTypeController.text.trim(),
          logoUrl: _companyLogo,

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

        // Fetch required data for AddNewDealScreen
        final racerService = RacerService();
        final eventService = EventService();
        final sponsorService = SponsorService();

        // Load all required data
        final racers = await racerService.getRacersStream(userId).first;
        final events = await eventService.getUserEvents(userId).first;
        final sponsors = await sponsorService.getSponsorsStream(userId).first;

        // Check if we have all required data
        List<String> missingItems = [];
        if (racers.isEmpty) {
          missingItems.add('racers');
        }
        if (events.isEmpty) {
          missingItems.add('events');
        }
        if (sponsors.isEmpty) {
          missingItems.add('sponsors');
        }

        if (missingItems.isNotEmpty) {
          // Show missing data dialog with action buttons
          await _showMissingDataDialog(
            missingItems: missingItems,
            title: 'Missing Required Data',
            message:
                'To create a deal, you need to have at least one racer, event, and sponsor. Please add the missing items:',
          );
          return; // Exit the function
        }

        // Hide loading indicator and navigate to make deal screen
        if (mounted) {
          Navigator.pop(context); // Remove loading indicator
          final newDeal = await Navigator.push<DealItem>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddNewDealScreen(
                    sponsors: sponsors,
                    racers: racers,
                    events: events,
                  ),
            ),
          );

          // Handle the returned deal
          if (mounted && newDeal != null) {
            // Navigate to deals tab in main HomeScreen
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/deals',
              (route) => false,
            );

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sponsor and deal created successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
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
      firstDate: DateTime.now(), // Allow dates from 2020 onwards
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        _hasDateSelected = true;
      });
    }
  }

  // Add method to show missing data dialog with action buttons
  Future<void> _showMissingDataDialog({
    required List<String> missingItems,
    required String title,
    required String message,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF13386B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...missingItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFFFCC29),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            if (missingItems.contains('racers'))
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNewRacerScreen(),
                    ),
                  );
                  if (result == true) {
                    // Refresh racers list if needed
                    final userId = UserService().getCurrentUserId();
                    if (userId != null) {
                      await Provider.of<RacerProvider>(
                        context,
                        listen: false,
                      ).initializeRacers(userId);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC29),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Racer',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (missingItems.contains('events'))
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNewEventScreen(),
                    ),
                  );
                  // Refresh events after returning
                  final userId = UserService().getCurrentUserId();
                  if (userId != null) {
                    Provider.of<EventProvider>(
                      context,
                      listen: false,
                    ).initUserEvents(userId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC29),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Event',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (missingItems.contains('sponsors'))
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddNewSponsorScreen(
                            provider: Provider.of<SponsorProvider>(
                              context,
                              listen: false,
                            ),
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC29),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Sponsor',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        );
      },
    );
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                          widget.existingSponsor != null
                              ? "Edit Sponsor"
                              : "Add New Sponsor",
                          style: const TextStyle(
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
                validator: _validateEmail,
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildImagePicker(_companyLogo, true, "Logo Upload"),
              ),
              // _buildFormField(
              //   "Logo Upload",
              //   _logoUploadController,
              //   "Upload Logo of Sponsor Company",
              //   isOptional: true,
              // ),
              _buildDatePicker(),
              _buildFormField(
                "Expected Sponsorship Amount (USD)",
                _sponsorshipAmountController,
                "\$ Enter Amount",
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? "Please enter amount" : null,
                onChanged: _onSponsorshipAmountChanged,
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
                    icon: Icon(
                      widget.existingSponsor != null ? Icons.save : Icons.add,
                      color: Colors.black,
                      size: 16,
                    ),
                    label: Text(
                      widget.existingSponsor != null
                          ? "Update Sponsor"
                          : "Add Sponsor",
                      style: const TextStyle(
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
    Function(String)? onChanged,
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
            onChanged: onChanged,
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
                    _hasDateSelected
                        ? DateFormat('MM/dd/yyyy').format(_selectedEndDate)
                        : 'mm/dd/yyyy',
                    style: TextStyle(
                      color:
                          _hasDateSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                    ),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),

        /// Upload Box
        GestureDetector(
          onTap: () => _pickImage(isProfileImage),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF13386B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Upload logo of sponsors company...",
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Image.network(Images.logoImg),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// Show Uploaded Image with Cancel Icon
        if (imageResolvedUrl != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageResolvedUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 200,
                  alignment: Alignment.center,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildPlaceholder(isProfileImage),
                ),
              ),
              // Cancel button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _companyLogo = null;
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
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

  Widget _buildPartsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Preferred Branding Locations",
            style: context.titleSmall?.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: _buildPartRows()),
        ),

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16),
        //   child: Wrap(
        //     spacing: 10.0,
        //     runSpacing: 10.0,
        //     children:
        //         _availableParts.map((part) {
        //           return Container(
        //             decoration: BoxDecoration(
        //               color: const Color(0xFF27518A),
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               mainAxisSize: MainAxisSize.min,
        //               children: [
        //                 Container(
        //                   padding: EdgeInsets.zero,
        //                   child: Checkbox(
        //                     side: const BorderSide(color: Colors.white),
        //                     value: _selectedParts.contains(part),
        //                     onChanged: (bool? selected) {
        //                       setState(() {
        //                         if (selected == true) {
        //                           _selectedParts.add(part);
        //                         } else {
        //                           _selectedParts.remove(part);
        //                         }
        //                       });
        //                     },
        //                   ),
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.only(right: 16),
        //                   child: Text(
        //                     part,
        //                     style: context.labelLarge?.copyWith(
        //                       color: Colors.white,
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           );
        //         }).toList(),
        //   ),
        // ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPartBox(String part) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF27518A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              part,
              style: context.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPartRows() {
    List<Widget> rows = [];

    for (int i = 0; i < _availableParts.length; i += 2) {
      final String first = _availableParts[i];
      final String? second =
          (i + 1 < _availableParts.length) ? _availableParts[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPartBox(first),
              const SizedBox(width: 10),
              second != null ? _buildPartBox(second) : SizedBox(),
            ],
          ),
        ),
      );
    }

    return rows;
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
