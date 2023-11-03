import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ExpenseApp/ExpenseApp.dart';
import '../Utils.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  Future<void> navigateToNewScreen() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseApp()),
    );

    final newUser = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    String loggedInUser = Utils.userCredentialToJson(newUser);
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();
    await prefs.setString('loggedInUser', loggedInUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Text('Email'),
          TextField(
            onChanged: (email_) => {email = email_},
          ),
          const Text('Password'),
          TextField(
            onChanged: (password_) => {password = password_},
          ),
          ElevatedButton(
              onPressed: () async {
                final newUser = await _auth.createUserWithEmailAndPassword(
                    email: email, password: password);
                String loggedInUser = Utils.userCredentialToJson(newUser);
                Utils.prefs = await SharedPreferences.getInstance();
                await Utils.prefs.setString('loggedInUser', loggedInUser);
                await navigateToNewScreen();
              },
              child: const Text('Register'))
        ],
      ),
    );
  }
}