import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerEventEdit extends StatefulWidget {
  final Map<String, dynamic> event; // Event data passed from the previous page
  final String eventDocId;           // Event document ID from Firestore

  const OrganizerEventEdit({Key? key, required this.event, required this.eventDocId}) : super(key: key);

  @override
  _OrganizerEventEditState createState() => _OrganizerEventEditState();
}

class _OrganizerEventEditState extends State<OrganizerEventEdit> {
  late TextEditingController _eventNameController;
  late TextEditingController _venueController;
  late TextEditingController _descriptionController;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current event data
    _eventNameController = TextEditingController(text: widget.event['eventName']);
    _venueController = TextEditingController(text: widget.event['venue']);
    _descriptionController = TextEditingController(text: widget.event['description']);
    _startTime = _parseTime(widget.event['startTime']);
    _endTime = _parseTime(widget.event['endTime']);
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
                    // Event Name Input
                    _buildTextField(context, 'Event Name', _eventNameController),
                    const SizedBox(height: 20),
                    // Venue Input
                    _buildTextField(context, 'Venue', _venueController),
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
                        'save',
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

  // Save Event to Firestore
  void _saveEvent() async {
    if (_eventNameController.text.isEmpty ||
        _venueController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _startTime == null ||
        _endTime == null) {
      // Show error if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields'),
      ));
      return;
    }

    // Prepare updated event data
    Map<String, dynamic> updatedEvent = {
      'eventName': _eventNameController.text,
      'venue': _venueController.text,
      'startTime': _startTime?.format(context),
      'endTime': _endTime?.format(context),
      'description': _descriptionController.text,
    };

    try {
      // Update event in Firestore using the eventDocId
      await FirebaseFirestore.instance.collection('events').doc(widget.eventDocId).update(updatedEvent);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Event updated successfully!'),
      ));

      // Pass the updated event data back to the OrganizerEventDetails page
      Navigator.pop(context, updatedEvent); // Pass updated event data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update event: $e'),
      ));
    }
  }
}