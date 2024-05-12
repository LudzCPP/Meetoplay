import 'package:flutter/material.dart';
import 'package:meetoplay/edit_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:geocoding/geocoding.dart';
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
  @override
  Widget build(BuildContext context) {

    void showJoinDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Potwierdzenie"),
            content:
                const Text("Czy na pewno chcesz dołączyć do tego wydarzenia?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Anuluj"),
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknij okno dialogowe
                },
              ),
              TextButton(
                child: const Text("Dołącz"),
                onPressed: () {
                  setState(() {
                    joined = true;
                    print(joined); // Zaktualizuj stan dołączenia
                  });
                  Navigator.of(context).pop(); // Zamknij okno dialogowe
                },
              ),
            ],
          );
        },
      );
    }

    List<Participant> participants = [
      Participant(name: "Jan Kowalski", rating: 5, userId: "user001"),
      Participant(name: "Anna Nowak", rating: 4, userId: "user002"),
      Participant(name: "Tomasz Duda", rating: 3, userId: "user003"),
    ];

    Future<String> getAddressFromLatLng(
        double latitude, double longitude) async {
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
        }
        return "Nie można znaleźć adresu";
      } catch (e) {
        return "Błąd: $e";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting.name, style: const TextStyle(color: white)),
        backgroundColor: darkBlue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sports_soccer, color: white),
                      const SizedBox(width: 8),
                      Text('Sport: ${widget.meeting.category}',
                          style: const TextStyle(
                              fontSize: 18,
                              color: white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.bar_chart, color: white),
                      const SizedBox(width: 8),
                      Text('Poziom: ${widget.meeting.skillLevel}',
                          style: const TextStyle(
                              fontSize: 18,
                              color: white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Existing Widgets
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: getAddressFromLatLng(
                            widget.meeting.location.latitude,
                            widget.meeting.location.longitude),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) {
                            List<String> address = snapshot.data!.split(',');
                            return Flexible(
                              child: Text('Miejsce: ${address[0]}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: white,
                                      fontWeight: FontWeight.bold)),
                            );
                          } else if (snapshot.hasError) {
                            return Text("Błąd: ${snapshot.error}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: white,
                                    fontWeight: FontWeight.bold));
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: white),
                      const SizedBox(width: 8),
                      Text('Data: ${widget.meeting.date}',
                          style: const TextStyle(
                              fontSize: 18,
                              color: white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.access_time, color: white),
                      const SizedBox(width: 8),
                      Text(widget.meeting.time,
                          style: const TextStyle(
                              fontSize: 18,
                              color: white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                      'Maksymalna liczba uczestników: ${widget.meeting.participantsCount}',
                      style: const TextStyle(
                          fontSize: 18,
                          color: white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Wyłącza przewijanie listy uczestników
              itemCount: participants.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person, color: white),
                  title: Text(participants[index].name,
                      style: const TextStyle(
                          color: white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Ocena: ${participants[index].rating}',
                      style: const TextStyle(color: white)),
                );
              },
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditMeetPage(meeting: widget.meeting),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(orange),
                  foregroundColor: MaterialStateProperty.all(white),
                ),
                child: const Text('Edytuj spotkanie'),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
              child: ElevatedButton(
                onPressed: () {
                  // Logika dołączania do wydarzenia
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(orange),
                  foregroundColor: MaterialStateProperty.all(white),
                ),
                child: const Text('Dołącz do wydarzenia'),
              ),
            ),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 390, // Set a maximum height
              ),
              child: Padding(
                padding: EdgeInsets.all(4.0), // Add padding here
                child: GroupChatPage(meetingId: widget.meeting.meetingId),
              ),
            ),
            // Additional Widgets as per existing code
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(!joined) {
            showJoinDialog();
          } 
          print(joined);
        },
        backgroundColor:
            joined ? Colors.green : orange, // Wyłącz przycisk, jeśli dołączono
        child: Icon(joined ? Icons.check : Icons.add, color: white),
      ),
    );
  }
}

class Participant {
  String name;
  int rating;
  String userId; // User ID is included but not displayed

  Participant({required this.name, required this.rating, required this.userId});
}
