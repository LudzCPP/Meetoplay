import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/event_details_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/models/meetings.dart';

class FindMeetPage extends StatefulWidget {
  const FindMeetPage({super.key});

  @override
  _FindMeetPageState createState() => _FindMeetPageState();
}

class _FindMeetPageState extends State<FindMeetPage> {
  final TextEditingController _sportController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String? _selectedLevel;
  final List<String> _levels = [
    'Początkujący',
    'Średniozaawansowany',
    'Zaawansowany'
  ];
  bool _areFreeSpotsAvailable = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedSport;
  List<Meeting> filteredMeetings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WYSZUKIWANIE'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var sportsList = snapshot.data!.docs
                    .map((doc) => doc['name'] as String)
                    .toList();
                return DropdownButtonFormField<String>(
                  value: _selectedSport,
                  decoration: const InputDecoration(
                    labelText: 'Wybierz sport',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  dropdownColor: darkBlue,
                  style: const TextStyle(color: Colors.white),
                  items: sportsList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSport = newValue;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Miasto',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Poziom zaawansowania',
                labelStyle: TextStyle(color: Colors.white),
              ),
              dropdownColor: darkBlue,
              style: const TextStyle(color: Colors.white),
              items: _levels.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLevel = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Dostępne miejsca',
                  style: TextStyle(color: Colors.white)),
              value: _areFreeSpotsAvailable,
              onChanged: (bool value) {
                setState(() {
                  _areFreeSpotsAvailable = value;
                });
              },
              activeColor: specialActionButtonColor,
            ),
            ListTile(
              title: const Text("Wybierz datę",
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                _selectedDate == null
                    ? "Nie wybrano daty"
                    : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: _pickDate,
            ),
            ListTile(
              title: const Text("Wybierz godzinę",
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                _selectedTime == null
                    ? "Nie wybrano godziny"
                    : _selectedTime!.format(context),
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: searchMeetings,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(specialActionButtonColor),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text('Szukaj'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMeetings.length,
                itemBuilder: (context, index) {
                  Meeting meeting = filteredMeetings[index];
                  return Card(
                    color: darkBlue,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(meeting.name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text("Organizator: ${meeting.organizerName}",
                          style: const TextStyle(color: Colors.white70)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsPage(meeting: meeting),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: specialActionButtonColor,
              onPrimary: white,
              surface: lightBlue,
              onSurface: white,
            ),
            dialogBackgroundColor: darkBlue,
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void searchMeetings() {
    List<Meeting> allMeetings = globalMeetings;
    filteredMeetings = allMeetings.where((meeting) {
      bool matchesSport =
          _selectedSport == null || meeting.category == _selectedSport;
      bool matchesCity = _cityController.text.isEmpty ||
          meeting.location.toString().contains(_cityController.text);
      bool matchesLevel =
          _selectedLevel == null || meeting.skillLevel == _selectedLevel;
      bool matchesFreeSpots = !_areFreeSpotsAvailable ||
          (meeting.maxParticipants > meeting.registeredCount);
      bool matchesDate = _selectedDate == null ||
          meeting.date ==
              "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
      bool matchesTime = _selectedTime == null ||
          meeting.time == _selectedTime!.format(context);
      return matchesSport &&
          matchesCity &&
          matchesLevel &&
          matchesFreeSpots &&
          matchesDate &&
          matchesTime;
    }).toList();
    setState(() {});
  }

  @override
  void dispose() {
    _sportController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
