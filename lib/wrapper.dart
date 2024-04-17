import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetoplay/authenticate_page.dart';
import 'package:meetoplay/home_page.dart';


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          // Jeśli użytkownik jest zalogowany (nie jest null), idź do HomeScreen
          if (user == null) {
            return AuthenticationScreen();
          } else {
            FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
              if (user != null) {
                try {
                  // Sprawdź, czy konto użytkownika istnieje
                  await user.reload();
                } catch (e) {
                  if (e is FirebaseAuthException && e.code == 'user-not-found') {
                    // Użytkownik usunięty, wyloguj
                    await FirebaseAuth.instance.signOut();
                  }
                }
              }
            });
            return HomePage();
          }
        } else {
          // Wyświetl ekran ładowania, gdy stan połączenia nie jest aktywny
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
