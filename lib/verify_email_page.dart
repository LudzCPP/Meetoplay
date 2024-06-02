import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/wrapper.dart';
import 'authenticate_page.dart';

class VerifyEmailPage extends StatefulWidget {
  final User user;
  
  const VerifyEmailPage({required this.user});

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late Timer _timer;
  final _auth = FirebaseAuth.instance; 

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    await _auth.currentUser!.reload();
    if (_auth.currentUser!.emailVerified) {
      print("EMAIL ZWERYFIKOWANY");
      Fluttertoast.showToast(msg: "Email został zweryfikowany.");
      _timer.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await widget.user.sendEmailVerification();
      Fluttertoast.showToast(msg: "Wysłano ponownie email weryfikacyjny.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd podczas wysyłania emaila weryfikacyjnego: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weryfikacja Email"),
        backgroundColor: darkBlue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Email weryfikacyjny został wysłany na adres: ${widget.user.email}. Proszę sprawdzić skrzynkę pocztową i kliknąć w link weryfikacyjny.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: specialActionButtonColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Wyślij ponownie email weryfikacyjny'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
