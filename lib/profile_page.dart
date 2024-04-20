import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetoplay/authenticate_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/wrapper.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFIL'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) ...[
              Text('Nazwa użytkownika: ${user.displayName ?? "Nie podano"}'),
              SizedBox(height: 10),
              Text('Email: ${user.email ?? "Nie podano"}'),
              SizedBox(height: 10),
              Text('Data założenia konta: ${user.metadata.creationTime?.toString() ?? "Nieznana"}'),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Wyloguj'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: specialActionButtonColor, // Use a global variable for color
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (user.email != null) {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                      Fluttertoast.showToast(msg: "Link do resetowania hasła został wysłany na Twój email.");
                    } catch (e) {
                      Fluttertoast.showToast(msg: "Wystąpił błąd podczas resetowania hasła: $e");
                    }
                  } else {
                    Fluttertoast.showToast(msg: "Brak zarejestrowanego emaila, nie można zresetować hasła.");
                  }
                },
                child: const Text('Resetuj hasło'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: specialActionButtonColor, // Use a global variable for color
                ),
              ),
            ] else ...[
              Text("Brak danych użytkownika."),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Wróć do logowania'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: specialActionButtonColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
