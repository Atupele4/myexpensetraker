import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myexpensetraker/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DTO/Expense.dart';
import '../DatabaseHelper.dart';
import '../Utils.dart';
import 'AddExpens.dart';
import 'AppSettings.dart';
import 'ExpenseCategories.dart';
import 'package:share_plus/share_plus.dart';
import 'ExpenseStatistics.dart';

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
        FirebaseFirestore.instance.collection(Utils.accountEmail);
    QuerySnapshot querySnapshot = await expensesCollection.get();
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
  }

  Future<bool> backUpExpensesOnline(
      List<Expense> expenses, FirebaseFirestore db) async {
    for (var expense in expenses) {
      db
          .collection(Utils.accountEmail)
          .add(expense.toMap())
          .then((value) => debugPrint('Document ID ${value.id}'));
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _expensesFuture = DatabaseHelper.instance.getAllExpenses();
      Utils.selectedCurrency = Utils.prefs.getString('Currency') ?? "ZMK";
    });
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
      body: bodyFunction(),
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
                bool isDone = false;

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      title: Text('Backing up expenses online...'),
                    );
                  },
                  barrierDismissible: false,
                );

                FirebaseFirestore db = FirebaseFirestore.instance;

                final expenses = await DatabaseHelper.instance.expenses();
                await clearExpensesCollection();

                await backUpExpensesOnline(expenses, db).then((value) {
                  Navigator.pop(context);
                  isDone = true;
                  if (value == true) {
                    // Display an AlertDialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Online Backup'),
                          content: const Text(
                              'Expenses have successfully backed up online'),
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
                }).catchError((onError){
                  Navigator.pop(context);
                  isDone = true;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Online Backup'),
                        content: Text(onError.toString()),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  );
                });

                while (isDone) {
                  await Future.delayed(const Duration(milliseconds: 100));
                }
              },
              child: const Icon(Icons.upload)),
          ElevatedButton(
              onPressed: () async {
                // Show a progress dialog
                bool isDone = false;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      title: Text('Loading...'),
                    );
                  },
                  barrierDismissible: false,
                );

                // Get the expenses from online
                await Utils.getExpensesFromOnline().then((value) {
                  // Close the progress dialog
                  Navigator.pop(context);
                  isDone = true;

                  if (value.isNotEmpty) {
                    // Display an AlertDialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Backup Restore'),
                          content: const Text(
                              'Online Expense backups have successfully been retrieved.'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    );
                  }else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Backup Restore'),
                          content: const Text(
                              'No Online Backup was found'),
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
                }).catchError((error) {
                  // Close the progress dialog
                  Navigator.pop(context);
                  isDone = true;

                  // Display an error message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: Text('Something went wrong: $error'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  );
                });

                // Wait until the progress dialog is closed
                while (!isDone) {
                  await Future.delayed(const Duration(milliseconds: 100));
                }
              },
              child: const Icon(Icons.download)),
          ElevatedButton(
              onPressed: () async {
                final expenseData = await _expensesFuture;
                final expenseSummary =
                    Utils.generateExpenseSummary(expenseData!);

                Share.share(expenseSummary);
              },
              child: const Text('Share'))
        ],
      ),
    );
  }

  Widget bodyFunction() {
    switch (_selectedIndex) {
      case 1:
        return const ExpenseStatistics();
      case 2:
        return const AppSettings();
      default:
        return FutureBuilder<List<Expense>>(
          future: _expensesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              expenseTotal = 0;
              for (final expense in snapshot.data!) {
                expenseTotal += expense.amount;
              }
              return Column(
                children: [
                  Center(
                    child: DataTable(
                      columnSpacing: 40,
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
                                  DataCell(Text(
                                      '${Utils.selectedCurrency} ${expense.amount.toString()}')),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const Center(child: Text('No Data'));
            }
          },
        );
    }
  }
}
