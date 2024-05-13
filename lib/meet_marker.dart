import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
                  return AlertDialog(
                    title: Text(meeting.name),
                    content: Text(meeting.location.toString()),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventDetailsPage(meeting: meeting),
                            ),
                          );
                        },
                        child: const Text('Sprawdź'),
                      ),
                    ],
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
