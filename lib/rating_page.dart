import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:meetoplay/global_variables.dart';

class RatingPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const RatingPage({super.key, required this.event});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final Map<String, double> ratings = {};

  @override
  Widget build(BuildContext context) {
    final participants = widget.event['participants'] as List<dynamic>? ?? [];
    final existingRatings = widget.event['ratings'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event['name']),
        backgroundColor: darkBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Oceń uczestników:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...participants.map<Widget>((participant) {
              final userId = participant['userId'];
              final alreadyRated = existingRatings.containsKey(userId);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    participant['name'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  trailing: alreadyRated
                      ? Text(
                          'Oceniono: ${existingRatings[userId]}',
                          style: const TextStyle(color: Colors.black54, fontSize: 16),
                        )
                      : RatingBar.builder(
                          initialRating: ratings[userId] ?? 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              ratings[userId] = rating;
                            });
                          },
                        ),
                ),
              );
            }),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _submitRatings();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: specialActionButtonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Zatwierdź oceny'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRatings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final history = List.from(userData['history'] ?? []);

      for (var event in history) {
        if (event['meetingId'] == widget.event['meetingId']) {
          final existingRatings = event['ratings'] as Map<String, dynamic>? ?? {};
          ratings.forEach((key, value) {
            existingRatings[key] = value;
          });
          event['ratings'] = existingRatings;
          break;
        }
      }

      await userDocRef.update({'history': history});
    }
  }
}
