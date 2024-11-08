import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OrganizerEventEdit extends StatefulWidget {
  final Map<String, dynamic> event; // Event data passed from the previous page
  final String eventDocId;           // Event document ID from Firestore

  const OrganizerEventEdit({Key? key, required this.event, required this.eventDocId}) : super(key: key);

  @override
  _OrganizerEventEditState createState() => _OrganizerEventEditState();
}

class _OrganizerEventEditState extends State<OrganizerEventEdit> {
  late TextEditingController _eventNameController;
  late TextEditingController _descriptionController;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _eventDate; // Event date
  List<String?> _selectedVenues = [null]; // Selected venues list
  List<String> _venues = []; // Available venues list from Firestore
  bool _isLoadingVenues = true; // Loading state for venues
  List<String> selectedTags = []; // Selected tags list
  File? _selectedImage; // File to store the selected image
  String? _imageUrl; // Store the uploaded image URL

  // List of available tags
  final List<String> _tags = [
    "Music", "Sports", "Alternative", "Arts", "Health", "Business",
    "Cultural", "Food", "Gaming", "Educational", "Socializing"
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current event data
    _eventNameController = TextEditingController(text: widget.event['eventName']);
    _descriptionController = TextEditingController(text: widget.event['description']);
    _startTime = _parseTime(widget.event['startTime']);
    _endTime = _parseTime(widget.event['endTime']);
    _eventDate = (widget.event['eventDate'] as Timestamp?)?.toDate();
    _selectedVenues = List<String>.from(widget.event['venues'] ?? [null]);
    selectedTags = List<String>.from(widget.event['tags'] ?? []);
    _imageUrl = widget.event['imageUrl'] as String?; // Initialize image URL

    _fetchVenues(); // Fetch available venues from Firestore
  }


  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFe8c9ab),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 20,
              color: Color(0xFF801e15),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFF801e15),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 16,
                  color: Color(0xFF801e15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFe8c9ab),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Success',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 20,
              color: Color(0xFF801e15),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFF801e15),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 16,
                  color: Color(0xFF801e15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to select an image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Method to upload the image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('event_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask.whenComplete(() {});
      _imageUrl = await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      showErrorDialog('Failed to upload image: $e');
    }
  }

  // Fetch venues from Firestore
  Future<void> _fetchVenues() async {
    try {
      QuerySnapshot venueSnapshot = await FirebaseFirestore.instance.collection('venues').get();
      setState(() {
        _venues = venueSnapshot.docs.map((doc) => doc['name'] as String).toList();
        _isLoadingVenues = false; // Loading completed
      });
    } catch (error) {
      setState(() {
        _isLoadingVenues = false; // Stop loading if there's an error
      });
      print('Error fetching venues: $error');
    }
  }

  // Helper method to parse time from a string (e.g., "08:00 AM")
  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final format = RegExp(r'(\d+):(\d+)\s*(AM|PM)');
    final match = format.firstMatch(timeString);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      if (match.group(3) == 'PM' && hour != 12) {
        hour += 12;
      } else if (match.group(3) == 'AM' && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  // Add a widget to display and select the event image
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          image: _selectedImage != null
              ? DecorationImage(
            image: FileImage(_selectedImage!),
            fit: BoxFit.cover,
          )
              : _imageUrl != null
              ? DecorationImage(
            image: NetworkImage(_imageUrl!),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: _selectedImage == null && _imageUrl == null
            ? const Icon(
          Icons.image,
          size: 100,
          color: Colors.black,
        )
            : null,
      ),
    );
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
                            Navigator.pop(context); // Go back when tapped
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
                      'Edit Event',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 36,
                        color: Color(0xFF801e15),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildImagePicker(), // Image picker widget
                    const SizedBox(height: 20),
                    // Event Name Input
                    _buildTextField(context, 'Event Name', _eventNameController),
                    const SizedBox(height: 20),
                    // Venue Dropdowns
                    _buildVenueDropdowns(),
                    const SizedBox(height: 20),
                    // Date Picker
                    _buildDatePicker(context),
                    const SizedBox(height: 20),
                    // Time Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimePicker(context, 'Start Time', _startTime, (newTime) {
                          setState(() {
                            _startTime = newTime;
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
                        _buildTimePicker(context, 'End Time', _endTime, (newTime) {
                          setState(() {
                            _endTime = newTime;
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Description Input
                    _buildTextField(context, 'Description', _descriptionController, isMultiline: true),
                    const SizedBox(height: 20),
                    // Tag Selection
                    _buildTagSelection(),
                    const SizedBox(height: 30),
                    // Save Button
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

  // Method to build text field
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

  // Method to build time picker
  Widget _buildTimePicker(BuildContext context, String label, TimeOfDay? time, ValueChanged<TimeOfDay> onTimeSelected) {
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
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
            );
            if (selectedTime != null) {
              onTimeSelected(selectedTime);
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
                  time != null ? time.format(context) : 'Select Time',
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

  // Method to build venue dropdowns
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

  // Method to build date picker
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
              initialDate: _eventDate ?? DateTime.now(),
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

  // Method to build tag selection
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
              backgroundColor: const Color(0xFFe8c9ab),
              checkmarkColor: const Color(0xFF801e15),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Save Event to Firestore
  void _saveEvent() async {
    if (_eventNameController.text.isEmpty ||
        _selectedVenues.isEmpty ||
        _descriptionController.text.isEmpty ||
        _startTime == null ||
        _endTime == null ||
        _eventDate == null) {
      // Show error if any field is empty
      showErrorDialog('Please fill in all fields');
      return;
    }

    // Upload image if a new one is selected
    if (_selectedImage != null) {
      await _uploadImage();
    }

    // Prepare updated event data
    Map<String, dynamic> updatedEvent = {
      'eventName': _eventNameController.text,
      'venues': _selectedVenues.whereType<String>().toList(),
      'startTime': _startTime?.format(context),
      'endTime': _endTime?.format(context),
      'eventDate': _eventDate,
      'description': _descriptionController.text,
      'tags': selectedTags,
      'imageUrl': _imageUrl, // Update with the new image URL
    };

    try {
      // Update event in Firestore using the eventDocId
      await FirebaseFirestore.instance.collection('events').doc(widget.eventDocId).update(updatedEvent);

      // Show success message
      showSuccessDialog('Event updated successfully!');
      // Pass the updated event data back to the OrganizerEventDetails page
      Navigator.pop(context, updatedEvent); // Pass updated event data
    } catch (e) {
      showErrorDialog('Failed to update event: $e');
    }
  }
}