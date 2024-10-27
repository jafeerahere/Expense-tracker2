import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jaff/categories/categories_screen.dart';
import 'package:jaff/services/firebaseauth_service.dart';

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  _ExpenseTrackerPageState createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;

  double totalIncome = 0;
  double monthlyBudget = 0;
  double totalExpenses = 0;
  double remainingAmount = 0;
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _fetchIncomeAndBudget(); // Fetch income and budget on initial load
      _fetchExpenses(); // Fetch expenses on initial load
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data whenever dependencies change
    if (currentUser != null) {
      _fetchIncomeAndBudget(); // Refresh income and budget
      _fetchExpenses(); // Refresh expenses
    }
  }

  Future<void> _fetchExpenses() async {
  if (currentUser != null) {
    QuerySnapshot expenseSnapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('categories')
        .get();
    setState(() {
      _expenses = expenseSnapshot.docs.map((doc) {
        Timestamp timestamp = doc['date'];
        DateTime dateTime = timestamp.toDate();
        String formattedDate = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
        return {
          'id': doc.id, // Get the document ID for uniqueness
          'description': doc['description'],
          'amount': doc['amount'],
          'date': formattedDate,
        };
      }).toList();
      totalExpenses = _expenses.fold(0, (sum, item) => sum + item['amount']);
      remainingAmount = monthlyBudget - totalExpenses;
    });
  }
}

 
  Future<void> _fetchIncomeAndBudget() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          totalIncome = userDoc['totalIncome'] ?? 0;
          monthlyBudget = userDoc['monthlyBudget'] ?? 0;
          remainingAmount = monthlyBudget - totalExpenses;
        });
      }
    }
  }
  // Save the user's income and budget to Firestore
  Future<void> _saveIncomeAndBudget() async {
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'totalIncome': totalIncome,
        'monthlyBudget': monthlyBudget,
      }, SetOptions(merge: true)); // Using merge to keep existing data
    }
  }
Future<void> _deleteExpense(Map<String, dynamic> expense) async {
  if (currentUser != null) {
    // Assuming each expense has an 'id' field to identify it
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('categories')
        .doc(expense['id']) // Use the unique ID to delete the document
        .delete();
    
    // Refresh the expense list after deletion
    await _fetchExpenses(); 
  }
}


  Future<void> _inputIncomeDialog() async {
    double? inputIncome;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Total Income'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              inputIncome = double.tryParse(value);
            },
            decoration: const InputDecoration(labelText: 'Income Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (inputIncome != null) {
                  setState(() {
                    totalIncome = inputIncome!;
                  });
                  _saveIncomeAndBudget();
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
 Future<void> _addExpense(String description, double amount) async {
  if (currentUser != null) {
    // Create a new document with a unique ID
    DocumentReference newExpenseRef = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('categories')
        .doc(); // Automatically generates a unique ID

    await newExpenseRef.set({
      'id': newExpenseRef.id, // Save the unique ID in the document
      'description': description,
      'amount': amount,
      'date': Timestamp.now(),
    });
    
    // Optionally fetch the expenses again to update the UI
    await _fetchExpenses();
  }
}


  Future<void> _inputBudgetDialog() async {
    double? inputBudget;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Monthly Budget'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              inputBudget = double.tryParse(value);
            },
            decoration: const InputDecoration(labelText: 'Budget Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (inputBudget != null) {
                  setState(() {
                    monthlyBudget = inputBudget!;
                    remainingAmount = monthlyBudget - totalExpenses;
                  });
                  _saveIncomeAndBudget();
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
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
        title: const Text('Expense Tracker'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: () async {
                // Call the logout method
                await FirebaseAuthService().logout();

                // Optionally navigate to the login screen or show a message
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout_outlined, size: 30, color: Colors.grey),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceOverview(),
            const SizedBox(height: 20),
            _buildIncomeExpenseSummary(),
            const SizedBox(height: 20),
            _buildBudgetOverview(),
            const SizedBox(height: 20),
            _buildExpenseList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to CategoriesScreen when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoriesScreen(
                onAddExpense: (String description, double amount) async {

                },
              ),
            ),
          );
        },
        label: const Text('Add Expenses'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 78, 209, 57),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBalanceOverview() {
    double balance = totalIncome - totalExpenses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Balance 💳', style: TextStyle(fontSize: 25, color: Color.fromARGB(255, 255, 0, 0) , )),
        const SizedBox(height: 8),
        Text(
          '₹${balance.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

Widget _buildIncomeExpenseSummary() {
  return Row(
    children: [
      Expanded(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 100, // Minimum height
            maxHeight: 170, // Maximum height
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Income 💵',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BreeSerif', // Set font style to Bree Serif
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${totalIncome.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BreeSerif', // Set font style to Bree Serif
                ),
              ),
              ElevatedButton(
                onPressed: _inputIncomeDialog,
                child: const Text('Set Income'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 100, // Minimum height
            maxHeight: 170, // Maximum height
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 236, 193, 208),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expenses 💸',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BreeSerif', // Set font style to Bree Serif
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '₹${totalExpenses.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BreeSerif', // Set font style to Bree Serif
                ),
              ),
              const SizedBox(height: 10),
              const ElevatedButton(
                onPressed: null, // No action for the button
                child: SizedBox.shrink(), // Empty child to hide button
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


 Widget _buildBudgetOverview() {
  return Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: _inputBudgetDialog,
          child: Stack(
            alignment: Alignment.bottomRight, // Aligns the icon to the bottom-right
            children: [
              Container(
                constraints: const BoxConstraints(
                  minHeight: 100, // Minimum height
                  maxHeight: 150, // Maximum height
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 219, 228, 161),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Budget 📅',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${monthlyBudget.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Add the icon here
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: _inputBudgetDialog, // Optional: add functionality for the icon tap
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 219, 228, 161), // Background for the icon
                      shape: BoxShape.circle, // Circular shape
                     
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 31, 31, 31), // Icon color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 100, // Minimum height
            maxHeight: 150, // Maximum height
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 192, 238, 203),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Remaining Budget 💸 ',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${remainingAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 222, 37, 24),  fontFamily: 'BreeSerif'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


 Widget _buildSummaryCard(String title, double amount, Color? color, ElevatedButton elevatedButton) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24), // Set border radius
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.blueGrey)),
        const SizedBox(height: 8),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'BreeSerif'),
        ),
        const SizedBox(height: 8),
        elevatedButton,
      ],
    ),
  );
}
Widget _buildExpenseList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Recent Expenses ⏱️:',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      ..._expenses.map((expense) {
        return Dismissible(
          key: Key(expense['id'].toString()), // Use a unique identifier
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            _deleteExpense(expense);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${expense['description']} dismissed')),
            );
          },
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              child: Icon(
                Icons.arrow_downward,
                color: Colors.red,
              ),
            ),
            title: Text(
              expense['description'] ?? 'No description',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              '₹${expense['amount']?.toString() ?? '0.00'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 28, 134, 17),
              ),
            ),
            trailing: Text(
              expense['date'] ?? 'Unknown Date',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }),
    ],
  );
}


} 