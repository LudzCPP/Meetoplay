import 'package:flutter/material.dart';
import 'package:meetoplay/global_variables.dart';

import 'models/meetings.dart';

class EventDetailsPage extends StatelessWidget {
  final Meeting meeting;

  EventDetailsPage({Key? key, required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meeting.name, style: TextStyle(color: white)),
        backgroundColor: darkBlue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sports_soccer, color: white),
                      SizedBox(width: 8),
                      Text('Sport: ${meeting.category}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: white),
                      SizedBox(width: 8),
                      Text('Poziom: ${meeting.skillLevel}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Existing Widgets
                  Row(
                    children: [
                      Icon(Icons.location_on, color: white),
                      SizedBox(width: 8),
                      Text('Miejsce: ${meeting.location}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: white),
                      SizedBox(width: 8),
                      Text('Data: ${meeting.date}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.access_time, color: white),
                      SizedBox(width: 8),
                      Text('${meeting.time}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Continue with existing widgets
                  Text('Maksymalna liczba uczestników: ${meeting.participantsCount}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                  // More Widgets as per existing code
                ],
              ),
            ),
            // Additional Widgets as per existing code
          ],
        ),
      ),
    );
  }
}

class Participant {
  String name;
  int rating;
  String userId; // User ID is included but not displayed

  Participant({required this.name, required this.rating, required this.userId});
}
