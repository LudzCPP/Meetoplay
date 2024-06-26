import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/models/meetings.dart';

class EventManagementScreen extends StatelessWidget {
  const EventManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wydarzenia'),
        backgroundColor: Colors.blueAccent,
      ),
      body: EventList(),
    );
  }
}

class EventList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EventList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('meetings').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Coś poszło nie tak'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10.0),
                title: Text(
                  data['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data: ${data['date']}'),
                    Text('Czas: ${data['time']}'),
                    Text('Sport: ${data['category']}'),
                    Text('Poziom zaawansowania: ${data['skillLevel']}'),
                    Text('Uczestnicy: ${data['participants'].length} / ${data['maxParticipants']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () {
                        _editEvent(context, document.id, data);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        _deleteEvent(context, document.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _editEvent(BuildContext context, String eventId, Map<String, dynamic> eventData) async {
    final TextEditingController nameController = TextEditingController(text: eventData['name']);
    final TextEditingController dateController = TextEditingController(text: eventData['date']);
    final TextEditingController timeController = TextEditingController(text: eventData['time']);
    final TextEditingController categoryController = TextEditingController(text: eventData['category']);
    final TextEditingController skillLevelController = TextEditingController(text: eventData['skillLevel']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edytuj wydarzenie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nazwa wydarzenia'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Data'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Czas'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Sport'),
              ),
              TextField(
                controller: skillLevelController,
                decoration: const InputDecoration(labelText: 'Poziom zaawansowania'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _firestore.collection('meetings').doc(eventId).update({
                  'name': nameController.text,
                  'date': dateController.text,
                  'time': timeController.text,
                  'category': categoryController.text,
                  'skillLevel': skillLevelController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Zapisz', style: TextStyle(color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(BuildContext context, String eventId) async {
    try {
      await _firestore.collection('meetings').doc(eventId).delete();
      Fluttertoast.showToast(msg: "Wydarzenie zostało usunięte.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd usuwania wydarzenia: $e");
    }
  }
}
