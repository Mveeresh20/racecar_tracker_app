import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:racecar_tracker/models/sponsor.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/deal_detail_item.dart';

import 'package:racecar_tracker/Services/deal_service.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNewDealScreen extends StatefulWidget {
  final List<Sponsor> sponsors;
  final List<Racer> racers;
  final List<Event> events;
  final DealDetailItem? existingDeal;

  const AddNewDealScreen({
    Key? key,
    required this.sponsors,
    required this.racers,
    required this.events,
    this.existingDeal,
  }) : super(key: key);

  @override
  State<AddNewDealScreen> createState() => _AddNewDealScreenState();
}

class _AddNewDealScreenState extends State<AddNewDealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dealService = DealService();
  final _uuid = const Uuid();

  Sponsor? _selectedSponsor;
  Racer? _selectedRacer;
  Event? _selectedEvent;

  final TextEditingController _dealAmountController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _earnController = TextEditingController();

  DealStatusType _paymentStatus = DealStatusType.pending;

  final List<String> _brandingLocations = [
    "Pit Banner",
    "Suit",
    "Car Hood",
    "Car Door",
    "Helmet",
    "Side Skirt",
    "Windshield",
  ];
  Set<String> _selectedBranding = {};

  List<File> _brandingImages = [];

  DateTime? _startDate;
  DateTime? _endDate;
  String? _renewalReminder;

  final List<String> _renewalReminders = [
    "1 Day Before",
    "2 Days Before",
    "1 Week Before",
    "2 Weeks Before",
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize form with existing deal data if editing
    if (widget.existingDeal != null) {
      _selectedSponsor = widget.sponsors.firstWhere(
        (s) => s.id == widget.existingDeal!.sponsorId,
        orElse: () => widget.sponsors.first,
      );
      _selectedRacer = widget.racers.firstWhere(
        (r) => r.id == widget.existingDeal!.racerId,
        orElse: () => widget.racers.first,
      );
      _selectedEvent = widget.events.firstWhere(
        (e) => e.id == widget.existingDeal!.eventId,
        orElse: () => widget.events.first,
      );

      _dealAmountController.text =
          '\$${widget.existingDeal!.dealValue.toString()}';
      _commissionController.text =
          '${widget.existingDeal!.commissionPercentage.toString()}';
      _earnController.text =
          '\$${widget.existingDeal!.commissionAmount.toString()}';
      _selectedBranding = Set<String>.from(widget.existingDeal!.parts);
      _startDate = widget.existingDeal!.startDate;
      _endDate = widget.existingDeal!.endDate;
      _renewalReminder = widget.existingDeal!.renewalReminder;
      _paymentStatus = widget.existingDeal!.status;
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime lastDate = DateTime(2100);

    final DateTime initialDate =
        isStart ? (_startDate ?? now) : (_endDate ?? (_startDate ?? now));

    final DateTime minDate =
        isStart ? now : (_startDate?.isAfter(now) == true ? _startDate! : now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(),
            dialogBackgroundColor: const Color(0xFF13386B),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          if (_startDate == null || picked.isAfter(_startDate!)) {
            _endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End date must be after start date'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _brandingImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both start and end dates'),
          ),
        );
        return;
      }

      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date must be after start date')),
        );
        return;
      }

      // Validate commission percentage early
      final commissionPercentage =
          double.tryParse(
            _commissionController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0;

      if (commissionPercentage > 100.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commission percentage cannot be greater than 100%'),
            backgroundColor: Colors.blueGrey,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          throw Exception('No user logged in');
        }

        // Generate initials
        final sponsorInitials = _selectedSponsor!.initials;
        final racerInitials = _selectedRacer!.initials;

        final dealValue =
            double.tryParse(
              _dealAmountController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
            ) ??
            0.0;

        // Commission percentage already validated above
        // final commissionPercentage = double.tryParse(...) - removed duplicate

        if (widget.existingDeal != null) {
          // Update existing deal
          await _dealService.updateDeal(
            widget.existingDeal!.id,
            userId: userId,
            sponsorId: _selectedSponsor!.id,
            racerId: _selectedRacer!.id,
            eventId: _selectedEvent!.id,
            sponsorInitials: sponsorInitials,
            racerInitials: racerInitials,
            title: "${_selectedSponsor!.name} X ${_selectedRacer!.name}",
            raceType: _selectedEvent!.type,
            dealValue: dealValue,
            commissionPercentage: commissionPercentage,
            advertisingPositions: _selectedBranding.toList(),
            startDate: _startDate!,
            endDate: _endDate!,
            renewalReminder: _renewalReminder ?? "2 Days Before",
            status: _paymentStatus,
            brandingImages: _brandingImages,
            context: context,
          );

          final updatedDeal = DealItem(
            id: widget.existingDeal!.id,
            sponsorId: _selectedSponsor!.id,
            racerId: _selectedRacer!.id,
            eventId: _selectedEvent!.id,
            title: "${_selectedSponsor!.name} X ${_selectedRacer!.name}",
            raceType: _selectedEvent!.type,
            dealValue: '\$${dealValue.toStringAsFixed(2)}',
            commission: '${commissionPercentage.toStringAsFixed(1)}%',
            renewalDate: DateFormat('MMMM yyyy').format(_endDate!),
            parts: _selectedBranding.toList(),
            status: _paymentStatus,
            sponsorInitials: sponsorInitials,
            racerInitials: racerInitials,
          );

          if (!mounted) return;
          Navigator.pop(context, updatedDeal);
        } else {
          // Create new deal
          final dealId = await _dealService.createDeal(
            userId: userId,
            sponsorId: _selectedSponsor!.id,
            racerId: _selectedRacer!.id,
            eventId: _selectedEvent!.id,
            sponsorInitials: sponsorInitials,
            racerInitials: racerInitials,
            title: "${_selectedSponsor!.name} X ${_selectedRacer!.name}",
            raceType: _selectedEvent!.type,
            dealValue: dealValue,
            commissionPercentage: commissionPercentage,
            advertisingPositions: _selectedBranding.toList(),
            startDate: _startDate!,
            endDate: _endDate!,
            renewalReminder: _renewalReminder ?? "2 Days Before",
            status: _paymentStatus,
            brandingImages: _brandingImages,
            context: context,
          );

          final deal = DealItem(
            id: dealId,
            sponsorId: _selectedSponsor!.id,
            racerId: _selectedRacer!.id,
            eventId: _selectedEvent!.id,
            title: "${_selectedSponsor!.name} X ${_selectedRacer!.name}",
            raceType: _selectedEvent!.type,
            dealValue: '\$${dealValue.toStringAsFixed(2)}',
            commission: '${commissionPercentage.toStringAsFixed(1)}%',
            renewalDate: DateFormat('MMMM yyyy').format(_endDate!),
            parts: _selectedBranding.toList(),
            status: _paymentStatus,
            sponsorInitials: sponsorInitials,
            racerInitials: racerInitials,
          );

          if (!mounted) return;
          Navigator.pop(context, deal);
        }
      } catch (e) {
        print(
          'Error ${widget.existingDeal != null ? 'updating' : 'creating'} deal: $e',
        );
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${widget.existingDeal != null ? 'updating' : 'creating'} deal: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.existingDeal != null
                              ? "Edit Deal"
                              : "Make Deal",
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
              SizedBox(height: 20),

              // Dropdowns
              _buildLabel("Select Sponsor"),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<Sponsor>(
                  value: _selectedSponsor,
                  items:
                      widget.sponsors
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s.name,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedSponsor = val),
                  decoration: _dropdownDecoration(),
                  hint: Text(
                    "Select sponsor...",
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Color(0xFF13386B),
                  validator: (val) => val == null ? "Required" : null,
                ),
              ),
              SizedBox(height: 16),
              _buildLabel("Select Racer"),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<Racer>(
                  value: _selectedRacer,
                  items:
                      widget.racers
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r.name,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedRacer = val),
                  decoration: _dropdownDecoration(),
                  hint: Text(
                    "Select Racer...",
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Color(0xFF13386B),
                  validator: (val) => val == null ? "Required" : null,
                ),
              ),
              SizedBox(height: 16),
              _buildLabel("Select Race Event"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<Event>(
                  value: _selectedEvent,
                  items:
                      widget.events
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.name,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedEvent = val),
                  decoration: _dropdownDecoration(),
                  hint: Text(
                    "Select Race Event...",
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Color(0xFF13386B),
                  validator: (val) => val == null ? "Required" : null,
                ),
              ),
              SizedBox(height: 16),

              // Deal Terms & Commission
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "\$",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    SizedBox(width: 4),

                    Text(
                      "Deal Terms & Commission",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),
              _buildLabel("Total Deal Amount"),
              SizedBox(height: 8),

              _buildTextField(
                _dealAmountController,
                "\$ Enter Amount",
                keyboardType: TextInputType.number,
                onChanged: _onDealAmountChanged,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLabel("Your Commission"),
                        _buildTextField(
                          _commissionController,
                          "\$ Enter Commission",
                          keyboardType: TextInputType.number,
                          onChanged: _onCommissionChanged,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLabel("Your Earnings"),
                        _buildTextField(
                          _earnController,
                          "\$ Your Earnings",
                          keyboardType: TextInputType.number,
                          onChanged: _onEarnChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Payment Status
              _buildLabel("Payment Status"),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    // DUE Option
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            _paymentStatus == DealStatusType.pending
                                ? Colors.orange
                                : const Color(0xFF13386B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _paymentStatus == DealStatusType.pending,
                            activeColor: Colors.white, // tick color
                            checkColor: Colors.orange, // checkbox fill
                            side: const BorderSide(color: Colors.white),
                            onChanged: (val) {
                              setState(() {
                                _paymentStatus = DealStatusType.pending;
                              });
                            },
                          ),
                          const Text(
                            "Due",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // PAID Option
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            _paymentStatus == DealStatusType.paid
                                ? const Color(0xFF24C166)
                                : const Color(0xFF13386B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _paymentStatus == DealStatusType.paid,
                            activeColor: Colors.white,
                            checkColor: const Color(0xFF24C166),
                            side: const BorderSide(color: Colors.white),
                            onChanged: (val) {
                              setState(() {
                                _paymentStatus = DealStatusType.paid;
                              });
                            },
                          ),
                          const Text(
                            "Paid",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Branding Locations
              _buildLabel("Assigned Branding Locations"),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(children: _buildBoxRows()),
              ),

              SizedBox(height: 16),
              // Logo Upload (Branding Images)
              _buildLabel("Logo Upload"),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF27518A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Upload logo to advertise ...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.upload, color: Colors.white),
                        onPressed: _pickImages,
                      ),
                    ],
                  ),
                ),
              ),
              if (_brandingImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          _brandingImages.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final file = entry.value;

                            if (!file.existsSync()) {
                              print(
                                'Error: File does NOT exist at path: ${file.path}',
                              );
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Image.file(
                                    file,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _brandingImages.removeAt(idx);
                                      });
                                    },
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              SizedBox(height: 16),

              // Deal Duration & Renewal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.white),
                    Text(
                      "Deal Duration & Renewal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Start Date"),
                        SizedBox(height: 4),

                        _buildDatePicker(
                          context,
                          _startDate,
                          "mm/dd/yyyy",
                          (ctx) => _pickDate(ctx, true),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("End Date"),
                        SizedBox(height: 4),
                        _buildDatePicker(
                          context,
                          _endDate,
                          "mm/dd/yyyy",
                          (ctx) => _pickDate(ctx, false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
              _buildLabel("Renewal Reminder"),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: _renewalReminder,
                  items:
                      _renewalReminders
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _renewalReminder = val),
                  decoration: _dropdownDecoration(),
                  hint: Text(
                    "Select Renewal Reminder...",
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Color(0xFF13386B),
                  validator: (val) => val == null ? "Required" : null,
                ),
              ),

              SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitForm,
                    icon:
                        _isLoading
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                            : Icon(
                              widget.existingDeal != null
                                  ? Icons.save
                                  : Icons.add,
                              color: Colors.black,
                            ),
                    label: Text(
                      _isLoading
                          ? "Saving..."
                          : (widget.existingDeal != null
                              ? "Update Deal"
                              : "Save Deal"),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC29),
                      disabledBackgroundColor: const Color(0xFFFFCC29),
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
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    ),
  );
  List<Widget> _buildBoxRows() {
    List<Widget> rows = [];

    for (int i = 0; i < _brandingLocations.length; i += 2) {
      final first = _brandingLocations[i];
      final second =
          (i + 1 < _brandingLocations.length)
              ? _brandingLocations[i + 1]
              : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBrandingBox(first),
              second != null
                  ? _buildBrandingBox(second)
                  : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                  ), // Placeholder for spacing
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildBrandingBox(String part) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF27518A),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            side: BorderSide(color: Colors.white),
            value: _selectedBranding.contains(part),
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  _selectedBranding.add(part);
                } else {
                  _selectedBranding.remove(part);
                }
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(part, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration() => InputDecoration(
    alignLabelWithHint: true,
    filled: true,
    fillColor: const Color(0xFF13386B),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

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
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          alignLabelWithHint: true,
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
          errorStyle: const TextStyle(color: Colors.red),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (keyboardType == TextInputType.number) {
            final number = double.tryParse(
              value.replaceAll(RegExp(r'[^0-9.]'), ''),
            );
            if (number == null) {
              return 'Please enter a valid number';
            }
            if (number <= 0) {
              return 'Please enter a number greater than 0';
            }
          }
          return null;
        },
      ),
    );
  }

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
            alignLabelWithHint: true,
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

  // Add formatters for currency
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

  void _onDealAmountChanged(String value) {
    String formatted = _formatCurrency(value);
    if (formatted != value) {
      _dealAmountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _onCommissionChanged(String value) {
    String formatted = _formatCurrency(value);
    if (formatted != value) {
      _commissionController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _onEarnChanged(String value) {
    String formatted = _formatCurrency(value);
    if (formatted != value) {
      _earnController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}
