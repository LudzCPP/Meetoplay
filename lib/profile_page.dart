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
        child: user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    textColor: white,
                    title: const Text(
                      'Nazwa użytkownika:',
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(user.displayName ?? 'Nie podano'),
                  ),
                  ListTile(
                    textColor: white,
                    title: const Text(
                      'Email:',
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(user.email ?? 'Nie podano'),
                  ),
                  ListTile(
                    textColor: white,
                    title: const Text(
                      'Data założenia konta:',
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                        user.metadata.creationTime?.toString().split('.')[0] ??
                            'Nieznana'),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const AuthWrapper()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: specialActionButtonColor,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Wyloguj'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (user.email != null) {
                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: user.email!);
                          Fluttertoast.showToast(
                              msg:
                                  "Link do resetowania hasła został wysłany na Twój email.");
                        } catch (e) {
                          Fluttertoast.showToast(
                              msg:
                                  "Wystąpił błąd podczas resetowania hasła: $e");
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg:
                                "Brak zarejestrowanego emaila, nie można zresetować hasła.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: specialActionButtonColor,
                    ),
                    icon: const Icon(Icons.lock),
                    label: const Text('Resetuj hasło'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Brak danych użytkownika."),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const AuthWrapper()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: specialActionButtonColor,
                    ),
                    child: const Text('Wróć do logowania'),
                  ),
                ],
              ),
      ),
    );
  }
}
