import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/home_page.dart';
import 'package:meetoplay/menu_page.dart';
import 'package:meetoplay/services/database.dart';

// Import Meeting class here
import 'package:meetoplay/models/meetings.dart'; // Zaimportuj swoją klasę Meeting

class CreateMeetPage extends StatefulWidget {
  const CreateMeetPage({super.key});

  @override
  _CreateMeetPageState createState() => _CreateMeetPageState();
}

class _CreateMeetPageState extends State<CreateMeetPage> {
  final MapController _mapController = MapController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _mapKey = GlobalKey();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(); // New
  final TextEditingController _categoryController =
      TextEditingController(); // New
  final TextEditingController _skillLevelController =
      TextEditingController(); // New
  final TextEditingController _searchController = TextEditingController();

  String? _selectedLevel;
  String? _selectedSport;
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

  @override
  Widget build(BuildContext context) {
    List<Marker> markersToShow = [_temporaryMarker];

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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa wydarzenia',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
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
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
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
                            onPrimary: Colors.white,
                            surface: lightBlue,
                            onSurface: Colors.white,
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
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Godzina',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wpisać godzinę wydarzenia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedSport,
                decoration: const InputDecoration(
                  labelText: 'Sport',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                dropdownColor: darkBlue,
                style: const TextStyle(color: Colors.white),
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
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                dropdownColor: darkBlue,
                style: const TextStyle(color: Colors.white),
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
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
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
                      hintStyle:
                          TextStyle(color: Colors.blueAccent.withOpacity(0.8)),
                      prefixIcon:
                          const Icon(Icons.map, color: Colors.blueAccent),
                      suffixIcon: IconButton(
                        icon:
                            const Icon(Icons.search, color: Colors.blueAccent),
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
                        // Replace this with Meeting creation logic
                        Meeting newMeeting = Meeting(
                          name: _eventNameController.text,
                          location: _selectedLocation,
                          date: _dateController.text,
                          time: _timeController.text,
                          category: _categoryController.text,
                          skillLevel: _skillLevelController.text,
                          participantsCount: 0,
                          registeredCount: 0,
                          waitListCount: 0,
                          organizerName:
                              FirebaseAuth.instance.currentUser!.displayName ??
                                  "Organizer",
                          organizerRating: 4.5, // Example rating
                          participants: [],
                          ownerId: FirebaseAuth.instance.currentUser!.uid,
                        );
                        DatabaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .updateMeeting(
                          _eventNameController.text,
                          _selectedLocation,
                          _dateController.text,
                          _timeController.text,
                          _categoryController.text,
                          _skillLevelController.text,
                          0,
                          0,
                          0,
                          FirebaseAuth.instance.currentUser!.displayName ??
                              "Organizer",
                          4.5, // Example rating
                          [],
                          FirebaseAuth.instance.currentUser!.uid,
                        );

                        // Store new meeting in database or manage it locally
                        print("New Meeting Created: ${newMeeting.name}");

                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Spotkanie zostało dodane!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(specialActionButtonColor),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: const Text('Dodaj spotkanie'),
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
    _categoryController.dispose();
    _skillLevelController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
