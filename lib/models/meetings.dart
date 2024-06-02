import 'package:latlong2/latlong.dart';
import 'package:meetoplay/event_details_page.dart';

class Meeting {
  String meetingId;
  String name;
  LatLng location;
  String date;
  String time;
  String category;
  String skillLevel;
  int maxParticipants;
  int waitListCount;
  String organizerName;
  double organizerRating;
  List<Participant> participants;
  String ownerId;
  String status; // Dodaj to pole

  Meeting({
    required this.meetingId,
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.category,
    required this.skillLevel,
    required this.maxParticipants,
    required this.waitListCount,
    required this.organizerName,
    required this.organizerRating,
    required this.participants,
    required this.ownerId,
    this.status = 'ongoing', // Domyślnie status to 'ongoing'
  });

  // Pamiętaj o zaktualizowaniu serializacji/deserializacji
}

