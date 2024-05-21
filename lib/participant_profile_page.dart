import 'package:flutter/material.dart';
import 'package:meetoplay/event_details_page.dart';
import 'package:meetoplay/global_variables.dart';

class ParticipantProfilePage extends StatelessWidget {
  final Participant participant;

  const ParticipantProfilePage({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundImage: null,
                child: Icon(Icons.person, size: 50)
              ),
              const SizedBox(height: 20),
              Text(
                participant.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.person, color: darkBlue),
                title: const Text('User ID', style: TextStyle(color: Colors.black)),
                subtitle: Text(participant.userId, style: const TextStyle(color: white)),
              ),
              ListTile(
                leading: const Icon(Icons.star, color: darkBlue),
                title: const Text('Rating', style: TextStyle(color: Colors.black)),
                subtitle: Text(participant.rating.toString(), style: const TextStyle(color: white)),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 2),
              const Text(
                'Event History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              // Placeholder for event history
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'No event history available.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
