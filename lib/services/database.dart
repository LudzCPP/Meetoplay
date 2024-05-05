import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:latlong2/latlong.dart";
import "package:meetoplay/event_details_page.dart";

class DatabaseService{

  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference meetingsCollection = FirebaseFirestore.instance.collection('meetings');


Future updateMeeting(
  String name,
  LatLng location,
  String date,
  String time,
  String category,
  String skillLevel,
  int participantsCount,
  int registeredCount,
  int waitListCount,
  String organizerName,
  double organizerRating,
  List<Participant> participants,
) async {
  return await meetingsCollection.doc().set({
    'owner': uid,
    'name': name,
    'location': {
      'latitude': location.latitude,
      'longitude': location.longitude,
    },
    'date': date,
    'time': time,
    'category': category,
    'skillLevel': skillLevel,
    'participantsCount': participantsCount,
    'registeredCount': registeredCount,
    'waitListCount': waitListCount,
    'organizerName': organizerName,
    'organizerRating': organizerRating,
    'participants': {
      for ( var participant in participants){
        'participant': participant
      }
    }
  });
}
Stream<QuerySnapshot> get meetings {
  return meetingsCollection.snapshots();
}
}