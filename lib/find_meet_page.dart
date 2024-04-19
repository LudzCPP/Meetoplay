import 'package:flutter/material.dart';
import 'package:meetoplay/global_variables.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _sportController,
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
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Miasto',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: specialActionButtonColor),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
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
            ),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Logika wyszukiwania
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(specialActionButtonColor),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: const Text('Szukaj'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
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

  @override
  void dispose() {
    _sportController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
