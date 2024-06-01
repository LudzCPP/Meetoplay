import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetoplay/admin/admin_dashboard.dart';
import 'package:meetoplay/rating_page.dart';
import 'authenticate_page.dart';
import 'global_variables.dart';
import 'wrapper.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<String> getCurrentUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    return userDoc['role'];
  }

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
        actions: [
          FutureBuilder<String>(
            future: getCurrentUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const SizedBox.shrink();
              } else if (snapshot.data == 'Admin') {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return const AdminDashboard();
                        },
                      ));
                    },
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: getCurrentUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Błąd wczytywania danych użytkownika.'));
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text('Nie można pobrać roli użytkownika.'));
          } else {
            String userRole = snapshot.data!;
            bool isGuest = userRole == 'Guest';

            return SingleChildScrollView(
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
                            title: const Text('Email',
                                style: TextStyle(color: Colors.black)),
                            subtitle: Text(user.email ?? 'Nie podano',
                                style: const TextStyle(color: white)),
                          ),
                          ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: darkBlue),
                            title: const Text('Data założenia konta',
                                style: TextStyle(color: Colors.black)),
                            subtitle: Text(
                                user.metadata.creationTime
                                        ?.toString()
                                        .split('.')[0] ??
                                    'Nieznana',
                                style: const TextStyle(color: white)),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text('Wyloguj'),
                          ),
                          const SizedBox(height: 20),
                          if (!isGuest)
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (user.email != null) {
                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                            email: user.email!);
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(Icons.lock),
                              label: const Text('Resetuj hasło'),
                            ),
                          const SizedBox(height: 30),
                          if (!isGuest) ...[
                            const Divider(thickness: 2),
                            const Text(
                              'Historia wydarzeń',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return const Text(
                                    'Błąd wczytywania historii wydarzeń.',
                                    style: TextStyle(color: Colors.red),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text(
                                    'Brak historii wydarzeń.',
                                    style: TextStyle(color: Colors.black54),
                                  );
                                }

                                var userData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                List<dynamic> history =
                                    userData['history'] ?? [];

                                if (history.isEmpty) {
                                  return const Text(
                                    'Brak historii wydarzeń.',
                                    style: TextStyle(color: Colors.black54),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: history.length,
                                  itemBuilder: (context, index) {
                                    var event = history[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                            color: darkBlue, width: 1),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(16.0),
                                        title: Text(
                                          event['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: darkBlue,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              'Data: ${event['date']} ${event['time']}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Kategoria: ${event['category']}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                            Icons.chevron_right,
                                            color: darkBlue),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RatingPage(event: event),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Wróć do logowania'),
                          ),
                        ],
                      ),
              ),
            );
          }
        },
      ),
    );
  }
}
