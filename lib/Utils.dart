import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DTO/Expense.dart';
import 'DTO/ExpenseItem.dart';
import 'DatabaseHelper.dart';

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

  static String generateExpenseSummary(List<Expense> expenses) {
    double totalExpense = 0;
    Map<String, List<ExpenseItem>> categoryItems = {};

    for (final expense in expenses) {
      totalExpense += expense.amount;

      if (!categoryItems.containsKey(expense.category)) {
        categoryItems[expense.category] = [];
      }

      categoryItems[expense.category]!.add(ExpenseItem(expense.name, expense.amount));
    }

    String summary = "Total Expense: ${totalExpense.toStringAsFixed(2)}\n\n";
    summary += "Itemized Expense Breakdown:\n";

    for (final category in categoryItems.keys) {
      summary += "\nCategory: $category\n";

      double categoryTotal = 0;
      for (final item in categoryItems[category]!) {
        summary +=
        "   - ${item.item}: ${item.price.toStringAsFixed(2)}\n";
        categoryTotal += item.price;
      }

      summary += "   Category Total: ${categoryTotal.toStringAsFixed(2)}\n";
    }

    return summary;
  }

  static Future<List<Expense>> getExpensesFromOnline() async {
    //clear local database
    DatabaseHelper.instance.clearDatabase();

    //get collection from online
    CollectionReference expensesCollection =
    FirebaseFirestore.instance.collection('expenses');
    QuerySnapshot querySnapshot = await expensesCollection.get();
    List<Expense> expensesMemory = [];

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Get the document data as a map
      final documentData = documentSnapshot.data();
      // Convert the document data to JSON
      String jsonData = jsonEncode(documentData);
      // Decode the JSON string into an Expense object
      final expenseDec = jsonDecode(jsonData);
      Expense expenseFromOnline = Expense.fromMap(expenseDec);
      await DatabaseHelper.instance.insertExpense(expenseFromOnline);
      expensesMemory.add(expenseFromOnline);
    }
    return expensesMemory;
  }

}


