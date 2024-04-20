import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/main.dart';
import 'package:meetoplay/meet_view.dart';

class MeetMarker extends Marker {
  MeetMarker({
    required LatLng location,
    required String tooltipMessage,
    required Color color,
    required String eventTitle,
    double size = 50.0,
  }) : super(
          width: 50,
          height: 97,
          point: location,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: GestureDetector(
              onTap: () {
                print(eventTitle);
                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(eventTitle),
                      content: Text(tooltipMessage),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return const MeetView();
                                },
                              ),
                            );
                          },
                          child: const Text('Sprawdz'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 53),
                  child: Icon(
                    Icons.location_on,
                    color: color,
                    size: size,
                  ),
                ),
              ),
            ),
          ),
        );
}
