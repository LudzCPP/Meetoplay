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
        title: const Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AdminSection(
              title: 'User Management',
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
              title: 'Event Management',
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
              title: 'Categories Management',
              icon: Icons.category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 16.0),
            AdminSection(
              title: 'Statistics & Reports',
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsReportsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}