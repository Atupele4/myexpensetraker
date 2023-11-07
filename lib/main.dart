import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myexpensetraker/DatabaseHelper.dart';
import 'package:myexpensetraker/Register/Register.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'ExpenseApp/ExpenseApp.dart';
import 'firebase_options.dart';
import 'login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await openDatabase(
    join(await getDatabasesPath(), DatabaseHelper.DatabaseName),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, expenseid TEXT, name TEXT, description TEXT, expensedate TEXT, category TEXT, amount REAL)',
      );
    },
    version: 1,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? expenseTrackerValue = prefs.getString('loggedInUser');

  runApp(MyApp(expenseTrackerValue: expenseTrackerValue));
  initExpenseCategories();
}

void initExpenseCategories() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('expense_categories')) {
    List<String> expenseCategories = [
      "Groceries",
      "Utilities",
      "Transportation",
      "Dining Out",
      "Entertainment",
      "Shopping",
      "Healthcare",
      "Education",
      "Travel",
      "Insurance",
      "Taxes",
      "Savings",
      "Other",
    ];
    // Save the list to SharedPreferences
    prefs.setStringList('expense_categories', expenseCategories);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.expenseTrackerValue});
  final String? expenseTrackerValue;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: expenseTrackerValue == null || expenseTrackerValue!.isEmpty
          ? const MyHomePage(title: 'Flutter Demo Home Page')
          : const ExpenseApp(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      )
                    },
                child: const Text('SignIn')),
            ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Register()),
                      )
                    },
                child: const Text('Register')),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
