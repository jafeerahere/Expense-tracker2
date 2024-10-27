import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get package
import 'package:jaff/categories/category_detail.dart';

class CategoriesScreen extends StatefulWidget {
  final Future<Null> Function(String description, double amount) onAddExpense; // Define the onAddExpense parameter

  const CategoriesScreen({super.key, required this.onAddExpense}); // Pass it to the constructor

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // List of predefined categories
  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.fastfood, 'color': Colors.orange},
    {'name': 'Travel', 'icon': Icons.airplanemode_active, 'color': Colors.blue},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.green},
    {'name': 'Shopping', 'icon': Icons.shopping_cart, 'color': Colors.pink},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.red},
    {'name': 'Bills & Utilities', 'icon': Icons.receipt, 'color': Colors.teal},
    {'name': 'Health & Wellness', 'icon': Icons.local_hospital, 'color': Colors.purple},
    {'name': 'Others', 'icon': Icons.category, 'color': Colors.grey},
  ];

  // Controller for adding custom categories
  final TextEditingController customCategoryController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controller to prevent memory leaks
    customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addCategoryDialog(context),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryButton(category);
        },
      ),
    );
  }

  // Helper method to build category buttons
  Widget _buildCategoryButton(Map<String, dynamic> category) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: category['color'],
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        // Navigate to CategoryDetail using Get
        Get.to(() => CategoryDetail(categoryName: category['name']));
      },
      icon: Icon(category['icon'], size: 30, color: Colors.white),
      label: Text(
        category['name'],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Dialog for adding custom categories
  Future<void> _addCategoryDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Custom Category'),
          content: TextField(
            controller: customCategoryController,
            decoration: const InputDecoration(hintText: 'Enter Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (customCategoryController.text.isEmpty) {
                  // Simple validation for empty category name
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category name cannot be empty')),
                  );
                  return;
                }
                _addCategory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to add custom categories
  void _addCategory() {
    setState(() {
      categories.add({
        'name': customCategoryController.text,
        'icon': Icons.category,
        'color': Colors.grey,
      });
    });
    customCategoryController.clear(); // Clear the input after adding the category
  }
}
