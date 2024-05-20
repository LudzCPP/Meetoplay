import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetoplay/authenticate_page.dart';
import 'package:meetoplay/event_details_page.dart';
import 'package:meetoplay/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/main.dart'; // Ensure navigatorKey is defined here
import 'package:meetoplay/models/meetings.dart';
import 'global_variables.dart';
import 'meet_marker.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            return const AuthenticationScreen();
          } else {
            // Listen for token changes to manage user session
            FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
              if (user != null) {
                try {
                  await user.reload();
                } catch (e) {
                  if (e is FirebaseAuthException &&
                      e.code == 'user-not-found') {
                    await FirebaseAuth.instance.signOut();
                  }
                }
              }
            });

            // Fetch user-specific data from Firestore and update global markers
            return StreamBuilder<QuerySnapshot>(
              //stream: FirebaseFirestore.instance.collection('meetings').where('userId', isEqualTo: user.uid).snapshots(),
              stream:
                  FirebaseFirestore.instance.collection('meetings').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  globalMarkers.clear();
                  globalMeetings.clear();
                  print('restart');
                  for (var doc in snapshot.data!.docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    LatLng location = LatLng(data['location']['latitude'],
                        data['location']['longitude']);
                    List<Participant> participants = [];
                    for (var participant in data['participants']) {
                      // Sprawdź czy każde pole uczestnika istnieje i nie jest nullem
                      String name = participant['name'] ??
                          'Nieznany'; // Użyj domyślnej nazwy jeśli pole jest puste
                      double rating = participant['rating'].toDouble() ??
                          0; // Użyj domyślnej oceny jeśli pole jest puste

                      // Dodaj uczestnika do listy z wczytanymi i sprawdzonymi danymi
                      participants.add(Participant(name: name, rating: rating.toDouble(), userId: participant['userId']));
                    }

                    Meeting meeting = Meeting(
                        meetingId: data['meetingId'],
                        name: data['name'],
                        location: location,
                        date: data['date'],
                        time: data['time'],
                        category: data['category'],
                        skillLevel: data['skillLevel'],
                        participantsCount: data['participantsCount'],
                        registeredCount: data['registeredCount'],
                        waitListCount: data['waitListCount'],
                        organizerName: data['organizerName'],
                        organizerRating: data['organizerRating'],
                        participants: participants,
                        ownerId: data['ownerId']);
                    globalMeetings.add(meeting);
                    if (data['owner'] == user.uid) {
                      globalMarkers.add(MeetMarker(
                        location: location,
                        meeting: meeting,
                        color:
                            Colors.red, // Example: dynamic color based on data
                      ));
                    } else {
                      globalMarkers.add(MeetMarker(
                        location: location,
                        meeting: meeting,
                        color: Colors.blue,
                      ));
                    }
                  }
                  return const HomePage();
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text("Error fetching data: ${snapshot.error}"),
                    ),
                  );
                } else {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            );
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
