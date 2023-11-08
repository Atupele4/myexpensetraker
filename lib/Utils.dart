import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {

  static late String selectedCurrency = "";
  static late SharedPreferences prefs;
  static String userCredentialToJson(UserCredential userCredential) {
    return jsonEncode({
      'uid': userCredential.user?.uid,
      'email': userCredential.user?.email,
      'displayName': userCredential.user?.displayName,
      'photoURL': userCredential.user?.photoURL,
      'phoneNumber': userCredential.user?.phoneNumber,
    });
  }

  static String jsonToUserCredential(String json) {
    final data = jsonDecode(json);
    return data['uid'];
  }

  static Future<List<String>> getExpenseCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final dropdownItems = prefs.getStringList('expense_categories') ?? [];
    return dropdownItems;
  }

  static Future<void> saveExpenseCategories(List<String> dropdownItems) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('expense_categories', dropdownItems);
  }

}


