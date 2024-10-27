import 'package:flutter/material.dart';

// Define a Transaction model
class Transaction {
  final String description;
  final double amount;

  Transaction(this.description, this.amount);
}

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final List<Transaction> transactions = []; // List to hold transactions

  // Method to add a new transaction
  void _addTransaction(String description, double amount) {
    final newTransaction = Transaction(description, amount);
    setState(() {
      transactions.add(newTransaction); // Add transaction to the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(), // Show dialog to add transaction
          ),
        ],
      ),
      body: transactions.isNotEmpty
          ? ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  title: Text(transaction.description),
                  subtitle: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                );
              },
            )
          : const Center(
              child: Text('No transactions available.'),
            ),
    );
  }

  // Dialog to add a new transaction
  void _showAddTransactionDialog() {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
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
                final String description = descriptionController.text;
                final double amount = double.tryParse(amountController.text) ?? 0.0;

                if (description.isNotEmpty && amount > 0) {
                  _addTransaction(description, amount); // Call the add transaction method
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }
}
