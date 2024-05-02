import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/models/meetings.dart'; 
import 'package:meetoplay/meet_marker.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/event_details_page.dart';


class CreateMeetPage extends StatefulWidget {
  const CreateMeetPage({Key? key}) : super(key: key);

  @override
  _CreateMeetPageState createState() => _CreateMeetPageState();
}

class _CreateMeetPageState extends State<CreateMeetPage> {
  final MapController _mapController = MapController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _skillLevelController = TextEditingController();
  final TextEditingController _participantsCountController = TextEditingController();
  final TextEditingController _registeredCountController = TextEditingController();
  final TextEditingController _waitListCountController = TextEditingController();
  final TextEditingController _organizerNameController = TextEditingController();
  final TextEditingController _organizerRatingController = TextEditingController();
  LatLng _selectedLocation = LatLng(51.509865, -0.118092); // Default location

  void _handleTap(LatLng latlng) {
    setState(() {
      _selectedLocation = latlng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DODAJ SPOTKANIE'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [darkBlue, lightBlue],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _eventNameController,
              decoration: const InputDecoration(labelText: 'Nazwa wydarzenia'),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _selectedLocation,
                  zoom: 13.0,
                  onTap: (_, latlng) => _handleTap(latlng),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      MeetMarker(
                        location: _selectedLocation,
                        meeting: Meeting(
                          name: _eventNameController.text.isEmpty ? 'New Event' : _eventNameController.text,
                          location: _selectedLocation,
                          date: '2024-05-02',  // Example date
                          time: '15:00',  // Example time
                          category: 'Sports',
                          skillLevel: 'Beginner',
                          participantsCount: 10,
                          registeredCount: 5,
                          waitListCount: 2,
                          organizerName: 'John Doe',
                          organizerRating: 4.5,
                          participants: [],  // This should be handled according to your app's logic
                          userId: 'UserID'  // Adjust as necessary
                        ),
                        color: Colors.red,
                        size: 50.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => submitData(context),
              child: Text('Submit Meeting')
            ),
          ],
        ),
      ),
    );
  }

  Meeting createMeeting() {
    return Meeting(
      name: _eventNameController.text,
      location: _selectedLocation,
      date: _dateController.text,
      time: _timeController.text,
      category: _categoryController.text,
      skillLevel: _skillLevelController.text,
      participantsCount: int.tryParse(_participantsCountController.text) ?? 0,
      registeredCount: int.tryParse(_registeredCountController.text) ?? 0,
      waitListCount: int.tryParse(_waitListCountController.text) ?? 0,
      organizerName: _organizerNameController.text,
      organizerRating: double.tryParse(_organizerRatingController.text) ?? 0.0,
      participants: [],  // Here you would convert a list of participants if available
      userId: 'userId'  // Assume this is fetched from your user management system
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  void submitData(BuildContext context) {
    final meeting = createMeeting();
    // Here you would typically send the meeting data to a server or database
    Navigator.pop(context);  // Pop the context or navigate as necessary
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _categoryController.dispose();
    _skillLevelController.dispose();
    _participantsCountController.dispose();
    _registeredCountController.dispose();
    _waitListCountController.dispose();
    _organizerNameController.dispose();
    _organizerRatingController.dispose();
    super.dispose();
  }
}
