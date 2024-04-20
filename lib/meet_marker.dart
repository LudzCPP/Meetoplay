import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/main.dart';

class MeetMarker extends Marker {
  MeetMarker({
    required LatLng location,
    required String tooltipMessage,
    required Color color,
    required String eventTitle,
    double size = 50.0,
  }) : super(
          point: location,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: navigatorKey.currentContext!,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(eventTitle),
                    content: Text(tooltipMessage),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Check'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(
              Icons.location_on,
              color: color,
              size: size,
            ),
          ),
        );
}