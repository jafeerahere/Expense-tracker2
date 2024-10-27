import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _expenses = [];

  List<Map<String, dynamic>> get expenses => _expenses;

  Future<void> fetchExpenses(String userId) async {
    QuerySnapshot expensesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses') // Assuming all expenses are here
        .get();

    _expenses = expensesSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'description': doc['description'],
        'amount': doc['amount'],
        'date': (doc['date'] as Timestamp).toDate().toString(),
      };
    }).toList();

    notifyListeners();
  }

  Future<void> addExpense(String userId, String description, double amount) async {
    await _firestore.collection('users').doc(userId).collection('expenses').add({
      'description': description,
      'amount': amount,
      'date': DateTime.now(),
    });

    await fetchExpenses(userId); // Refresh the expense list after adding
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();

    await fetchExpenses(userId); // Refresh the expense list after deletion
  }
}
