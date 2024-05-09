import 'package:flutter/material.dart';
import 'package:meetoplay/edit_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:geocoding/geocoding.dart';
import 'models/meetings.dart';

class EventDetailsPage extends StatelessWidget {
  final Meeting meeting;

  const EventDetailsPage({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
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
        title: Text(meeting.name, style: const TextStyle(color: white)),
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
                      Text('Sport: ${meeting.category}',
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
                      Text('Poziom: ${meeting.skillLevel}',
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
                        future: getAddressFromLatLng(meeting.location.latitude,
                            meeting.location.longitude),
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
                      Text('Data: ${meeting.date}',
                          style: const TextStyle(
                              fontSize: 18,
                              color: white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.access_time, color: white),
                      const SizedBox(width: 8),
                      Text(meeting.time,
                          style: const TextStyle(
                              fontSize: 18,
                              color: white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Continue with existing widgets
                  Text(
                      'Maksymalna liczba uczestników: ${meeting.participantsCount}',
                      style: const TextStyle(
                          fontSize: 18,
                          color: white,
                          fontWeight: FontWeight.bold)),
                  // More Widgets as per existing code
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMeetPage(meeting: meeting),
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
            // Additional Widgets as per existing code
          ],
        ),
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
