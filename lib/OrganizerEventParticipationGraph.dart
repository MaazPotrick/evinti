import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class OrganizerEventParticipationGraph extends StatefulWidget {
  const OrganizerEventParticipationGraph({Key? key}) : super(key: key);

  @override
  _OrganizerEventParticipationGraphState createState() =>
      _OrganizerEventParticipationGraphState();
}

class _OrganizerEventParticipationGraphState
    extends State<OrganizerEventParticipationGraph> {
  List<String> eventNames = [];
  List<int> participantCounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventParticipationData();
  }

  Future<void> _fetchEventParticipationData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('createdBy', isEqualTo: currentUser.uid)
          .get();

      List<String> fetchedEventNames = [];
      List<int> fetchedParticipantCounts = [];

      for (var eventDoc in eventsSnapshot.docs) {
        final eventName = eventDoc['eventName'];
        final participantsSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .doc(eventDoc.id)
            .collection('participants')
            .get();

        fetchedEventNames.add(eventName);
        fetchedParticipantCounts.add(participantsSnapshot.size);
      }

      setState(() {
        eventNames = fetchedEventNames;
        participantCounts = fetchedParticipantCounts;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching event data: $e');
      setState(() {
        isLoading = false;
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
                  // Page Title
                  const Text(
                    'Event Participation Graph',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 28,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Graph or Loading Indicator
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : eventNames.isEmpty
                        ? const Center(
                      child: Text(
                        'No event data available',
                        style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 18,
                          color: Color(0xFF801e15),
                        ),
                      ),
                    )
                        : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        height: 400, // Reduced height
                        child: BarChart(
                          BarChartData(
                            barGroups: _buildBarGroups(),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: _buildLeftTitles,
                                  interval: 0.1,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: _buildBottomTitles,
                                  interval: 1,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                top: BorderSide.none,
                                right: BorderSide.none,
                                bottom: BorderSide(width: 1),
                                left: BorderSide(width: 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(eventNames.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: participantCounts[index].toDouble(),
            width: 16,
            color: const Color(0xFF801e15),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= eventNames.length) {
      return const SizedBox.shrink();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5.0,
      // Add a margin to push the labels further down
      child: Transform.translate(
        offset: const Offset(0, 40), // Adjust the value as needed to push the labels down
        child: Transform.rotate(
          angle: -1.5708, // Rotate label 90 degrees counterclockwise
          child: Text(
            eventNames[index],
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 12,
              color: Color(0xFF801e15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(
        value.toStringAsFixed(1), // Display numbers as 0.1, 0.2, etc.
        style: const TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 8,
          color: Color(0xFF801e15),
        ),
      ),
    );
  }
}