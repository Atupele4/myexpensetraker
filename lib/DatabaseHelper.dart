import 'package:sqflite/sqflite.dart';

import 'DTO/Expense.dart';
import 'Utils.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    _database ??= await openDatabase(Utils.DatabaseName);
    return _database!;
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final results = await db.query('expenses');
    return results.map((row) => Expense.fromMap(row)).toList();
  }
}
