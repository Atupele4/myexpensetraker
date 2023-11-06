import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ExpenseApp/ExpenseApp.dart';
import '../Utils.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  Future<void> navigateToNewScreen() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              labelText: 'Email'
            ),
            onChanged: (email_) => {email = email_},
          ),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password'
            ),
            onChanged: (password_) => {password = password_},
          ),
          ElevatedButton(
              onPressed: () async {
                final newUser = await _auth.signInWithEmailAndPassword(
                    email: email, password: password);
                String loggedInUser = Utils.userCredentialToJson(newUser);
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('loggedInUser', loggedInUser);
                await navigateToNewScreen();
              },
              child: const Text('Sign'))
        ],
      ),
    );
  }
}
