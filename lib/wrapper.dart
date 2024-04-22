import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetoplay/authenticate_page.dart';
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
                  if (e is FirebaseAuthException && e.code == 'user-not-found') {
                    await FirebaseAuth.instance.signOut();
                  }
                }
              }
            });

            // Fetch user-specific data from Firestore and update global markers
            return StreamBuilder<QuerySnapshot>(
              //stream: FirebaseFirestore.instance.collection('meetings').where('userId', isEqualTo: user.uid).snapshots(),
              stream: FirebaseFirestore.instance.collection('meetings').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  globalMarkers.clear(); // Clear existing markers before updating
                  for (var doc in snapshot.data!.docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    LatLng location = LatLng(data['location']['latitude'], data['location']['longitude']);
                    globalMeetings.add(Meeting(location: location, date: data['date'], eventName: data['eventName'], userId: data['userId']));
                    if(data['userId']==user.uid){ globalMarkers.add(MeetMarker(
                      location: location,
                      eventDescription: "Event at ${data['date']}",
                      color: Colors.red, // Example: dynamic color based on data
                      eventTitle: data['eventName'],
                    ));}
                    else{
                       globalMarkers.add(MeetMarker(
                      location: location,
                      eventDescription: "Event at ${data['date']}",
                      color: Colors.blue, // Example: dynamic color based on data
                      eventTitle: data['eventName'],
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
