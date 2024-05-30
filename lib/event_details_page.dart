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
import 'package:meetoplay/services/notification.dart';
import 'models/meetings.dart';
import 'models/message_module.dart';
import 'dart:math';

class EventDetailsPage extends StatefulWidget {
  final Meeting meeting;

  const EventDetailsPage({super.key, required this.meeting});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool joined = false;
  List<Participant> participants = [];
  List<Participant> waitingList = [];
  bool isEnded = false;
  List<Participant> teamA = [];
  List<Participant> teamB = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkUserJoinStatus();
    updateParticipantsList();
  }

  void updateParticipantsList() async {
    DocumentSnapshot meetingDoc = await FirebaseFirestore.instance
        .collection('meetings')
        .doc(widget.meeting.meetingId)
        .get();
    var data = meetingDoc.data() as Map<String, dynamic>;
    List<Participant> updatedParticipants = List<Participant>.from(
        (data['participants'] as List).map((item) => Participant(
              name: item['name'],
              rating: item['rating'],
              userId: item['userId'],
            )));
    List<Participant> updatedWaitingList = List<Participant>.from(
        (data['waitingList'] as List).map((item) => Participant(
              name: item['name'],
              rating: item['rating'],
              userId: item['userId'],
            )));
    setState(() {
      participants = updatedParticipants;
      waitingList = updatedWaitingList;
      isEnded = data['status'] == 'ended';
    });

    if (isEnded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RatingPage(meeting: widget.meeting),
        ),
      );
    }
  }

  void checkUserJoinStatus() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        bool isParticipant = await DatabaseService(uid: currentUser.uid)
            .isUserParticipant(widget.meeting.meetingId, currentUser.uid);
        bool isInWaitingList = await DatabaseService(uid: currentUser.uid)
            .isUserInWaitingList(widget.meeting.meetingId, currentUser.uid);
        setState(() {
          joined = isParticipant || isInWaitingList;
        });
      }
    } catch (e) {
      print("Error checking user join status: $e");
    }
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
                  buildWaitingList(),
                  if (currentUser?.uid == widget.meeting.ownerId)
                    buildEndEventButton(),
                  buildEditButton(),
                  buildJoinButton(),
                  buildDrawTeamsButton(),
                  buildTeamsDisplay(),
                  buildChatSection(widget.meeting.meetingId),
                ],
              ),
            ),
    );
  }

  Widget buildDrawTeamsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      child: ElevatedButton(
        onPressed: drawTeams,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
          foregroundColor: MaterialStateProperty.all(white),
        ),
        child: const Text('Wylosuj składy'),
      ),
    );
  }

  Widget buildTeamsDisplay() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Skład drużyny A:',
                  style: TextStyle(
                      fontSize: 18, color: white, fontWeight: FontWeight.bold),
                ),
              ),
              ...teamA.map((participant) => ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: Text(participant.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Ocena: ${participant.rating}',
                        style: const TextStyle(color: Colors.white)),
                  )),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Skład drużyny B:',
                  style: TextStyle(
                      fontSize: 18, color: white, fontWeight: FontWeight.bold),
                ),
              ),
              ...teamB.map((participant) => ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: Text(participant.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Ocena: ${participant.rating}',
                        style: const TextStyle(color: Colors.white)),
                  )),
            ],
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
  await FirebaseFirestore.instance
      .collection('meetings')
      .doc(widget.meeting.meetingId)
      .update({'status': 'ended'});

  for (Participant participant in participants) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(participant.userId)
        .update({
      'history': FieldValue.arrayUnion([
        {
          'meetingId': widget.meeting.meetingId,
          'name': widget.meeting.name,
          'date': widget.meeting.date,
          'time': widget.meeting.time,
          'category': widget.meeting.category,
          'skillLevel': widget.meeting.skillLevel,
          'organizerName': widget.meeting.organizerName,
          'organizerRating': widget.meeting.organizerRating,
        }
      ])
    });
  }

  setState(() {
    isEnded = true;
  });

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => RatingPage(meeting: widget.meeting),
    ),
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
            'Maksymalna liczba uczestników: ${widget.meeting.maxParticipants}'),
      ],
    );
  }

  Widget buildParticipantsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Uczestnicy:',
            style: TextStyle(
                fontSize: 18, color: white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
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
                        rating: item['rating'],
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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
        ),
      ],
    );
  }

  Widget buildWaitingList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Lista oczekujących:',
            style: TextStyle(
                fontSize: 18, color: white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200, // Ustawiamy maksymalną wysokość kontenera
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('meetings')
                .doc(widget.meeting.meetingId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                List<Participant> waitingList = List<Participant>.from(
                    (data['waitingList'] as List).map((item) => Participant(
                        name: item['name'],
                        rating: item['rating'],
                        userId: item['userId'])));
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: waitingList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: Text(waitingList[index].name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text('Ocena: ${waitingList[index].rating}',
                          style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParticipantProfilePage(
                                participant: waitingList[index]),
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
        ),
      ],
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
                return Colors.red; // Zmiana koloru przycisku na czerwony, jeśli użytkownik jest uczestnikiem
              }
              return orange;
            },
          ),
          foregroundColor: MaterialStateProperty.all(white),
        ),
        child: Icon(joined ? Icons.remove : Icons.add,
            color: white), // Zmiana ikony przycisku na "Usuń", jeśli użytkownik jest uczestnikiem
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
                        orElse: () => waitingList.firstWhere(
                            (p) => p.userId == currentUser.uid,
                            orElse: () => Participant(
                                name: 'Anonim',
                                rating: 0,
                                userId: currentUser.uid)));
                    await DatabaseService(uid: currentUser.uid)
                        .removeMeetingParticipant(
                            widget.meeting.meetingId, currentParticipant);
                    updateParticipantsList(); // Ponownie załaduj uczestników
                    PushNotifications().unscheduleNotification(0);
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
                    String dateTimeString =
                        '${widget.meeting.date}/${widget.meeting.time}';
                    List<String> dateTimeParts = dateTimeString.split('/');
                    String formattedDate =
                        '${dateTimeParts[2]}-${dateTimeParts[1].padLeft(2, '0')}-${dateTimeParts[0].padLeft(2, '0')}';
                    String formattedTime = dateTimeParts[3].padLeft(5, '0');
                    String formattedDateTimeString =
                        '$formattedDate $formattedTime';

                    DateTime meetingDateTime =
                        DateTime.tryParse(formattedDateTimeString) ??
                            DateTime.now();
                    PushNotifications().scheduleNotification(
                        widget.meeting.name, meetingDateTime);
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
        return "${place.locality}, ${place.street}";
      }
      return "Nie można znaleźć adresu";
    } catch (e) {
      return "Błąd: $e";
    }
  }

  void drawTeams() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      List<Participant> shuffledParticipants = List.from(participants);
      shuffledParticipants.shuffle(Random());

      int halfSize = (shuffledParticipants.length / 2).ceil();
      teamA = shuffledParticipants.sublist(0, halfSize);
      teamB = shuffledParticipants.sublist(halfSize);

      setState(() {
        isLoading = false;
      });
    });
  }

  Widget buildChatSection(String meetingId) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 390),
      padding: const EdgeInsets.all(4.0),
      child: GroupChatPage(
          meetingId: meetingId), // Przekazujesz meetingId do widgetu czatu
    );
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
