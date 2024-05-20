import 'package:flutter/material.dart';
import 'package:meetoplay/event_details_page.dart';
import 'package:meetoplay/models/meetings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingPage extends StatefulWidget {
  final Meeting meeting;

  const RatingPage({super.key, required this.meeting});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  Map<String, double> ratings = {};
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    initializeRatings();
  }

  void initializeRatings() {
    for (var participant in widget.meeting.participants) {
      ratings[participant.userId] = 0.0;
    }
  }

  void submitRatings() {
    // Tutaj możesz dodać logikę do zapisania ocen w bazie danych
    Navigator.of(context).pop();
    print('Submitted ratings: $ratings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Oceń uczestników"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: widget.meeting.participants.length,
        itemBuilder: (context, index) {
          Participant participant = widget.meeting.participants[index];
          if (participant.userId == currentUser?.uid) {
            return Container(); // Nie wyświetlaj oceny dla samego siebie
          }
          return ListTile(
            title: Text(participant.name),
            trailing: RatingBar.builder(
              initialRating: ratings[participant.userId] ?? 0.0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 30.0,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  ratings[participant.userId] = rating;
                });
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: submitRatings,
          child: const Text('Zatwierdź oceny'),
        ),
      ),
    );
  }
}
