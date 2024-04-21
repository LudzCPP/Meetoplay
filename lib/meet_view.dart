import 'package:flutter/material.dart';
import 'package:meetoplay/global_variables.dart';

class MeetView extends StatelessWidget {
  final String eventTitle;
  final String? eventDescription;

  const MeetView({
    super.key,
    required this.eventTitle,
    required this.eventDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SPOTKANIE',
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [darkBlue, lightBlue],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Spotkanie'),
            Text(eventDescription!),
          ],
        ),
      ),
    );
  }
}
