import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/home_page.dart';
import 'package:meetoplay/menu_page.dart';
import 'package:meetoplay/services/database.dart';

// Import Meeting class here
import 'package:meetoplay/models/meetings.dart'; // Zaimportuj swoją klasę Meeting

class EditMeetPage extends StatefulWidget {
  final Meeting meeting;

  const EditMeetPage({required this.meeting, super.key});

  @override
  _EditMeetPageState createState() => _EditMeetPageState();
}

class _EditMeetPageState extends State<EditMeetPage> {
  final MapController _mapController = MapController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _mapKey = GlobalKey();
  late TextEditingController _eventNameController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _searchController;

  String? _selectedLevel;
  String? _selectedSport;
  bool _isOrganizerParticipating = false;
  int? _selectedMaxParticipants;
  LatLng _selectedLocation = const LatLng(0, 0);
  final List<String> _levels = [
    'Początkujący',
    'Średniozaawansowany',
    'Zaawansowany'
  ];
  Marker _temporaryMarker = const Marker(
    point: LatLng(0, 0),
    child: Icon(
      Icons.location_on,
      color: Colors.blue,
      size: 0,
    ),
  );

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.meeting.name);
    _locationController = TextEditingController(
        text: '${widget.meeting.location.latitude}, ${widget.meeting.location.longitude}');
    _dateController = TextEditingController(text: widget.meeting.date);
    _timeController = TextEditingController(text: widget.meeting.time);
    _searchController = TextEditingController();
    _selectedSport = widget.meeting.category;
    _selectedLevel = widget.meeting.skillLevel;
    _selectedMaxParticipants = widget.meeting.maxParticipants;
    _isOrganizerParticipating = widget.meeting.participants
        .contains(FirebaseAuth.instance.currentUser!.uid);
    _selectedLocation = widget.meeting.location;
    _temporaryMarker = Marker(
      width: 50,
      height: 50,
      alignment: const Alignment(0, -0.9),
      point: widget.meeting.location,
      child: const Icon(
        Icons.location_on,
        color: Colors.blue,
        size: 50,
      ),
    );
  }

  void _handleTap(TapPosition, LatLng latlng) {
    setState(() {
      _selectedLocation = latlng;
      _locationController.text = '${latlng.latitude}, ${latlng.longitude}';
      _temporaryMarker = Marker(
        width: 50,
        height: 50,
        alignment: const Alignment(0, -0.9),
        point: latlng,
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 50,
        ),
      );
    });
  }

  Future<void> _searchAndUpdateLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final firstLocation = locations.first;
        LatLng newLatLng =
            LatLng(firstLocation.latitude, firstLocation.longitude);
        setState(() {
          _mapController.move(newLatLng, _mapController.camera.zoom);
          _temporaryMarker = Marker(
            width: 50,
            height: 50,
            point: newLatLng,
            alignment: const Alignment(0, -0.9),
            child: const Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 50,
            ),
          );
          _locationController.text =
              '${newLatLng.latitude}, ${newLatLng.longitude}';
          _selectedLocation = newLatLng;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adres nie został znaleziony.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd wyszukiwania adresu: $e')));
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('HH:mm'); // Używając DateFormat z pakietu intl
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markersToShow = [_temporaryMarker];

    return Scaffold(
      appBar: AppBar(
        title: const Text('EDYTUJ SPOTKANIE'),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa wydarzenia',
                  labelStyle: TextStyle(color: white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                style: const TextStyle(color: white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wpisać nazwę wydarzenia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Additional fields for time, category, and skill level
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  labelStyle: TextStyle(color: white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                style: const TextStyle(color: white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wpisać datę wydarzenia';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
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
                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    setState(() {
                      _dateController.text = formattedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: orange,
                              onPrimary: white,
                              surface: darkBlue,
                              onSurface: white,
                            ),
                            dialogBackgroundColor: darkBlue,
                          ),
                          child: child!,
                        ),
                      );
                    },
                  );
                  if (pickedTime != null) {
                    _timeController.text = formatTimeOfDay(pickedTime);
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Godzina',
                      labelStyle: TextStyle(color: white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: orange),
                      ),
                    ),
                    style: const TextStyle(color: white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę wybrać godzinę wydarzenia';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedSport,
                decoration: const InputDecoration(
                  labelText: 'Sport',
                  labelStyle: TextStyle(color: white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                dropdownColor: darkBlue,
                style: const TextStyle(color: white),
                items: sportsList.map<DropdownMenuItem<String>>((String value) {
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
                icon: const Icon(Icons.arrow_drop_down, color: white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wybrać sport';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                itemHeight: 50,
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Poziom zaawansowania',
                  labelStyle: TextStyle(color: white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                dropdownColor: darkBlue,
                style: const TextStyle(color: white),
                items: _levels.map<DropdownMenuItem<String>>((String value) {
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
                icon: const Icon(Icons.arrow_drop_down, color: white),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedMaxParticipants,
                decoration: const InputDecoration(
                  labelText: 'Maksymalna liczba uczestników',
                  labelStyle: TextStyle(color: white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: orange),
                  ),
                ),
                dropdownColor: darkBlue,
                style: const TextStyle(color: white),
                items: List<DropdownMenuItem<int>>.generate(49, (int index) {
                  return DropdownMenuItem<int>(
                    value: index + 2,
                    child: Text('${index + 2}'),
                  );
                }),
                onChanged: (int? value) {
                  setState(() {
                    _selectedMaxParticipants = value;
                  });
                },
                icon: const Icon(Icons.arrow_drop_down, color: white),
              ),
              const SizedBox(height: 40),
              CheckboxListTile(
                activeColor: orange,
                title: const Text(
                  'Biorę udział w wydarzeniu',
                  style: TextStyle(color: white),
                ),
                value: _isOrganizerParticipating,
                onChanged: (bool? value) {
                  setState(() {
                    _isOrganizerParticipating = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.blueAccent),
                    decoration: InputDecoration(
                      hintText: 'Wpisz adres, np. ul. Piotrkowska, Łódź',
                      hintStyle: TextStyle(
                          color: Colors.blueAccent.withOpacity(0.8)),
                      prefixIcon:
                          const Icon(Icons.map, color: Colors.blueAccent),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.blueAccent),
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          _searchAndUpdateLocation(_searchController.text);
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                    ),
                    onSubmitted: (value) {
                      _searchAndUpdateLocation(value);
                    },
                  ),
                ),
              ),

              SizedBox(
                height: 300,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    cameraConstraint: CameraConstraint.contain(
                      bounds: LatLngBounds(
                        const LatLng(49.002, 14.122),
                        const LatLng(54.838, 24.145),
                      ),
                    ),
                    minZoom: 7,
                    maxZoom: 20,
                    initialCenter: const LatLng(51.759247, 19.455982),
                    initialZoom: 13.2,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                          InteractiveFlag.drag |
                          InteractiveFlag.pinchMove,
                    ),
                    onTap: _handleTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: markersToShow),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Update meeting logic here
                        DatabaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .updateMeeting(
                          widget.meeting.meetingId,
                          _eventNameController.text,
                          _selectedLocation,
                          _dateController.text,
                          _timeController.text,
                          _selectedSport.toString(),
                          _selectedLevel.toString(),
                          _selectedMaxParticipants!.toInt(),
                          0,
                          0,
                          FirebaseAuth.instance.currentUser!.displayName ??
                              "Organizer",
                          4.5, // Example rating
                          [],
                          [],
                          FirebaseAuth.instance.currentUser!.uid,
                        );
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Spotkanie zostało zaktualizowane!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(specialActionButtonColor),
                      foregroundColor: MaterialStateProperty.all(white),
                    ),
                    child: const Text('Zaktualizuj spotkanie'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
