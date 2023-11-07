import 'package:sqflite/sqflite.dart';

import 'DTO/Expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  static String DatabaseName = "expenses.db";
  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    _database ??= await openDatabase(DatabaseName);
    return _database!;
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final results = await db.query('expenses');
    return results.map((row) => Expense.fromMap(row)).toList();
  }

  Future<void> insertExpense(Expense expense) async {
    // Get a reference to the database.
    final db = await database;

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

  Future<void> clearDatabase() async {
    // Get a reference to the database.
    final db = await database;
    // Clear the 'expenses' table.
    await db.delete('expenses');
  }

  Future<List<Expense>> expenses() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Expense(
        name: maps[i]['name'] as String,
        category: maps[i]['category'] as String,
        amount: maps[i]['amount'] as double,
        description: maps[i]['description'] as String,
        expensedate: maps[i]['expensedate'] as String,
        id: maps[i]['id'] as int,
      );
    });
  }

  Future<void> updateExpense(Expense expense) async {
    // Get a reference to the database.
    final db = await database;

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

  Future<int> deleteExpense(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    return await db.delete(
      'expenses',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getExpensesTotals() async {
    // Open the SQLite database.
    final db = await databaseFactory.openDatabase(DatabaseName);

    // Create a Map to store the totals for each category.
    final totals = <String, double>{};

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    List<Expense> results = List.generate(maps.length, (i) {
      return Expense(
        name: maps[i]['name'] as String,
        category: maps[i]['category'] as String,
        amount: maps[i]['amount'] as double,
        description: maps[i]['description'] as String,
        expensedate: maps[i]['expensedate'] as String,
        id: maps[i]['id'] as int,
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
