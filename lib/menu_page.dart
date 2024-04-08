import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meetoplay/find_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/main_window_card.dart';
import 'package:meetoplay/map_page.dart';
import 'package:meetoplay/settings_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const MapPage();
                      },
                    ),
                  );
                },
                child: const MainWindowCard(
                  cardText: 'MAPA WYDARZEŃ',
                  cardHeight: 250,
                  cardIcon: Icon(
                    Icons.map_outlined,
                    size: 213,
                    color: white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap:() {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const FindMeetPage();
                      },
                    ),
                  );
                },
                child: const MainWindowCard(
                  cardText: 'WYSZUKAJ SPOTKANIE',
                  cardHeight: 110,
                  cardIcon: Icon(
                    Icons.search,
                    size: 73,
                    color: white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // MainWindowCard(
              //   cardText: 'EDYTUJ PROFIL',
              //   cardHeight: 100,
              //   cardIcon: Icon(
              //     Icons.edit,
              //     size: 63,
              //     color: white,
              //   ),
              // ),
              // SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const SettingsPage();
                      },
                    ),
                  );
                },
                child: const MainWindowCard(
                  cardText: 'OPCJE',
                  cardHeight: 110,
                  cardIcon: Icon(
                    Icons.settings,
                    size: 73,
                    color: white,
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
