import 'package:flutter/material.dart';
import 'package:meetoplay/create_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MAPA',
        ),
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
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                const LatLng(
                    49.002, 14.122), // Południowo-Zachodni punkt Polski
                const LatLng(54.838, 24.145), // Północno-Wschodni punkt Polski
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
              markers: globalMarkers,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(mapController.camera.visibleBounds.east.toString());
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const CreateMeetPage();
              },
            ),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: pink,
        elevation: 4.0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
