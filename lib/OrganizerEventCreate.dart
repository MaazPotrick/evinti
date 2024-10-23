import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get the current user
import 'package:flutter/material.dart';

class OrganizerEventCreate extends StatefulWidget {
  const OrganizerEventCreate({Key? key}) : super(key: key);

  @override
  _OrganizerEventCreateState createState() => _OrganizerEventCreateState();
}

class _OrganizerEventCreateState extends State<OrganizerEventCreate> {
  // Controllers for capturing form input
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _eventDate; // Date for the event
  String? _selectedVenue; // Selected venue
  List<String> selectedTags = []; // List to store selected tags

  String? _clubName; // Store the organizer's club name

  // List of hardcoded venues
  final List<String> _venues = [
    "LR605 & LR606",
    "MPH",
    "Rooftop",
    "Classrooms",
    "Level 5 foyer",
  ];

  // List of available tags
  final List<String> _tags = [
    "Music", "Sports", "Tech", "Arts", "Health", "Business",
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrganizerDetails(); // Fetch the organizer's club name
  }

  Future<void> _fetchOrganizerDetails() async {
    // Get the current user's ID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      setState(() {
        _clubName = userDoc['clubName']; // Fetch the club name from the user document
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg4.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Bar with Back Button and Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Image.asset('assets/images/back2.png'),
                          iconSize: 40,
                        ),
                        Image.asset(
                          'assets/images/Logo2.png',
                          height: 80,
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create New Event',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 36,
                        color: Color(0xFF801e15),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Placeholder for event image
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(context, 'Event Name', _eventNameController),
                    const SizedBox(height: 20),
                    _buildVenueDropdown(),
                    const SizedBox(height: 20),
                    _buildDatePicker(context),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimePicker(context, 'Start Time', _startTime, (selectedTime) {
                          setState(() {
                            _startTime = selectedTime;
                          });
                        }),
                        const Text(
                          '—',
                          style: TextStyle(
                            fontFamily: 'FredokaOne',
                            fontSize: 18,
                            color: Color(0xFF801e15),
                          ),
                        ),
                        _buildTimePicker(context, 'End Time', _endTime, (selectedTime) {
                          setState(() {
                            _endTime = selectedTime;
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(context, 'Description', _descriptionController, isMultiline: true),
                    const SizedBox(height: 20),
                    _buildTagSelection(),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF801e15),
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _saveEvent, // Save event on press
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 18,
                          color: Color(0xFFe8c9ab),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Text Field Builder
  Widget _buildTextField(BuildContext context, String label, TextEditingController controller, {bool isMultiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 14,
            color: Color(0xFF801e15),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: isMultiline ? 5 : 1,
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 14,
            color: Color(0xFF801e15),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFe8c9ab),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF801e15),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF801e15),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Time Picker Builder
  Widget _buildTimePicker(BuildContext context, String label, TimeOfDay? selectedTime, Function(TimeOfDay) onTimePicked) {
    return GestureDetector(
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null) {
          onTimePicked(pickedTime);
        }
      },
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFe8c9ab),
          border: Border.all(color: const Color(0xFF801e15), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          selectedTime?.format(context) ?? label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 14,
            color: Color(0xFF801e15),
          ),
        ),
      ),
    );
  }

  // Venue Dropdown Builder
  Widget _buildVenueDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Venue',
          style: TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 14,
            color: Color(0xFF801e15),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedVenue,
          items: _venues.map((venue) {
            return DropdownMenuItem(
              value: venue,
              child: Text(
                venue,
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 14,
                  color: Color(0xFF801e15),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedVenue = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFe8c9ab),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF801e15),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF801e15),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Date Picker Builder
  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _eventDate ?? DateTime.now(),
          firstDate: DateTime(2021),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _eventDate = pickedDate;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFe8c9ab),
          border: Border.all(color: const Color(0xFF801e15), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _eventDate != null ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}' : 'Select Date',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 14,
            color: Color(0xFF801e15),
          ),
        ),
      ),
    );
  }

  // Tag Selection Widget
  Widget _buildTagSelection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _tags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedTags.remove(tag);
              } else {
                selectedTags.add(tag);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF801e15) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF801e15),
                width: 2,
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 16,
                color: isSelected ? Colors.white : const Color(0xFF801e15),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Save Event to Firebase
  void _saveEvent() async {
    if (_eventNameController.text.isEmpty ||
        _selectedVenue == null ||
        _descriptionController.text.isEmpty ||
        _startTime == null ||
        _endTime == null ||
        _eventDate == null) {
      // Show error if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields'),
      ));
      return;
    }

    if (_clubName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error fetching club information'),
      ));
      return;
    }

    // Generate a new document in the 'events' collection and get its eventId
    DocumentReference eventRef = FirebaseFirestore.instance.collection('events').doc();

    // Prepare event data
    Map<String, dynamic> eventData = {
      'eventId': eventRef.id,
      'eventName': _eventNameController.text,
      'venue': _selectedVenue,
      'eventDate': _eventDate, // Save the date
      'startTime': _startTime?.format(context),
      'endTime': _endTime?.format(context),
      'description': _descriptionController.text,
      'clubId': _clubName,
      'tags': selectedTags, // Save the tags
      'createdAt': Timestamp.now(),
      'isVenueApproved': false,
    };

    // Save event data to Firestore
    await eventRef.set(eventData);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Event created successfully!'),
    ));

    // Clear form fields after saving
    _eventNameController.clear();
    _descriptionController.clear();
    setState(() {
      _startTime = null;
      _endTime = null;
      _eventDate = null;
      _selectedVenue = null;
      selectedTags.clear();
    });
  }
}