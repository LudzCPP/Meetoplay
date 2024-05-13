import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetoplay/edit_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meetoplay/services/database.dart';
import 'models/meetings.dart';
import 'models/message_module.dart';

class EventDetailsPage extends StatefulWidget {
  final Meeting meeting;

  const EventDetailsPage({super.key, required this.meeting});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool joined = false;
  List<Participant> participants = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUserJoinStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting.name, style: const TextStyle(color: white)),
        backgroundColor: darkBlue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildMeetingDetails(),
            ),
            buildParticipantsList(),
            buildEditButton(),
            buildJoinButton(),
            buildChatSection(widget.meeting.meetingId),
          ],
        ),
      ),
    );
  }

  void checkUserJoinStatus() async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      bool isParticipant = await DatabaseService(uid: currentUser.uid)
          .isUserParticipant(widget.meeting.meetingId, currentUser.uid);
      // Aktualizujemy stan dołączenia na podstawie wyniku
      setState(() {
        joined = isParticipant;
      });
    }
  } catch (e) {
    print("Error checking user join status: $e");
  }
}

  Widget buildChatSection(String meetingId) {
  return Container(
    constraints: const BoxConstraints(maxHeight: 390),
    padding: const EdgeInsets.all(4.0),
    child: GroupChatPage(meetingId: meetingId), // Przekazujesz meetingId do widgetu czatu
  );
}


  Widget buildMeetingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDetailRow(Icons.sports_soccer, 'Sport: ${widget.meeting.category}'),
        buildDetailRow(Icons.bar_chart, 'Poziom: ${widget.meeting.skillLevel}'),
        buildLocation(),
        buildDetailRow(Icons.calendar_today, 'Data: ${widget.meeting.date} ${widget.meeting.time}'),
        Text('Maksymalna liczba uczestników: ${widget.meeting.participantsCount}',
            style: const TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildParticipantsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('meetings').doc(widget.meeting.meetingId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          participants = List<Participant>.from(
            (data['participants'] as List).map((item) => Participant(
              name: item['name'],
              rating: item['rating'],
              userId: item['userId']
            ))
          );
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.person, color: white),
                title: Text(participants[index].name, style: const TextStyle(color: white, fontWeight: FontWeight.bold)),
                subtitle: Text('Ocena: ${participants[index].rating}', style: const TextStyle(color: white)),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: white),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildLocation() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.white),
        const SizedBox(width: 8),
        FutureBuilder<String>(
          future: getAddressFromLatLng(widget.meeting.location.latitude, widget.meeting.location.longitude),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Flexible(child: Text('Miejsce: ${snapshot.data}', style: const TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)));
            } else if (snapshot.hasError) {
              return Flexible(child: Text("Błąd: ${snapshot.error}", style: const TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)));
            }
            return const CircularProgressIndicator();
          },
        ),
      ],
    );
  }

  Widget buildEditButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditMeetPage(meeting: widget.meeting),
            ),
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(orange),
          foregroundColor: MaterialStateProperty.all(white),
        ),
        child: const Text('Edytuj spotkanie'),
      ),
    );
  }

  Widget buildJoinButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      child: ElevatedButton(
        onPressed: () {
          if (!joined) {
            showJoinDialog();
          }
          print(joined);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (joined) {
                return Colors.green;
              }
              return orange;
            },
          ),
          foregroundColor: MaterialStateProperty.all(white),
        ),
        child: Icon(joined ? Icons.check : Icons.add, color: white),
      ),
    );
  }

  void showJoinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Potwierdzenie"),
          content: const Text("Czy na pewno chcesz dołączyć do tego wydarzenia?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Anuluj"),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij okno dialogowe
              },
            ),
            TextButton(
              child: const Text("Dołącz"),
              onPressed: () async {
                try {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    Participant newParticipant = Participant(
                      name: currentUser.displayName ?? "Anonim",
                      rating: 0, // Domniemana wartość, aktualizuj według potrzeb
                      userId: currentUser.uid,
                    );

                    // Dodajemy do listy lokalnej
                    setState(() {
                      participants.add(newParticipant);
                      joined = true; // Zaktualizuj stan dołączenia
                      print("Uczestnicy po dodaniu: ${participants.length}");
                    });

                    // Aktualizacja Firestore
                    await DatabaseService(uid: currentUser.uid).updateMeetingParticipants(
                      widget.meeting.meetingId,
                      participants,
                    );
                  }
                  Navigator.of(context).pop(); // Zamknij okno dialogowe
                } catch (e) {
                  print("Error joining meeting: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        print("${place.street}, ${place.locality}, ${place.postalCode}, ${place.country},  ${place.administrativeArea},  ${place.name}");
        return "${place.locality}, ${place.street}";
      }
      return "Nie można znaleźć adresu";
    } catch (e) {
      return "Błąd: $e";
    }
  }
}


class Participant {
  String name;
  int rating;
  String userId;

  Participant({required this.name, required this.rating, required this.userId});
}
