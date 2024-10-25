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
  List<String?> _selectedVenues = [null]; // List to store selected venues
  List<String> selectedTags = []; // List to store selected tags
  List<String> _venues = []; // List to store venues from Firestore
  bool _isLoadingVenues = true; // State to track loading of venues

  String? _clubName; // Store the organizer's club name
  String? _clubId; // Store the organizer's club ID

  // List of available tags
  final List<String> _tags = [
    "Music", "Sports", "Tech", "Arts", "Health", "Business",
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrganizerDetails(); // Fetch the organizer's club details
    _fetchVenues(); // Fetch the venues from Firestore
  }

  Future<void> _fetchOrganizerDetails() async {
    // Get the current user's ID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      setState(() {
        _clubName = userDoc['clubName']; // Fetch the club name from the user document
        _clubId = _clubName; // Fetch the club ID from the user document
      });
    }
  }

  Future<void> _fetchVenues() async {
    try {
      // Fetch venues from Firestore
      QuerySnapshot venueSnapshot = await FirebaseFirestore.instance.collection('venues').get();

      setState(() {
        _venues = venueSnapshot.docs.map((doc) => doc['name'] as String).toList();
        _isLoadingVenues = false; // Loading is complete
      });
    } catch (error) {
      // Handle error if needed
      setState(() {
        _isLoadingVenues = false; // Stop loading even if there's an error
      });
      print('Error fetching venues: $error');
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
                    _buildVenueDropdowns(), // Multiple venue dropdowns
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

  // Build venue dropdowns with a '+' button for adding more venues
  Widget _buildVenueDropdowns() {
    return Column(
      children: List.generate(_selectedVenues.length, (index) {
        return Row(
          children: [
            Expanded(
              child: _buildVenueDropdown(index),
            ),
            if (_selectedVenues[index] != null && index == _selectedVenues.length - 1)
              IconButton(
                icon: Icon(Icons.add_circle, color: Color(0xFF801e15)),
                onPressed: () {
                  setState(() {
                    _selectedVenues.add(null);
                  });
                },
              ),
            if (_selectedVenues.length > 1)
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _selectedVenues.removeAt(index);
                  });
                },
              ),
          ],
        );
      }),
    );
  }

  // Venue Dropdown Builder
  Widget _buildVenueDropdown(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index == 0)
          const Text(
            'Venue',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 14,
              color: Color(0xFF801e15),
            ),
          ),
        const SizedBox(height: 8),
        _isLoadingVenues
            ? const CircularProgressIndicator()
            : DropdownButtonFormField<String>(
          value: _selectedVenues[index],
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
              _selectedVenues[index] = value;
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
          maxLines: isMultiline ? 4 : 1,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Date',
          style: TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 14,
            color: Color(0xFF801e15),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            setState(() {
              _eventDate = selectedDate;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFe8c9ab),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF801e15), width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF801e15)),
                const SizedBox(width: 10),
                Text(
                  _eventDate != null
                      ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}'
                      : 'Select Date',
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 14,
                    color: Color(0xFF801e15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Time Picker Builder
  Widget _buildTimePicker(BuildContext context, String label, TimeOfDay? selectedTime, Function(TimeOfDay) onTimeSelected) {
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
        GestureDetector(
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              onTimeSelected(pickedTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFe8c9ab),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF801e15), width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF801e15)),
                const SizedBox(width: 10),
                Text(
                  selectedTime != null ? selectedTime.format(context) : 'Select Time',
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 14,
                    color: Color(0xFF801e15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Tag Selection Builder
  Widget _buildTagSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 14,
            color: Color(0xFF801e15),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(
                tag,
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 14,
                  color: Color(0xFF801e15),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedTags.add(tag);
                  } else {
                    selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: const Color(0xFFe8c9ab),
              backgroundColor: const Color(0xFF801e15),
              checkmarkColor: const Color(0xFF801e15),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Save event to Firestore
  Future<void> _saveEvent() async {
    if (_clubId == null || _clubName == null) {
      // Show an error message if club details are not yet fetched
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Club details not loaded. Please try again.')),
      );
      return; // Exit the method if club details are not loaded
    }

    try {
      // Prepare the event data
      Map<String, dynamic> eventData = {
        'eventName': _eventNameController.text,
        'description': _descriptionController.text,
        'startTime': _startTime != null ? _startTime!.format(context) : null,
        'endTime': _endTime != null ? _endTime!.format(context) : null,
        'eventDate': _eventDate,
        'venues': _selectedVenues.whereType<String>().toList(), // Filter out null values
        'tags': selectedTags,
        'clubName': _clubName,
        'clubId': _clubId, // Add the club ID
        'createdBy': FirebaseAuth.instance.currentUser?.uid, // Save user ID as event creator
        'isVenueApproved': false, //setting the initial valuee as false, since not approved
      };

      // Save event to Firestore
      await FirebaseFirestore.instance.collection('events').add(eventData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );

      // Clear form fields
      _eventNameController.clear();
      _descriptionController.clear();
      setState(() {
        _startTime = null;
        _endTime = null;
        _eventDate = null;
        _selectedVenues = [null];
        selectedTags = [];
      });
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating event: $error')),
      );
    }
  }
}