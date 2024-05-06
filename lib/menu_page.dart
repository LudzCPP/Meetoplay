import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/find_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/main_window_card.dart';
import 'package:meetoplay/map_page.dart';

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
            const Spacer(flex: 1),
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
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: GestureDetector(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff1a659e),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                            0.8),
                        spreadRadius: 0,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('Nadchodzące wydarzenie',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xffefefd0))), // white
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.event_note,
                                size: 60, color: Color(0xffff6b35)), // orange
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Piknik rodzinny',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: const Color(0xffefefd0)), // white
                                ),
                                const Text(
                                  '15 maja 2024',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xffefefd0), // white
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
