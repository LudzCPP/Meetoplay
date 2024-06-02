import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:meetoplay/global_variables.dart';
import 'verify_email_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  DateTime? _birthdate;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Wybierz datę urodzenia';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        userCredential.user!.updateDisplayName(_nicknameController.text);

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text.trim(),
          'nickname': _nicknameController.text.trim(),
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'city': _cityController.text.trim(),
          'birthdate': _birthdate?.toIso8601String(),
          'rating': 0,
          'ratingCounter': 0,
          'role': 'User',
          'banned': false,
          'history': [],
        });

        await userCredential.user!.sendEmailVerification();
        Fluttertoast.showToast(
            msg: "Rejestracja pomyślna: ${userCredential.user!.email}");
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => VerifyEmailPage(user: userCredential.user!)),
        );
      } catch (e) {
        Fluttertoast.showToast(msg: "Błąd rejestracji: $e");
      }
    } else {
      Fluttertoast.showToast(msg: "Proszę poprawić błędy w formularzu.");
    }
  }

  void _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthdate) {
      setState(() {
        _birthdate = picked;
        _birthdateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rejestracja"),
        backgroundColor: darkBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: white),
                    filled: true,
                    fillColor: darkBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić Email';
                    }
                    if (!value.contains('@')) {
                      return 'Proszę wprowadzić prawidłowy adres email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Hasło',
                    labelStyle: const TextStyle(color: white),
                    filled: true,
                    fillColor: darkBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić Hasło';
                    }
                    if (value.length < 8) {
                      return 'Hasło musi mieć co najmniej 8 znaków';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Potwierdź hasło',
                    labelStyle: const TextStyle(color: white),
                    filled: true,
                    fillColor: darkBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę potwierdzić hasło';
                    }
                    if (value != _passwordController.text) {
                      return 'Hasła nie są zgodne';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Nick',
                    labelStyle: const TextStyle(color: white),
                    filled: true,
                    fillColor: darkBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić Nick';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Imię',
                    labelStyle: const TextStyle(color: white),
                    filled: true,
                    fillColor: darkBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić Imię';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Nazwisko',
                    labelStyle: const TextStyle(color: white),
                    filled: true,
                    fillColor: darkBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić Nazwisko';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Miasto',
                    labelStyle: const TextStyle(color: white),
                    filled: true,
                    fillColor: darkBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić Miasto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _birthdateController,
                  decoration: InputDecoration(
                    labelText: 'Data urodzenia',
                    labelStyle: const TextStyle(color: white),
                    filled: true,
                    fillColor: darkBlue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today, color: white),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectBirthdate(context);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wybrać datę urodzenia';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: specialActionButtonColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Zarejestruj się'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
