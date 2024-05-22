import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'authenticate_page.dart';
import 'global_variables.dart';
import 'wrapper.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: user != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      user.displayName ?? 'Nie podano',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.email, color: darkBlue),
                      title: const Text('Email', style: TextStyle(color: Colors.black)),
                      subtitle: Text(user.email ?? 'Nie podano', style: const TextStyle(color: white)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: darkBlue),
                      title: const Text('Data założenia konta', style: TextStyle(color: Colors.black)),
                      subtitle: Text(
                          user.metadata.creationTime?.toString().split('.')[0] ?? 'Nieznana',  style: const TextStyle(color: white)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                msg: "Wystąpił błąd podczas resetowania hasła: $e");
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Brak zarejestrowanego emaila, nie można zresetować hasła.");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: specialActionButtonColor,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      icon: const Icon(Icons.lock),
                      label: const Text('Resetuj hasło'),
                    ),
                    const SizedBox(height: 30),
                    const Divider(thickness: 2),
                    const Text(
                      'Historia wydarzeń',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    // Placeholder for events history
                    Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Brak historii wydarzeń.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Wróć do logowania'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
