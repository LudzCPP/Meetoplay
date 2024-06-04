import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/calendar_page.dart';
import 'package:meetoplay/create_meet_page.dart';
import 'package:meetoplay/event_details_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/meet_marker.dart';
import 'package:meetoplay/menu_page.dart';
import 'package:meetoplay/models/meetings.dart';
import 'package:meetoplay/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPage = 0;
  String userRole = '';
  bool isLoading = true;

  final pageOptions = [const MenuPage(), const CalendarPage()];

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndMeetings();
  }

  Future<void> _loadUserRoleAndMeetings() async {
    await _getUserRole();
    await _loadMeetings();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role'];
        });
      } else {
        setState(() {
          userRole = 'Guest';
        });
      }
    } else {
      setState(() {
        userRole = 'Guest';
      });
    }
  }

  Future<void> _loadMeetings() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('meetings').get();

    globalMarkers.clear();
    globalMeetings.clear();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      LatLng location = LatLng(
        data['location']['latitude'],
        data['location']['longitude'],
      );

      List<Participant> participants = [];
      for (var participant in data['participants']) {
        String name = participant['name'] ?? 'Nieznany';
        double rating = (participant['rating']?.toDouble() ?? 0);

        participants.add(Participant(
          name: name,
          rating: rating,
          userId: participant['userId'],
        ));
      }

      Meeting meeting = Meeting(
        meetingId: data['meetingId'],
        name: data['name'],
        location: location,
        date: data['date'],
        time: data['time'],
        category: data['category'],
        skillLevel: data['skillLevel'],
        maxParticipants: data['maxParticipants'],
        waitListCount: data['waitListCount'],
        organizerName: data['organizerName'],
        organizerRating: data['organizerRating'],
        participants: participants,
        ownerId: data['ownerId'],
      );

      globalMeetings.add(meeting);

      if (data['ownerId'] == FirebaseAuth.instance.currentUser!.uid) {
        globalMarkers.add(MeetMarker(
          location: location,
          meeting: meeting,
          color: Colors.red,
        ));
      } else {
        globalMarkers.add(MeetMarker(
          location: location,
          meeting: meeting,
          color: Colors.blue,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            backgroundColor: lightBlue,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    bool isGuest = userRole == 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetoplay'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const ProfilePage();
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.person,
              size: 40,
            ),
          ),
        ],
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(selectedPage),
          index: selectedPage,
          children: pageOptions,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isGuest
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreateMeetPage();
                    },
                  ),
                );
              },
              shape: const CircleBorder(),
              backgroundColor: pink,
              elevation: 4.0,
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: isGuest
          ? null
          : BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: darkBlue,
              selectedItemColor: white,
              unselectedItemColor: white.withOpacity(0.5),
              currentIndex: selectedPage,
              onTap: (index) {
                setState(() {
                  selectedPage = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 45),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event, size: 45),
                  label: '',
                ),
              ],
            ),
    );
  }
}
