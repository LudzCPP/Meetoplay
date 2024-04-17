import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signInWithEmail() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print("Zalogowano: ${userCredential.user}");
    } catch (e) {
      print("Błąd logowania: $e");
    }
  }

  void _signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      print("Zalogowano anonimowo: ${userCredential.user}");
    } catch (e) {
      print("Błąd logowania anonimowego: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Auth")),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          ElevatedButton(
            onPressed: _signInWithEmail,
            child: Text('Login with Email'),
          ),
          ElevatedButton(
            onPressed: _signInAnonymously,
            child: Text('Login Anonymously'),
          ),
        ],
      ),
    );
  }
}
