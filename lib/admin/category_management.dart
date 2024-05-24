import 'package:flutter/material.dart';

class CategoriesManagementScreen extends StatelessWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories Management'),
      ),
      body: const Center(
        child: Text('Categories Management Screen'),
      ),
    );
  }
}
