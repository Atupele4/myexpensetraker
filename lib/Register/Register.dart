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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInUser', loggedInUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
              decoration: const InputDecoration(labelText: 'Password'),
              onChanged: (password_) => {password = password_},
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: ElevatedButton(
                  onPressed: () async {
                    await _auth
                        .createUserWithEmailAndPassword(
                            email: email, password: password)
                        .then((newUser_) {

                      Utils.accountEmail = email;
                      String loggedInUser =
                          Utils.userCredentialToJson(newUser_);
                      Utils.prefs
                          .setString('loggedInUser', loggedInUser)
                          .then((value) {
                        navigateToNewScreen();
                      });
                    }).onError((error, stackTrace){

                      showDialog(
                        context: context,
                        builder: (context) {

                          return AlertDialog(
                            title: const Text('Error'),
                            content: Text(error.toString()),
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
                  child: const Text('Register')),
            )
          ],
        ),
      ),
    );
  }
}
