import 'package:flutter/material.dart';
import 'package:meetoplay/create_meet_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

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
          options: const MapOptions(
            initialCenter: LatLng(51.759247, 19.455982),
            initialZoom: 13.2,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.pinchMove,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
