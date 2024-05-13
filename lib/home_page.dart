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

  Future<void> _refreshPage() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Symulacja opóźnienia przy odświeżaniu
    setState(() {
      // Tutaj możesz wywołać dodatkowe funkcje do załadowania danych lub zresetować stan strony
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MEETOPLAY',
        ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
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
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.home, size: 40),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, size: 40),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}
