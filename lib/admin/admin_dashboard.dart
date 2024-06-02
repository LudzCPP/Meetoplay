import 'package:flutter/material.dart';
import 'package:meetoplay/admin/admin_section.dart';
import 'package:meetoplay/admin/category_management.dart';
import 'package:meetoplay/admin/event_management.dart';
import 'package:meetoplay/admin/statistics.dart';
import 'package:meetoplay/admin/user_management.dart';
import 'package:meetoplay/global_variables.dart';


class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel administratora'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AdminSection(
              title: 'Użytkownicy',
              icon: Icons.people,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 16.0),
            AdminSection(
              title: 'Wydarzenia',
              icon: Icons.event,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EventManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 16.0),
            AdminSection(
              title: 'Kategorie sportu',
              icon: Icons.category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesManagementScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}