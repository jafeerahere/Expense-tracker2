import 'package:flutter/material.dart';

class TransactionHistory extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const TransactionHistory({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet.'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: const Icon(Icons.monetization_on, size: 40, color: Colors.blueAccent),
                  title: Text(transaction['category'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(transaction['date']),
                  trailing: Text(
                    '₹${transaction['amount'].toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}