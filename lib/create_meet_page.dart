import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/home_page.dart';
import 'package:meetoplay/meet_marker.dart';
import 'package:meetoplay/menu_page.dart';
import 'package:meetoplay/services/database.dart';

class CreateMeetPage extends StatefulWidget {
  const CreateMeetPage({super.key});

  @override
  _CreateMeetPageState createState() => _CreateMeetPageState();
}

class _CreateMeetPageState extends State<CreateMeetPage> {
  final MapController _mapController = MapController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(); // New field for sport category
  final TextEditingController _skillLevelController = TextEditingController(); // New field for skill level
  LatLng _selectedLocation = const LatLng(0, 0);
  Marker _temporaryMarker = const Marker(
    point: LatLng(0, 0),
    child: Icon(
      Icons.location_on,
      color: Colors.blue,
      size: 0,
    ),
  ); // Temporary marker

  void _handleTap(TapPosition, LatLng latlng) {
    setState(() {
      latlng = LatLng(latlng.latitude, latlng.longitude);
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
              // Field for category
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategoria sportu',
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
                    return 'Proszę wybrać kategorię sportu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(49.002, 14.122), // South-West corner of Poland
                      const LatLng(54.838, 24.145), // North-East corner of Poland
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
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: globalMarkers, // Ensure `globalMarkers` is defined
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
              // Field for skill level
              TextFormField(
                controller: _skillLevelController,
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
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wybrać poziom zaawansowania';
                  }
                  return null;
                },
              ),
              // Continue with existing widgets and add new functionalities
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
    _categoryController.dispose(); // Dispose new controllers
    _skillLevelController.dispose(); // Dispose new controllers
    super.dispose();
  }
}
