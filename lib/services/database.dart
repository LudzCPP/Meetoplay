import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:latlong2/latlong.dart";
import "package:meetoplay/event_details_page.dart";

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference meetingsCollection =
      FirebaseFirestore.instance.collection('meetings');

  Future createMeeting(
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
      String ownerId) async {
    try {
      DocumentReference meetingRef = meetingsCollection.doc();
      await meetingRef.set({
        'meetingId': meetingRef.id,
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
          for (var participant in participants)
            {'participant': participant.userId}
        },
        'ownerId': ownerId
      });
    } catch (e) {
      print('Błąd podczas dodawania spotkania: $e');
    }
  }

  Future updateMeeting(
      String meetingId,
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
      String ownerId) async {
    try {
      DocumentReference meetingRef = meetingsCollection.doc(meetingId);
      await meetingRef.update({
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
          for (var participant in participants) {'participant': participant}
        },
        'ownerId': ownerId
      });
    } catch (e) {
      print('Błąd podczas dodawania spotkania: $e');
    }
  }

  Stream<QuerySnapshot> get meetings {
    return meetingsCollection.snapshots();
  }

  Future updateUser(
    String name,
    int rating,
    int ratingsCount,
  ) async {
    return await usersCollection.doc().set(
      {
        'userId': uid,
        'name': name,
        'rating': rating,
        'ratingsCount': ratingsCount,
      },
    );
  }

  Stream<QuerySnapshot> get users {
    return usersCollection.snapshots();
  }

  static Future saveUserToken(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> data = {
      "email": user!.email,
      "token": token,
    };
    try {
      await FirebaseFirestore.instance
          .collection("user_data")
          .doc(user.uid)
          .set(data);

      print("Document Added to ${user.uid}");
    } catch (e) {
      print("error in saving to firestore");
      print(e.toString());
    }
  }

  Future<void> addMeetingParticipant(
      String meetingId, Participant newParticipant) async {
    DocumentReference meetingRef = meetingsCollection.doc(meetingId);
    try {
      await meetingRef.update({
        'participants': FieldValue.arrayUnion([
          {
            'name': newParticipant.name,
            'rating': newParticipant.rating,
            'userId': newParticipant.userId
          }
        ]),
      });
    } catch (e) {
      print('Błąd podczas dodawania uczestnika: $e');
    }
  }

  Future<void> removeMeetingParticipant(String meetingId, Participant participant) async {
  DocumentReference meetingRef = meetingsCollection.doc(meetingId);
  try {
    await meetingRef.update({
      'participants': FieldValue.arrayRemove([
        {
          'name': participant.name,
          'rating': participant.rating,
          'userId': participant.userId
        }
      ]),
    });
  } catch (e) {
    print('Błąd podczas usuwania uczestnika: $e');
  }
}


  Future<bool> isUserParticipant(String meetingId, String userId) async {
    try {
      // Pobierz dokument wydarzenia
      DocumentSnapshot meetingDoc =
          await meetingsCollection.doc(meetingId).get();

      // Sprawdź czy dokument istnieje i czy zawiera listę uczestników
      if (meetingDoc.exists) {
        // Pobierz listę uczestników z dokumentu
        List<dynamic> participants = meetingDoc['participants'];

        // Sprawdź czy użytkownik znajduje się na liście uczestników
        for (var participant in participants) {
          if (participant['userId'] == userId) {
            // Zwróć true jeśli użytkownik jest uczestnikiem wydarzenia
            return true;
          }
        }
      }
    } catch (e) {
      print('Błąd podczas sprawdzania uczestnictwa użytkownika: $e');
    }

    // Zwróć false jeśli użytkownik nie jest uczestnikiem wydarzenia lub wystąpił błąd
    return false;
  }
}
