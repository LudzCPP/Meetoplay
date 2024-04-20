//import 'dart:js_interop';

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
  final GlobalKey _mapKey = GlobalKey();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  LatLng _selectedLocation = const LatLng(0, 0);
  Marker _temporaryMarker = const Marker(
    point: LatLng(0, 0),
    child: Icon(
      Icons.location_on,
      color: Colors.blue,
      size: 0,
    ),
  ); // Tymczasowy marker

  void _handleTap(TapPosition, LatLng latlng) {
    setState(() {
      latlng = LatLng(latlng.latitude, latlng.longitude);
      _selectedLocation = latlng;
      print(_selectedLocation);
      _locationController.text = '${latlng.latitude}, ${latlng.longitude}';
      _temporaryMarker = Marker(
        point: latlng,
        child: Transform.translate(
          offset: const Offset(-8, -32), // Przesunięcie o połowę szerokości i całą wysokość w górę
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 50,
          ),
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    List<Marker> markersToShow = List.from(globalMarkers);
    markersToShow.add(_temporaryMarker);

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
              SizedBox(
                height: 300,
                child: FlutterMap(
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 20),
                                    Text('Trwa dodawanie spotkania...'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            globalMarkers.add(MeetMarker(
                              location: _selectedLocation,
                              eventTitle: _eventNameController.text,
                              tooltipMessage: "Opis",
                              color: Colors.red,
                            ));
                          });

                          DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).updateMeeting(_eventNameController.text, _selectedLocation.latitude,_selectedLocation.longitude, _dateController.text);

                          Navigator.of(context)
                              .pop();
                          Navigator.of(context).popUntil((route) =>
                              route.isFirst);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Spotkanie zostało dodane!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        });
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
    super.dispose();
  }
}
