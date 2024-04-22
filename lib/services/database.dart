import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:latlong2/latlong.dart";

class DatabaseService{

  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference meetingsCollection = FirebaseFirestore.instance.collection('meetings');


Future updateMeeting(String eventName, double latitude, double longitude, String date) async {
  return await meetingsCollection.doc().set({
    'userId': uid,
    'eventName': eventName,
    'location': {
      'latitude': latitude,
      'longitude': longitude,
    },
    'date': date,
  });
}
Stream<QuerySnapshot> get meetings {
  return meetingsCollection.snapshots();
}
}