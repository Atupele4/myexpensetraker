import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myexpensetraker/ExpenseApp/ExpenseStatistics.dart';
import 'package:myexpensetraker/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DTO/Expense.dart';
import '../DatabaseHelper.dart';
import 'AddExpens.dart';
import 'ExpenseCategories.dart';

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  late Future<List<Expense>> _expensesFuture;
  late double expenseTotal = 0;
  late String formattedDate;

  Future<void> navigateToNewScreen() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  Future<void> CloseAlert() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseApp()),
    );
  }

  Future<void> clearExpensesCollection() async {
    CollectionReference expensesCollection = FirebaseFirestore.instance.collection('expenses');
    QuerySnapshot querySnapshot = await expensesCollection.get();
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
  }

  Future<bool> backUpExpensesOnline(List<Expense> expenses, FirebaseFirestore db) async {
    for (var expense in expenses) {
      db.collection("expenses").add(expense.toMap()).then((value) => debugPrint('Document ID ${value.id}'));
    }
    return true;
  }

  Future<List<Expense>> getExpensesFromOnline() async {

    //clear local database
    DatabaseHelper.instance.clearDatabase();

    //get collection from online
    CollectionReference expensesCollection = FirebaseFirestore.instance.collection('expenses');
    QuerySnapshot querySnapshot = await expensesCollection.get();
    List<Expense> expensesMemory = [];

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Get the document data as a map
      final documentData = documentSnapshot.data();
      // Convert the document data to JSON
      String jsonData =  jsonEncode(documentData);
      // Decode the JSON string into an Expense object
      final expenseDec = jsonDecode(jsonData);
      Expense expenseFromOnline = Expense.fromMap(expenseDec);
      await DatabaseHelper.instance.insertExpense(expenseFromOnline);
      expensesMemory.add(expenseFromOnline);
    }
    return expensesMemory;
  }

  @override
  void initState() {
    super.initState();
    _expensesFuture = DatabaseHelper.instance.getAllExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/drawer.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [],
              ),
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.category),
                  Text(" Expense Category"),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExpenseCategories()),
                );
              },
            ),
            ListTile(
              title: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.stacked_bar_chart),
                  Text(" Statistics"),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExpenseStatistics()),
                );
              },
            ),
            ListTile(
              title: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.stacked_bar_chart),
                  Text(" LogOut"),
                ],
              ),
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('loggedInUser', '');

                await navigateToNewScreen();
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            expenseTotal = 0;
            for (final expense in snapshot.data!) {
              expenseTotal += expense.amount;
            }
            return RefreshIndicator(
              onRefresh: () async {
                final expenses = await DatabaseHelper.instance.expenses();
                setState(() {
                  _expensesFuture = Future.value(expenses);
                });
              },
              child: DataTable(
                dataTextStyle:
                    const TextStyle(fontSize: 10, color: Colors.black),
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: snapshot.data!
                    .map((expense) => DataRow(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete / View Expense'),
                                content: const Text(
                                    'Select the action you want to perform'),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // Delete the expense from the database or other storage
                                          DatabaseHelper.instance
                                              .deleteExpense(expense.id!);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('DELETE'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('VIEW'),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          cells: [
                            DataCell(Text(expense.expensedate)),
                            DataCell(Text(expense.name.toUpperCase())),
                            DataCell(Text(expense.category.toString())),
                            DataCell(Text(expense.amount.toString())),
                          ],
                        ))
                    .toList(),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total'),
              Text('ZMK $expenseTotal'),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddExpense()),
                );
              },
              child: const Icon(Icons.plus_one)),
          ElevatedButton(
              onPressed: () async {
                final expenses = await DatabaseHelper.instance.expenses();
                setState(() {
                  _expensesFuture = Future.value(expenses);
                });
              },
              child: const Icon(Icons.refresh)),
          ElevatedButton(
              onPressed: () async {
                FirebaseFirestore db = FirebaseFirestore.instance;

                final expenses = await DatabaseHelper.instance.expenses();
                await clearExpensesCollection();
                await backUpExpensesOnline(expenses, db).then((value) {
                  if(value == true){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Expenses Uploaded '),
                          content: const Text('Expenses were successfully uploaded online'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    );
                  }
                });
              },
              child: const Icon(Icons.upload)),
          ElevatedButton(
              onPressed: () async {
                await getExpensesFromOnline().then((value){
                  if (value.isNotEmpty) {
                    // Display an AlertDialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Expenses Retrieved'),
                          content: const Text('Expenses were successfully retrieved from the online source.'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    );
                  };
                });
              },
              child: const Icon(Icons.download)),
        ],
      ),
    );
  }


}
