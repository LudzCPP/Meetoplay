import 'package:flutter/material.dart';
import 'package:meetoplay/global_variables.dart';

class CreateMeetPage extends StatelessWidget {
  const CreateMeetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DODAJ SPOTKANIE',
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
      body: const Center(
        child: Text('FORMULARZ TWORZENIA SPOTKANIA'),
      ),
    );
  }
}
