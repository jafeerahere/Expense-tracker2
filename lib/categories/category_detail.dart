import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';

class CategoryDetail extends StatefulWidget {
  final String categoryName;

  const CategoryDetail({super.key, required this.categoryName});

  @override
  _CategoryDetailState createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  List<Map<String, dynamic>> _expenses = [];
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId; // This will store the authenticated user's UID

  @override
  void initState() {
    super.initState();
    _getCurrentUserId(); // Get the authenticated user's ID
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // Get current user's ID from Firebase Auth
  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Set the userId to the current user's UID
        _fetchExpenses(); // Fetch expenses for the specific category
      });
    }
  }

  // Fetch expenses for the specific category from Firestore
  Future<void> _fetchExpenses() async {
    if (userId == null) return;

    // Get category details first (monthlyBudget and totalIncome)
    DocumentSnapshot categoryDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(widget.categoryName) // Use category name as document ID
        .get();

    if (categoryDoc.exists) {
      // You can fetch monthlyBudget and totalIncome from the category document
      double monthlyBudget = categoryDoc['monthlyBudget'];
      double totalIncome = categoryDoc['totalIncome'];

      // Fetch the expenses from the 'expenses' sub-collection within this category document
      QuerySnapshot expensesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      // Map the expenses into a list
      setState(() {
        _expenses = expensesSnapshot.docs.map((doc) {
          return {
            'description': doc['description'],
            'amount': doc['amount'],
            'date': (doc['date'] as Timestamp).toDate().toString(),
          };
        }).toList();
      });
    }
  }

  // Function to add a new expense to Firestore
  Future<void> _addExpense(String description, double amount) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not available')),
      );
      return;
    }

    setState(() {
      _expenses.add({
        'description': description,
        'amount': amount,
        'date': DateTime.now().toString(),
      });
    });

    // Save expense to Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .add({
      'description': description,
      'amount': amount,
      'date': DateTime.now(),
    });

    _fetchExpenses(); // Refresh the expense list after adding
  }

  // Dialog to add a new expense
  Future<void> _addExpenseDialog(BuildContext context) async {
    descriptionController.clear();
    amountController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Expense'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: descriptionController,
                  decoration:
                      const InputDecoration(hintText: 'Expense Description'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Amount'),
                ),
              ],
            ),
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
                String description = descriptionController.text;
                double? amount = double.tryParse(amountController.text);
                if (description.isNotEmpty && amount != null) {
                  _addExpense(description, amount); // Save expense to Firestore
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please provide valid description and amount')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Expenses for ${widget.categoryName}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '₹${_expenses.fold<double>(0.0, (sum, expense) => sum + (expense['amount'] as double)).toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 20),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
           Expanded(
  child: _expenses.isEmpty
      ? const Center(
          child: Text(
            'No expenses added yet.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
      : ListView.builder(
          itemCount: _expenses.length,
          itemBuilder: (context, index) {
            final expense = _expenses[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: Text(
                  expense['description'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(expense['date']),
                trailing: Text(
                  '₹${expense['amount']}',
                  style: const TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add expense'),
                onPressed: () => _addExpenseDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
