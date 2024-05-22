import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetoplay/edit_meet_page.dart';
import 'package:meetoplay/event_bus.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meetoplay/main.dart';
import 'package:meetoplay/participant_profile_page.dart';
import 'package:meetoplay/rating_page.dart';
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
  bool isEnded = false;

  void updateParticipantsList() async {
    DocumentSnapshot meetingDoc = await FirebaseFirestore.instance
        .collection('meetings')
        .doc(widget.meeting.meetingId)
        .get();
    var data = meetingDoc.data() as Map<String, dynamic>;
    List<Participant> updatedParticipants = List<Participant>.from(
        (data['participants'] as List).map((item) => Participant(
            name: item['name'],
            rating: item['rating'].toDouble(),
            userId: item['userId'])));
    setState(() {
      participants = updatedParticipants;
      isEnded = data['status'] == 'ended';
    });

    // Jeśli wydarzenie jest zakończone, przekieruj na stronę oceniania
    if (isEnded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RatingPage(meeting: widget.meeting),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkUserJoinStatus();
    updateParticipantsList();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting.name, style: const TextStyle(color: white)),
        backgroundColor: darkBlue,
      ),
      body: isEnded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: buildMeetingDetails(),
                  ),
                  buildParticipantsList(),
                  if (currentUser?.uid == widget.meeting.ownerId)
                    buildEndEventButton(),
                  buildEditButton(),
                  buildJoinButton(),
                  buildChatSection(widget.meeting.meetingId),
                ],
              ),
            ),
    );
  }

  Widget buildEndEventButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      child: ElevatedButton(
        onPressed: () => endEvent(),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red),
          foregroundColor: MaterialStateProperty.all(white),
        ),
        child: const Text('Zakończ wydarzenie'),
      ),
    );
  }

  void endEvent() async {
    // Aktualizacja stanu wydarzenia w bazie danych na zakończone
    await FirebaseFirestore.instance
        .collection('meetings')
        .doc(widget.meeting.meetingId)
        .update({'status': 'ended'});

    setState(() {
      isEnded = true;
    });

    // Przekierowanie do strony oceny uczestników
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RatingPage(meeting: widget.meeting),
      ),
    );
  }

  void checkUserJoinStatus() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        bool isParticipant = await DatabaseService(uid: currentUser.uid)
            .isUserParticipant(widget.meeting.meetingId, currentUser.uid);
        setState(() {
          joined = isParticipant;
          if (isParticipant) {
            Participant currentParticipant = participants.firstWhere(
                (p) => p.userId == currentUser.uid,
                orElse: () => Participant(
                    name: 'Anonim', rating: 0, userId: currentUser.uid));
            if (!participants.contains(currentParticipant)) {
              participants.add(currentParticipant);
            }
          }
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
      child: GroupChatPage(
          meetingId: meetingId), // Przekazujesz meetingId do widgetu czatu
    );
  }

  Widget buildMeetingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDetailRow(
            Icons.sports_soccer, 'Sport: ${widget.meeting.category}'),
        const SizedBox(
          height: 10,
        ),
        buildDetailRow(Icons.bar_chart, 'Poziom: ${widget.meeting.skillLevel}'),
        const SizedBox(
          height: 10,
        ),
        buildLocation(),
        const SizedBox(
          height: 10,
        ),
        buildDetailRow(Icons.calendar_today,
            'Data: ${widget.meeting.date} ${widget.meeting.time}'),
        const SizedBox(
          height: 10,
        ),
        buildDetailRow(Icons.person_3_rounded,
            'Maksymalna liczba uczestników: ${widget.meeting.participantsCount}'),
      ],
    );
  }

  Widget buildParticipantsList() {
    return SizedBox(
      height: 200, // Ustawiamy maksymalną wysokość kontenera
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meetings')
            .doc(widget.meeting.meetingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            List<Participant> participants = List<Participant>.from(
                (data['participants'] as List).map((item) => Participant(
                    name: item['name'],
                    rating: item['rating'].toDouble(),
                    userId: item['userId'])));
            return ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.white),
                  title: Text(participants[index].name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Ocena: ${participants[index].rating}',
                      style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParticipantProfilePage(
                            participant: participants[index]),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: white),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 18, color: white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildLocation() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.white),
        const SizedBox(width: 8),
        FutureBuilder<String>(
          future: getAddressFromLatLng(widget.meeting.location.latitude,
              widget.meeting.location.longitude),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Flexible(
                  child: Text('Miejsce: ${snapshot.data}',
                      style: const TextStyle(
                          fontSize: 18,
                          color: white,
                          fontWeight: FontWeight.bold)));
            } else if (snapshot.hasError) {
              return Flexible(
                  child: Text("Błąd: ${snapshot.error}",
                      style: const TextStyle(
                          fontSize: 18,
                          color: white,
                          fontWeight: FontWeight.bold)));
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
          if (joined) {
            showLeaveDialog(); // Pokaż dialog potwierdzający opuszczenie wydarzenia
          } else {
            showJoinDialog(); // Pokaż dialog potwierdzający dołączenie do wydarzenia
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (joined) {
                return Colors
                    .red; // Zmiana koloru przycisku na czerwony, jeśli użytkownik jest uczestnikiem
              }
              return orange;
            },
          ),
          foregroundColor: MaterialStateProperty.all(white),
        ),
        child: Icon(joined ? Icons.remove : Icons.add,
            color:
                white), // Zmiana ikony przycisku na "Usuń", jeśli użytkownik jest uczestnikiem
      ),
    );
  }

  void showLeaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkBlue,
          title: const Text(
            "Czy na pewno chcesz opuścić to wydarzenie?",
            style: TextStyle(color: white),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: darkBlue,
                backgroundColor: pink,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Anuluj"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: darkBlue,
                backgroundColor: orange,
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Zamknij dialog potwierdzenia

                // Pokaż ekran ładowania
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const LoadingScreen();
                  },
                );

                try {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    Participant currentParticipant = participants.firstWhere(
                        (p) => p.userId == currentUser.uid,
                        orElse: () => Participant(
                            name: 'Anonim',
                            rating: 0,
                            userId: currentUser.uid));
                    await DatabaseService(uid: currentUser.uid)
                        .removeMeetingParticipant(
                            widget.meeting.meetingId, currentParticipant);
                    updateParticipantsList(); // Ponownie załaduj uczestników
                    eventBus.fire(
                        ParticipantChangedEvent()); // Wyślij powiadomienie
                    setState(() => joined = false);
                  }
                } catch (e) {
                  print("Error leaving meeting: $e");
                }

                if (mounted) {
                  navigatorKey.currentState?.pop(); // Zamknij ekran ładowania
                  navigatorKey.currentState?.pop(); // Zamknij EventDetailsPage
                  navigatorKey.currentState?.pop();
                }
              },
              child: const Text("Opuść"),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: white, width: 2),
          ),
        );
      },
    );
  }

  void showJoinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkBlue,
          title: const Text(
            "Czy na pewno chcesz dołączyć do tego wydarzenia?",
            style: TextStyle(color: white),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: darkBlue,
                backgroundColor: pink,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Anuluj"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: darkBlue,
                backgroundColor: orange,
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Zamknij dialog potwierdzenia

                // Pokaż ekran ładowania
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const LoadingScreen();
                  },
                );

                try {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    Participant newParticipant = Participant(
                      name: currentUser.displayName ?? "Anonim",
                      rating: 0,
                      userId: currentUser.uid,
                    );
                    await DatabaseService(uid: currentUser.uid)
                        .addMeetingParticipant(
                            widget.meeting.meetingId, newParticipant);
                    updateParticipantsList(); // Ponownie załaduj uczestników
                    eventBus.fire(
                        ParticipantChangedEvent()); // Wyślij powiadomienie
                    setState(() => joined = true);
                  }
                } catch (e) {
                  print("Error joining meeting: $e");
                }

                if (mounted) {
                  navigatorKey.currentState?.pop(); // Zamknij ekran ładowania
                  navigatorKey.currentState?.pop(); // Zamknij EventDetailsPage
                  navigatorKey.currentState?.pop();
                }
              },
              child: const Text("Dołącz"),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: white, width: 2),
          ),
        );
      },
    );
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        print(
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country},  ${place.administrativeArea},  ${place.name}");
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
  double rating;
  String userId;

  Participant({required this.name, required this.rating, required this.userId});
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
