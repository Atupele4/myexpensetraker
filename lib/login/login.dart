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
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (email_) => {email = email_},
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password*'),
              onChanged: (password_) => {password = password_},
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 25, 20, 25),
              child: ElevatedButton(
                  onPressed: () async {
                    await _auth
                        .signInWithEmailAndPassword(
                            email: email, password: password)
                        .then((newUser) {
                      String loggedInUser = Utils.userCredentialToJson(newUser);

                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('loggedInUser', loggedInUser);
                        navigateToNewScreen();
                      });
                    }).catchError((onError) {
                      showDialog(
                        context: context,
                        builder: (context) {

                          return AlertDialog(
                            title: const Text('Error'),
                            content: Text(onError.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    });
                  },
                  child: const Text('Sign')),
            )
          ],
        ),
      ),
    );
  }
}
