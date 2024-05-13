import 'package:latlong2/latlong.dart';

class Meeting {
  String meetingId;
  String name;
  LatLng location;
  String date;
  String time;
  String category;
  String skillLevel;
  int participantsCount;
  int registeredCount;
  int waitListCount;
  String organizerName;
  double organizerRating;
  List<Participant> participants;
  String ownerId;

  Meeting({
    required this.meetingId,
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.category,
    required this.skillLevel,
    required this.participantsCount,
    required this.registeredCount,
    required this.waitListCount,
    required this.organizerName,
    required this.organizerRating,
    required this.participants,
    required this.ownerId,
  });

}

class Participant {
  String name;
  int rating;

  Participant({
    required this.name,
    required this.rating,
  });
}
