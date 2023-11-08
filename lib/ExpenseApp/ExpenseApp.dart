import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myexpensetraker/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DTO/Expense.dart';
import '../DTO/ExpenseItem.dart';
import '../DatabaseHelper.dart';
import '../Utils.dart';
import 'AddExpens.dart';
import 'ExpenseCategories.dart';
import 'package:share_plus/share_plus.dart';

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  Future<List<Expense>>? _expensesFuture;
  late double expenseTotal = 0;
  late int _selectedIndex = 0;
  late String formattedDate;

  Future<void> navigateToNewScreen() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  Future<void> closeAlert() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseApp()),
    );
  }

  Future<void> clearExpensesCollection() async {
    CollectionReference expensesCollection =
        FirebaseFirestore.instance.collection('expenses');
    QuerySnapshot querySnapshot = await expensesCollection.get();
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
  }

  Future<bool> backUpExpensesOnline(
      List<Expense> expenses, FirebaseFirestore db) async {
    for (var expense in expenses) {
      db
          .collection("expenses")
          .add(expense.toMap())
          .then((value) => debugPrint('Document ID ${value.id}'));
    }
    return true;
  }

  Future<List<Expense>> getExpensesFromOnline() async {
    //clear local database
    DatabaseHelper.instance.clearDatabase();

    //get collection from online
    CollectionReference expensesCollection =
        FirebaseFirestore.instance.collection('expenses');
    QuerySnapshot querySnapshot = await expensesCollection.get();
    List<Expense> expensesMemory = [];

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Get the document data as a map
      final documentData = documentSnapshot.data();
      // Convert the document data to JSON
      String jsonData = jsonEncode(documentData);
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
    setState(() {
      SharedPreferences.getInstance().then((prefs) {
        setState(() {
          _expensesFuture = DatabaseHelper.instance.getAllExpenses();
          Utils.selectedCurrency = prefs.getString('Currency')!;
        });
      });
    });
  }

  String createEmailContent(String expenseSummary) {
    return "Expense Summary for the week of 2023-11-07 to 2023-11-13:\n\n$expenseSummary";
  }

  String generateExpenseSummary(List<Expense> expenses) {
    double totalExpense = 0;
    Map<String, List<ExpenseItem>> categoryItems = {};

    for (final expense in expenses) {
      totalExpense += expense.amount;

      if (!categoryItems.containsKey(expense.category)) {
        categoryItems[expense.category] = [];
      }

      categoryItems[expense.category]!.add(ExpenseItem(expense.name, expense.amount));
    }

    String summary = "Total Expense: ${totalExpense.toStringAsFixed(2)}\n\n";
    summary += "Itemized Expense Breakdown:\n";

    for (final category in categoryItems.keys) {
      summary += "\nCategory: $category\n";

      double categoryTotal = 0;
      for (final item in categoryItems[category]!) {
        summary +=
        "   - ${item.item}: ${item.price.toStringAsFixed(2)}\n";
        categoryTotal += item.price;
      }

      summary += "   Category Total: ${categoryTotal.toStringAsFixed(2)}\n";
    }

    return summary;
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
            return DataTable(
              dataTextStyle: const TextStyle(fontSize: 10, color: Colors.black),
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
                              title: const Text('Delete Expense'),
                              content: const Text(
                                  'Are you sure you want to delete this expense?'),
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
                                      child: const Text('YES'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('NO'),
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
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              // Navigate to the home page
              Navigator.pushNamed(context, '/ExpenseApp');
              break;
            case 1:
              // Navigate to the statistics page
              Navigator.pushNamed(context, '/ExpenseStatistics');
              break;
            case 2:
              // Navigate to the settings page
              Navigator.pushNamed(context, '/AppSettings');
              break;
          }
        },
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
                  if (value == true) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Expenses Uploaded '),
                          content: const Text(
                              'Expenses were successfully uploaded online'),
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
                await getExpensesFromOnline().then((value) {
                  if (value.isNotEmpty) {
                    // Display an AlertDialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Expenses Retrieved'),
                          content: const Text(
                              'Expenses were successfully retrieved from the online source.'),
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
              child: const Icon(Icons.download)),
          ElevatedButton(
              onPressed: () async {
                final expenseData = await _expensesFuture;
                final expenseSummary = generateExpenseSummary(expenseData!);

                Share.share(expenseSummary);
              },
              child: const Text('Share'))
        ],
      ),
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
