import 'package:flutter/material.dart';
import 'package:meetoplay/global_variables.dart';

class EventDetailsPage extends StatelessWidget {
  // Sample meeting data directly defined within the widget
  final Meeting meeting = Meeting(
    name: 'Developer Conference',
    location: 'Warsaw, Poland',
    date: '2024-05-01',
    time: '10:00 AM',
    participantsCount: 100,
    registeredCount: 75,
    waitListCount: 10,
    organizerName: 'Jan Kowalski',
    organizerRating: 4.5,
    participants: [
      Participant(name: 'Adam', rating: 4),
      Participant(name: 'Kacper', rating: 4),
      Participant(name: 'Michał', rating: 4),
      Participant(name: 'Stanisław', rating: 4),
      Participant(name: 'Martyna', rating: 5),
    ],
  );

  EventDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meeting.name, style: TextStyle(color: white)),
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
                      Icon(Icons.location_on, color: white),
                      SizedBox(width: 8),
                      Text('Miejsce: ${meeting.location}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: white),
                      SizedBox(width: 8),
                      Text('Data: ${meeting.date}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.access_time, color: white),
                      SizedBox(width: 8),
                      Text('${meeting.time}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width * 0.7,
                      color: Colors.white.withOpacity(0.7),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  Text('Maksymalna liczba uczestników: ${meeting.participantsCount}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Zapisani: ${meeting.registeredCount}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Lista rezerwowa: ${meeting.waitListCount}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: white),
                      SizedBox(width: 8),
                      Text('Organizator: ${meeting.organizerName}', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Text('(${meeting.organizerRating}/5)', style: TextStyle(fontSize: 18, color: white)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Uczestnicy:', style: TextStyle(fontSize: 18, color: white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              height: 300,
              child: ListView.builder(
                itemCount: meeting.participants.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.person, color: specialActionButtonColor),
                      title: Text('${meeting.participants[index].name} (${index + 1})'),
                      subtitle: Text('Ocena: ${meeting.participants[index].rating}/5'),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(specialActionButtonColor)),
                  child: Text('Dołącz do wydarzenia', style: TextStyle(color: white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Meeting {
  String name;
  String location;
  String date;
  String time;
  int participantsCount;
  int registeredCount;
  int waitListCount;
  String organizerName;
  double organizerRating;
  List<Participant> participants;

  Meeting({
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.participantsCount,
    required this.registeredCount,
    required this.waitListCount,
    required this.organizerName,
    required this.organizerRating,
    required this.participants,
  });
}

class Participant {
  String name;
  int rating;

  Participant({required this.name, required this.rating});
}
