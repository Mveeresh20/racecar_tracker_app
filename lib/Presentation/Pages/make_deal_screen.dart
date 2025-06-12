// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:racecar_tracker/models/sponsor.dart';
// import 'package:racecar_tracker/models/racer.dart';
// import 'package:racecar_tracker/models/event.dart';
// import 'package:racecar_tracker/models/deal_item.dart';
// import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
// import 'package:racecar_tracker/Utils/theme_extensions.dart';
// import 'package:racecar_tracker/Services/deal_service.dart';
// import 'package:racecar_tracker/Services/racer_service.dart';
// import 'package:racecar_tracker/Services/event_service.dart';

// import 'package:racecar_tracker/Services/user_service.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MakeDealScreen extends StatefulWidget {
//   final Sponsor sponsor;

//   const MakeDealScreen({Key? key, required this.sponsor}) : super(key: key);

//   @override
//   _MakeDealScreenState createState() => _MakeDealScreenState();
// }

// class _MakeDealScreenState extends State<MakeDealScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _dealService = DealService();
//   final _racerService = RacerService();
//   final _eventService = EventService();
  

//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _raceTypeController = TextEditingController();
//   final TextEditingController _dealValueController = TextEditingController();
//   final TextEditingController _commissionController = TextEditingController();
//   final TextEditingController _renewalReminderController =
//       TextEditingController();
//   final TextEditingController _notesController = TextEditingController();

//   DateTime _startDate = DateTime.now();
//   DateTime _endDate = DateTime.now().add(const Duration(days: 365));
//   Set<String> _selectedParts = {};
//   List<File> _brandingImages = [];
//   Racer? _selectedRacer;
//   Event? _selectedEvent;
//   bool _isLoading = false;
//   List<Racer> _availableRacers = [];
//   List<Event> _availableEvents = [];
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _selectedParts = Set.from(widget.sponsor.parts);
//     _loadRacersAndEvents();
//   }

//   Future<void> _loadRacersAndEvents() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final userId = UserService().getCurrentUserId();
//       if (userId == null) throw Exception('User not logged in');

//       // Load racers using real-time stream
//       _racerService
//           .getRacersStream(userId)
//           .listen(
//             (racers) {
//               if (mounted) {
//                 setState(() {
//                   _availableRacers = racers;
//                   _isLoading = false;
//                 });
//               }
//             },
//             onError: (error) {
//               if (mounted) {
//                 setState(() {
//                   _error = error.toString();
//                   _isLoading = false;
//                 });
//               }
//             },
//           );

//       // Load events using real-time stream
//       _eventService.streamEvents().listen(
//         (events) {
//           if (mounted) {
//             setState(() {
//               _availableEvents = events;
//               _isLoading = false;
//             });
//           }
//         },
//         onError: (error) {
//           if (mounted) {
//             setState(() {
//               _error = error.toString();
//               _isLoading = false;
//             });
//           }
//         },
//       );
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _pickBrandingImage() async {
//     try {
//       final image = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         setState(() {
//           _brandingImages.add(File(image.path));
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
//       }
//     }
//   }

//   void _removeBrandingImage(int index) {
//     setState(() {
//       _brandingImages.removeAt(index);
//     });
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate() &&
//         _selectedRacer != null &&
//         _selectedEvent != null &&
//         _startDate != null &&
//         _endDate != null) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         final userId = FirebaseAuth.instance.currentUser?.uid;
//         if (userId == null) {
//           throw Exception('No user logged in');
//         }

//         // Create the deal
//         final dealId = await _dealService.createDeal(
//           userId: userId, // Add the required userId parameter
//           sponsorId: widget.sponsor.id,
//           racerId: _selectedRacer!.id,
//           eventId: _selectedEvent!.id,
//           sponsorInitials: widget.sponsor.initials,
//           racerInitials: _selectedRacer!.initials,
//           title: _titleController.text.trim(),
//           raceType: _raceTypeController.text.trim(),
//           dealValue: double.parse(
//             _dealValueController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
//           ),
//           commissionPercentage: double.parse(
//             _commissionController.text.replaceAll('%', ''),
//           ),
//           advertisingPositions: _selectedParts.toList(),
//           startDate: _startDate!,
//           endDate: _endDate!,
//           renewalReminder: _renewalReminderController.text.trim(),
//           status: DealStatusType.pending,
//           brandingImages: _brandingImages,
//           context: context, // Add context parameter
//         );

//         if (!mounted) return;

//         // Create DealItem for the return value
//         final deal = DealItem(
//           id: dealId,
//           sponsorId: widget.sponsor.id,
//           racerId: _selectedRacer!.id,
//           eventId: _selectedEvent!.id,
//           title: _titleController.text.trim(),
//           raceType: _raceTypeController.text.trim(),
//           dealValue: _dealValueController.text,
//           commission: '${_commissionController.text}%',
//           renewalDate: DateFormat('MMMM yyyy').format(_endDate!),
//           parts: _selectedParts.toList(),
//           status: DealStatusType.pending,
//           sponsorInitials: widget.sponsor.initials,
//           racerInitials: _selectedRacer!.initials,
//         );

//         Navigator.pop(context, deal);
//       } catch (e) {
//         print('Error creating deal: $e');
//         if (!mounted) return;

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error creating deal: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _raceTypeController.dispose();
//     _dealValueController.dispose();
//     _commissionController.dispose();
//     _renewalReminderController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isStartDate ? _startDate : _endDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = picked;
//         } else {
//           _endDate = picked;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with gradient background
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                 ).copyWith(top: 64, bottom: 18),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF2D5586), Color(0xFF171E45)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(
//                             Icons.arrow_back_ios_new_outlined,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         const SizedBox(width: 16),
//                         const Text(
//                           "Make New Deal",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       "Sponsor: ${widget.sponsor.name}",
//                       style: const TextStyle(color: Colors.white, fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Add Racer Selection
//               _buildDropdown<Racer>(
//                 "Select Racer",
//                 _selectedRacer,
//                 _availableRacers,
//                 (racer) => racer.name,
//                 (racer) {
//                   setState(() => _selectedRacer = racer);
//                 },
//               ),

//               // Add Event Selection
//               _buildDropdown<Event>(
//                 "Select Event",
//                 _selectedEvent,
//                 _availableEvents,
//                 (event) => event.name,
//                 (event) {
//                   setState(() => _selectedEvent = event);
//                 },
//               ),

//               // Form Fields
//               _buildFormField(
//                 "Deal Title",
//                 _titleController,
//                 "Enter Deal Title",
//                 validator:
//                     (value) =>
//                         value?.isEmpty ?? true
//                             ? "Please enter deal title"
//                             : null,
//               ),
//             _buildFormField(
//                 "Race Type",
//                 _raceTypeController,
//                 "Enter Race Type",
//                 validator:
//                     (value) =>
//                         value?.isEmpty ?? true
//                             ? "Please enter race type"
//                             : null,
//               ),
//               _buildFormField(
//                 "Deal Value (USD)",
//                 _dealValueController,
//                 "Enter Amount",
//                 keyboardType: TextInputType.number,
//                 validator:
//                     (value) =>
//                         value?.isEmpty ?? true ? "Please enter amount" : null,
//               ),
//               _buildFormField(
//                 "Commission (%)",
//                 _commissionController,
//                 "Enter Commission Percentage",
//                 keyboardType: TextInputType.number,
//                 validator:
//                     (value) =>
//                         value?.isEmpty ?? true
//                             ? "Please enter commission"
//                             : null,
//               ),
//               _buildDatePicker("Start Date", true),
//               _buildDatePicker("End Date", false),
//               _buildFormField(
//                 "Renewal Reminder",
//                 _renewalReminderController,
//                 "Enter Renewal Reminder",
//                 validator:
//                     (value) =>
//                         value?.isEmpty ?? true
//                             ? "Please enter renewal reminder"
//                             : null,
//               ),
//               _buildPartsSelection(),
//               _buildNotesField(),

//               // Submit Button
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: kDefaultPadding,
//                   vertical: 8.0,
//                 ),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _submitForm,
//                     child: const Text(
//                       "Create Deal",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFFFCC29),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(60),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFormField(
//     String label,
//     TextEditingController controller,
//     String hintText, {
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             label,
//             style: context.titleSmall?.copyWith(color: Colors.white),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: TextFormField(
//             controller: controller,
//             validator: validator,
//             keyboardType: keyboardType,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color(0xFF13386B),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//                 vertical: 8,
//               ),
//               hintText: hintText,
//               hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.red),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.red),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildDatePicker(String label, bool isStartDate) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             label,
//             style: context.titleSmall?.copyWith(color: Colors.white),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: InkWell(
//             onTap: () => _selectDate(context, isStartDate),
//             child: InputDecorator(
//               decoration: InputDecoration(
//                 hintText: 'Select Date',
//                 filled: true,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 8,
//                 ),
//                 fillColor: const Color(0xFF13386B),
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Text(
//                     DateFormat(
//                       'dd/MM/yyyy',
//                     ).format(isStartDate ? _startDate : _endDate),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   const Icon(Icons.calendar_today, color: Colors.white),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildPartsSelection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             "Advertising Positions:",
//             style: context.titleSmall?.copyWith(color: Colors.white),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Wrap(
//             spacing: 10.0,
//             runSpacing: 10.0,
//             children:
//                 widget.sponsor.parts.map((part) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF27518A),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.zero,
//                           child: Checkbox(
//                             side: const BorderSide(color: Colors.white),
//                             value: _selectedParts.contains(part),
//                             onChanged: (bool? selected) {
//                               setState(() {
//                                 if (selected == true) {
//                                   _selectedParts.add(part);
//                                 } else {
//                                   _selectedParts.remove(part);
//                                 }
//                               });
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(right: 16),
//                           child: Text(
//                             part,
//                             style: context.labelLarge?.copyWith(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildNotesField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             "Additional Notes",
//             style: context.titleSmall?.copyWith(color: Colors.white),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: TextFormField(
//             controller: _notesController,
//             maxLines: 5,
//             keyboardType: TextInputType.text,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               alignLabelWithHint: true,
//               filled: true,
//               fillColor: const Color(0xFF13386B),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//                 vertical: 8,
//               ),
//               hintText: 'Write any additional notes about the deal...',
//               hintStyle: context.bodyLarge?.copyWith(color: Colors.white),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.red),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.red),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildDropdown<T>(
//     String label,
//     T? selectedValue,
//     List<T> items,
//     String Function(T) getLabel,
//     void Function(T?) onChanged,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             label,
//             style: context.titleSmall?.copyWith(color: Colors.white),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFF13386B),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.white.withOpacity(0.2)),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<T>(
//                 value: selectedValue,
//                 isExpanded: true,
//                 dropdownColor: const Color(0xFF13386B),
//                 style: const TextStyle(color: Colors.white),
//                 hint: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     'Select $label',
//                     style: TextStyle(color: Colors.white.withOpacity(0.6)),
//                   ),
//                 ),
//                 items:
//                     items.map((T item) {
//                       return DropdownMenuItem<T>(
//                         value: item,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Text(
//                             getLabel(item),
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                 onChanged: onChanged,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildBrandingImagesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             "Branding Images",
//             style: context.titleSmall?.copyWith(color: Colors.white),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFF13386B),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.white.withOpacity(0.2)),
//             ),
//             child: Column(
//               children: [
//                 // Image Grid
//                 if (_brandingImages.isNotEmpty)
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     padding: const EdgeInsets.all(8),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                           crossAxisSpacing: 8,
//                           mainAxisSpacing: 8,
//                         ),
//                     itemCount: _brandingImages.length,
//                     itemBuilder: (context, index) {
//                       return Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.file(
//                               _brandingImages[index],
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                               height: double.infinity,
//                               errorBuilder:
//                                   (context, error, stackTrace) =>
//                                       const Icon(Icons.error),
//                             ),
//                           ),
//                           Positioned(
//                             top: 4,
//                             right: 4,
//                             child: GestureDetector(
//                               onTap: () => _removeBrandingImage(index),
//                               child: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.5),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.close,
//                                   color: Colors.white,
//                                   size: 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),

//                 // Add Image Button
//                 Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: ElevatedButton.icon(
//                     onPressed: _pickBrandingImage,
//                     icon: const Icon(Icons.add_photo_alternate),
//                     label: const Text('Add Branding Image'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF27518A),
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
// }
