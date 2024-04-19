import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MeetMarker extends Marker {
  MeetMarker({
    required LatLng location,
    required String tooltipMessage,
    required Color color,
    double size = 50.0,
  }) : super(
          point: location,
          child: Tooltip(
            message: tooltipMessage,
            child: Icon(
              Icons.location_on,
              color: color,
              size: size,
            ),
          ),
        );
}
