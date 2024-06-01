import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetoplay/calendar_page.dart';
import 'package:meetoplay/create_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/menu_page.dart';
import 'package:meetoplay/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPage = 0;

  final pageOptions = [const MenuPage(), const CalendarPage()];

  Future<String> getCurrentUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    return userDoc['role'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Błąd: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(
              child: Text('Nie można pobrać roli użytkownika.'));
        } else {
          String userRole = snapshot.data!;
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
            body: pageOptions[selectedPage],
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
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
      },
    );
  }
}
