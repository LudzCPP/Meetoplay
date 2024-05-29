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
      int maxParticipants,
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
        'maxParticipants': maxParticipants,
        'registeredCount': registeredCount,
        'waitListCount': waitListCount,
        'organizerName': organizerName,
        'organizerRating': organizerRating,
        'participants': participants.map((p) => {
          'name': p.name,
          'rating': p.rating,
          'userId': p.userId,
        }).toList(),
        'waitingList': [],
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
      int maxParticipants,
      int registeredCount,
      int waitListCount,
      String organizerName,
      double organizerRating,
      List<Participant> participants,
      List<Participant> waitingList,
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
        'maxParticipants': maxParticipants,
        'registeredCount': registeredCount,
        'waitListCount': waitListCount,
        'organizerName': organizerName,
        'organizerRating': organizerRating,
        'participants': participants.map((p) => {
          'name': p.name,
          'rating': p.rating,
          'userId': p.userId,
        }).toList(),
        'waitingList': waitingList.map((p) => {
          'name': p.name,
          'rating': p.rating,
          'userId': p.userId,
        }).toList(),
        'ownerId': ownerId
      });
    } catch (e) {
      print('Błąd podczas aktualizacji spotkania: $e');
    }
  }

  Future<void> addMeetingParticipant(String meetingId, Participant newParticipant) async {
    DocumentReference meetingRef = meetingsCollection.doc(meetingId);
    DocumentSnapshot meetingDoc = await meetingRef.get();
    var data = meetingDoc.data() as Map<String, dynamic>;
    List participants = data['participants'];

    if (participants.length < data['maxParticipants']) {
      await meetingRef.update({
        'participants': FieldValue.arrayUnion([{
          'name': newParticipant.name,
          'rating': newParticipant.rating,
          'userId': newParticipant.userId,
        }]),
      });
    } else {
      await addWaitingListParticipant(meetingId, newParticipant);
    }
  }

  Future<void> addWaitingListParticipant(String meetingId, Participant newParticipant) async {
    DocumentReference meetingRef = meetingsCollection.doc(meetingId);
    await meetingRef.update({
      'waitingList': FieldValue.arrayUnion([{
        'name': newParticipant.name,
        'rating': newParticipant.rating,
        'userId': newParticipant.userId,
      }]),
    });
  }

  Future<void> removeMeetingParticipant(String meetingId, Participant participant) async {
    DocumentReference meetingRef = meetingsCollection.doc(meetingId);
    await meetingRef.update({
      'participants': FieldValue.arrayRemove([{
        'name': participant.name,
        'rating': participant.rating,
        'userId': participant.userId,
      }]),
    });
    await moveParticipantFromWaitingListToParticipants(meetingId);
  }

  Future<void> moveParticipantFromWaitingListToParticipants(String meetingId) async {
    DocumentReference meetingRef = meetingsCollection.doc(meetingId);
    DocumentSnapshot meetingDoc = await meetingRef.get();
    var data = meetingDoc.data() as Map<String, dynamic>;
    List participants = data['participants'];
    List waitingList = data['waitingList'];

    if (participants.length < data['maxParticipants'] && waitingList.isNotEmpty) {
      var nextParticipant = waitingList.removeAt(0);
      await meetingRef.update({
        'participants': FieldValue.arrayUnion([nextParticipant]),
        'waitingList': waitingList,
      });
    }
  }

  Future<bool> isUserParticipant(String meetingId, String userId) async {
    try {
      DocumentSnapshot meetingDoc = await meetingsCollection.doc(meetingId).get();

      if (meetingDoc.exists) {
        List<dynamic> participants = meetingDoc['participants'];
        for (var participant in participants) {
          if (participant['userId'] == userId) {
            return true;
          }
        }
      }
    } catch (e) {
      print('Błąd podczas sprawdzania uczestnictwa użytkownika: $e');
    }

    return false;
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
  
  Future<bool> isUserInWaitingList(String meetingId, String userId) async {
    try {
      DocumentSnapshot meetingDoc = await meetingsCollection.doc(meetingId).get();

      if (meetingDoc.exists) {
        List<dynamic> waitingList = meetingDoc['waitingList'];
        for (var participant in waitingList) {
          if (participant['userId'] == userId) {
            return true;
          }
        }
      }
    } catch (e) {
      print('Błąd podczas sprawdzania obecności użytkownika na liście oczekujących: $e');
    }

    return false;
  }
}
