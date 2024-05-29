import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/main.dart';
import 'package:meetoplay/event_details_page.dart';
import 'package:meetoplay/models/meetings.dart';

class MeetMarker extends Marker {
  final Meeting meeting;

  MeetMarker({
    required LatLng location,
    required this.meeting,
    required Color color,
    double size = 50.0,
  }) : super(
          width: 50,
          height: 50,
          point: location,
          alignment: const Alignment(0, -0.9),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: navigatorKey.currentContext!,
                builder: (BuildContext context) {
                  int occupiedSpots = meeting.participants.length;
                  return AlertDialog(
                    backgroundColor: darkBlue,
                    title: Text(
                      meeting.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    content: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Data: ${meeting.date}\n',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Czas: ${meeting.time}\n',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Sport: ${meeting.category}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text:
                                  'Liczba zajętych miejsc: $occupiedSpots / ${meeting.maxParticipants}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailsPage(meeting: meeting),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: specialActionButtonColor,
                        ),
                        child: const Text('Sprawdź'),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  );
                },
              );
            },
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.location_on,
                color: color,
                size: size,
              ),
            ),
          ),
        );
}
