import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signInWithEmail() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Fluttertoast.showToast(msg: "Zalogowano: ${userCredential.user!.email}");
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd logowania: $e");
    }
  }

  void _registerWithEmail() async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Fluttertoast.showToast(msg: "Rejestracja pomyślna: ${userCredential.user!.email}");
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd rejestracji: $e");
    }
  }

  void _signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      Fluttertoast.showToast(msg: "Zalogowano anonimowo: ${userCredential.user!.uid}");
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd logowania anonimowego: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meetoplay")),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white)),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Hasło',
                  labelStyle: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _signInWithEmail,
              child: const Text('Zaloguj przez email'),
            ),
            ElevatedButton(
              onPressed: _signInAnonymously,
              child: const Text('Kontynuuj bez logowania'),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: _registerWithEmail,
              child: const Text('Rejestracja przez email'),
            ),
          ],
        ),
      ),
    );
  }
}
