import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/find_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/main_window_card.dart';
import 'package:meetoplay/map_page.dart';
import 'package:meetoplay/settings_page.dart';


class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
              child: MainWindowCard(
                cardText: 'MAPA WYDARZEŃ',
                cardHeight: 250,
                cardIcon: SizedBox(
                  width: double.infinity,
                  height: 213,
                  child: AbsorbPointer(
                    child: FlutterMap(
                      options: const MapOptions(
                        interactionOptions: InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                        initialCenter: LatLng(51.747224, 19.453870),
                        initialZoom: 16.2,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
            GestureDetector(
              onTap: () {
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
            const Spacer(flex: 1),
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
            const Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}
