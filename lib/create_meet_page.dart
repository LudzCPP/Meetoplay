import 'package:flutter/material.dart';
import 'package:meetoplay/global_variables.dart';

class CreateMeetPage extends StatefulWidget {
  const CreateMeetPage({Key? key}) : super(key: key);

  @override
  _CreateMeetPageState createState() => _CreateMeetPageState();
}

class _CreateMeetPageState extends State<CreateMeetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

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
                decoration: InputDecoration(
                  labelText: 'Nazwa wydarzenia',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wpisać nazwę wydarzenia';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Dodaj odstęp między polami
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Miejsce',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wpisać miejsce wydarzenia';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Data',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: specialActionButtonColor),
                  ),
                ),
                style: TextStyle(color: Colors.white),
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
                          colorScheme: ColorScheme.dark(
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Przetwarzanie danych')),
                        );
                      }
                    },
                    child: const Text('Dodaj spotkanie'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          specialActionButtonColor), // Kolor tła przycisku
                      foregroundColor: MaterialStateProperty.all(
                          Colors.white), // Kolor tekstu przycisku
                    ),
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
