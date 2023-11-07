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
  late double countX = 0;
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
            for (final expense in snapshot.data!) {
              countX += expense.amount;
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
                                content: const Text('Select the action you want to perform'),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // Delete the expense from the database or other storage
                                          DatabaseHelper.instance.deleteExpense(expense.id!);
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
              Text('ZMK $countX'),
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
        ],
      ),
    );
  }
}
