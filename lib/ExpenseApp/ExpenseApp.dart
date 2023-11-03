
import 'package:flutter/material.dart';
import 'package:myexpensetraker/ExpenseApp/ExpenseStatistics.dart';
import '../Utils.dart';
import 'AddExpens.dart';
import 'ExpenseCategories.dart';
import 'ExpenseList.dart';


class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  final String? loggedInUser = Utils.prefs.getString('loggedInUser');


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
                    Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    Text(
                      "Menu",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.add),
                    Text(" "),
                    Text("Add Expense"),
                  ],
                ),
                selected: _selectedIndex == 1,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpense()),);
                },
              ),ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.category),
                    Text(" "),
                    Text("Expense Category"),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseCategories()),);
                },
              ),
               ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.list),
                    Text(" "),
                    Text("Expense Listing"),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseList()),);
                },
              ),
              // ListTile(
              //   title: const Text("Settings"),
              //   onTap: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()),);
              //   },
              // ),
              ListTile(
                title: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.stacked_bar_chart),
                    Text(" "),
                    Text("Statistics"),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseStatistics()),);
                },
              ),
            ],
          ),
        ),
        body: Center(
          child: _widgetOptions[_selectedIndex],
        ),
      );
  }
}