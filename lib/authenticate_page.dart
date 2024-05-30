import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meetoplay/global_variables.dart';
import 'register_page.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addUserToFirestore(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'nickname': user.displayName ?? '',
        'first_name': '',
        'last_name': '',
        'city': '',
        'birthdate': null,
        'role': 'User',
        'banned': false,
        'history': [],
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Błąd podczas dodawania użytkownika do Firestore: $e");
    }
  }

  Future<bool> _isUserBanned(User user) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists && userDoc['banned'] == true;
  }

  Future<void> _signInWithEmail() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (await _isUserBanned(userCredential.user!)) {
        await _auth.signOut();
        Fluttertoast.showToast(
            msg: "Twoje konto zostało zablokowane i nie możesz się zalogować.");
      } else {
        Fluttertoast.showToast(
            msg: "Zalogowano: ${userCredential.user!.email}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd logowania: $e");
    }
  }

  Future<void> _registerWithEmail() async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _addUserToFirestore(userCredential.user!);
      Fluttertoast.showToast(
          msg: "Rejestracja pomyślna: ${userCredential.user!.email}");
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd rejestracji: $e");
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      await _addUserToFirestore(userCredential.user!);
      Fluttertoast.showToast(
          msg: "Zalogowano anonimowo: ${userCredential.user!.uid}");
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd logowania anonimowego: $e");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (await _isUserBanned(userCredential.user!)) {
        await _auth.signOut();
        Fluttertoast.showToast(
            msg: "Twoje konto zostało zablokowane i nie możesz się zalogować.");
      } else {
        await _addUserToFirestore(userCredential.user!);
        Fluttertoast.showToast(
            msg: "Zalogowano przez Google: ${userCredential.user!.email}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd logowania przez Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meetoplay"),
        backgroundColor: darkBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
              TextField(
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
              ),
              const SizedBox(height: 10),
              TextField(
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
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _signInWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: specialActionButtonColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Zaloguj przez email'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signInAnonymously,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Kontynuuj bez logowania'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: pink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Rejestracja przez email'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Zaloguj przez Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
