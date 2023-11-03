


import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:myexpensetraker/DTO/Expense.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';


class Utils {

  static late SharedPreferences prefs;

  static late Database database;

  static String DatabaseName = "expenses.db";

  static String userCredentialToJson(UserCredential userCredential) {
    return jsonEncode({
      'uid': userCredential.user?.uid,
      'email': userCredential.user?.email,
      'displayName': userCredential.user?.displayName,
      'photoURL': userCredential.user?.photoURL,
      'phoneNumber': userCredential.user?.phoneNumber,
    });
  }

  static Future<void> insertExpense(Expense expense) async {
    // Get a reference to the database.
    final db = database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<List<Expense>> expenses() async {
    // Get a reference to the database.
    final db = database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        category: maps[i]['category'] as String,
        amount: maps[i]['amount'] as double,
      );
    });
  }

  static Future<void> updateExpense(Expense expense) async {
    // Get a reference to the database.
    final db = database;

    // Update the given Dog.
    await db.update(
      'expenses',
      expense.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [expense.id],
    );
  }

  static Future<void> deleteExpense(int id) async {
    // Get a reference to the database.
    final db = database;

    // Remove the Dog from the database.
    await db.delete(
      'expenses',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
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

  static Future<Map<String, double>> getExpensesTotals() async {
    // Open the SQLite database.
    final db = await databaseFactory.openDatabase(Utils.DatabaseName);


    // Create a Map to store the totals for each category.
    final totals = <String, double>{};

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    List<Expense> results = List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        category: maps[i]['category'] as String,
        amount: maps[i]['amount'] as double,
      );
    });

    // Iterate over the results and add the amount to the total for the category.
    for (final result in results) {
      final String category = result.category;
      final double amount = result.amount;

      if (totals.containsKey(category)) {
        final xx = totals[category]!;
        totals[category] = amount + xx;
      } else {
        totals[category] = amount;
      }
    }

    // Return the Map of totals.
    return totals;
  }

}


