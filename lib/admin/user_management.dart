import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Użytkownicy'),
        backgroundColor: Colors.blueAccent,
      ),
      body: UserList(),
    );
  }
}

class UserList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('users')
          .where('role', isNotEqualTo: 'Guest')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Coś poszło nie tak.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                isThreeLine: true,
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  data['nickname'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${data['email']}',
                        overflow: TextOverflow.ellipsis),
                    Text('Rola: ${data['role']}'),
                    Text('Status: ${data['banned'] ? "Zablokowany" : "Aktywny"}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () {
                        _editUser(context, document.id, data['nickname'],
                            data['email'], data['role'], data['banned']);
                      },
                    ),
                    IconButton(
                      icon: Icon(data['banned'] ? Icons.lock_open : Icons.lock,
                          color: Colors.redAccent),
                      onPressed: () {
                        _toggleBanUser(context, document.id, data['banned']);
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _editUser(BuildContext context, String userId, String nickname,
      String email, String role, bool banned) async {
    final TextEditingController nicknameController =
        TextEditingController(text: nickname);
    final TextEditingController emailController =
        TextEditingController(text: email);
    String selectedRole = role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edytuj użytkownika'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Nazwa'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Rola'),
                items: ['User', 'Admin'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedRole = newValue!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _firestore.collection('users').doc(userId).update({
                  'nickname': nicknameController.text,
                  'email': emailController.text,
                  'role': selectedRole,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Zapisz',
                  style: TextStyle(color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleBanUser(
      BuildContext context, String userId, bool isBanned) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'banned': !isBanned,
      });
      Fluttertoast.showToast(msg: isBanned ? "Użytkownik odblokowany." : "Użytkownik zablokowany.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd: $e");
    }
  }
}
