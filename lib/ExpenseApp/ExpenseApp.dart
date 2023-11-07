import 'package:flutter/material.dart';
import 'package:myexpensetraker/ExpenseApp/ExpenseStatistics.dart';
import 'package:myexpensetraker/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DTO/Expense.dart';
import '../DatabaseHelper.dart';
import 'AddExpens.dart';
import 'ExpenseCategories.dart';
import 'package:intl/intl.dart';

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  late Future<List<Expense>> _expensesFuture;
  final int _selectedIndex = 0;
  late double countX = 0;
  late String formattedDate;

  Future<void> navigateToNewScreen() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  void initState() {
    super.initState();
    _expensesFuture = DatabaseHelper.instance.getAllExpenses();

    // Create a formatter for the desired format
    final formatter = DateFormat('MM/dd/yyyy');
    formattedDate = formatter.format(DateTime.now());

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
                children: [
                ],
              ),
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.add),
                  Text(" Add Expense"),
                ],
              ),
              selected: _selectedIndex == 1,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddExpense()),
                );
              },
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



            // Format the date to the desired string





            return DataTable(
              dataTextStyle: const TextStyle(
                fontSize: 10,
                color: Colors.black
              ),
              columnSpacing: 10,
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('View'))
              ],
              rows: snapshot.data!
                  .map((expense) => DataRow(
                cells: [
                  DataCell(Text(formattedDate)),
                  DataCell(Text(expense.name.toUpperCase())),
                  DataCell(Text(expense.category.toString())),
                  DataCell(Text(expense.amount.toString())),
                  DataCell(ElevatedButton(
                    onPressed: () {
                      // Handle button click
                    },
                    child: const Icon(Icons.open_in_new),
                  ))
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
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total'),
              Text('ZMK $countX'),
            ],
          ),
        ),
      ),
    );
  }
}
