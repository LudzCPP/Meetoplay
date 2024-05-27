import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/event_bus.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/create_meet_page.dart';
import 'package:meetoplay/models/meetings.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  String? selectedSport;

  @override
  void initState() {
    super.initState();
    _registerNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAPA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
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
      body: Center(
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom |
                  InteractiveFlag.drag |
                  InteractiveFlag.pinchMove,
            ),
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                const LatLng(49.002, 14.122), // SW point of Poland
                const LatLng(54.838, 24.145), // NE point of Poland
              ),
            ),
            minZoom: 7,
            maxZoom: 20,
            initialCenter: const LatLng(51.759247, 19.455982),
            initialZoom: 13.2,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: _filteredMarkers(),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateMeetPage(),
            ),
          );
        },
        backgroundColor: pink,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    String? tempSelectedSport =
        selectedSport; // tymczasowa zmienna do przechowywania wyboru

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Wybierz sport'),
              content: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categories')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var categories = snapshot.data!.docs
                        .map((doc) => doc['name'] as String)
                        .toList();
                    return ListBody(
                      children: [
                        ...categories.map((String sport) {
                          return ListTile(
                            title: Text(sport),
                            selected: tempSelectedSport == sport,
                            selectedTileColor: Colors.blue.shade100,
                            onTap: () {
                              setStateDialog(() {
                                if (tempSelectedSport == sport) {
                                  tempSelectedSport = null;
                                } else {
                                  tempSelectedSport = sport;
                                }
                              });
                            },
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedSport = tempSelectedSport;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Marker> _filteredMarkers() {
    if (selectedSport == null) return globalMarkers;
    return globalMarkers
        .where((marker) => marker.meeting.category == selectedSport)
        .toList();
  }

  void _registerNotification() {
    eventBus.on<ParticipantChangedEvent>().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    eventBus.destroy();
    super.dispose();
  }
}
