import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/event_details_page.dart';
import 'package:meetoplay/find_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/main_window_card.dart';
import 'package:meetoplay/map_page.dart';
import 'package:intl/intl.dart';
import 'package:meetoplay/models/meetings.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  Meeting? findNearestMeeting(List<Meeting> meetings) {
    if (meetings.isEmpty) return null;

    DateTime now = DateTime.now();
    Meeting? nearestMeeting;
    Duration? nearestDuration;
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    for (Meeting meeting in meetings) {
      bool isParticipant = meeting.participants
          .any((participant) => participant.userId == currentUserId);
      if (!isParticipant) continue;

      String dateTimeString = '${meeting.date}/${meeting.time}';
      List<String> dateTimeParts = dateTimeString.split('/');
      String formattedDate =
          '${dateTimeParts[2]}-${dateTimeParts[1].padLeft(2, '0')}-${dateTimeParts[0].padLeft(2, '0')}';
      String formattedTime = dateTimeParts[3].padLeft(5, '0');
      String formattedDateTimeString = '$formattedDate $formattedTime';

      DateTime meetingDateTime =
          DateTime.tryParse(formattedDateTimeString) ?? DateTime.now();

      if (meetingDateTime.isAfter(now)) {
        Duration difference = meetingDateTime.difference(now);
        if (nearestDuration == null || difference < nearestDuration) {
          nearestDuration = difference;
          nearestMeeting = meeting;
        }
      }
    }

    return nearestMeeting;
  }

  @override
  Widget build(BuildContext context) {
    Meeting? nearestMeeting = findNearestMeeting(globalMeetings);

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
            if (nearestMeeting != null)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xff1a659e),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
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
                                ?.copyWith(color: const Color(0xffefefd0))),
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.event_note,
                                  size: 60, color: Color(0xffff6b35)),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    nearestMeeting.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: const Color(0xffefefd0)),
                                  ),
                                  Text(
                                    '${nearestMeeting.date} ${nearestMeeting.time}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xffefefd0),
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EventDetailsPage(meeting: nearestMeeting),
                      ),
                    );
                  },
                ),
              ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
