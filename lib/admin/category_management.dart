import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global_variables.dart';

class CategoriesManagementScreen extends StatelessWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorie sportu'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const CategoriesList(),
    );
  }
}

class CategoriesList extends StatefulWidget {
  const CategoriesList({super.key});

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  List<String> _categories = [];

  Future<void> _fetchCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    setState(() {
      _categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> _addCategory() async {
    final String newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      try {
        await _firestore.collection('categories').add({'name': newCategory});
        setState(() {
          _categories.add(newCategory);
        });
        _categoryController.clear();
        Fluttertoast.showToast(msg: "Kategoria została dodana.");
      } catch (e) {
        Fluttertoast.showToast(msg: "Błąd dodawania kategorii: $e");
      }
    } else {
      Fluttertoast.showToast(msg: "Kategoria już istnieje lub jest pusta.");
    }
  }

  Future<void> _deleteCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: category)
          .get();
      for (var doc in snapshot.docs) {
        await _firestore.collection('categories').doc(doc.id).delete();
      }
      setState(() {
        _categories.remove(category);
      });
      Fluttertoast.showToast(msg: "Kategoria została usunięta.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd usuwania kategorii: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: 'Nowa kategoria',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addCategory,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(_categories[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        _deleteCategory(_categories[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}
