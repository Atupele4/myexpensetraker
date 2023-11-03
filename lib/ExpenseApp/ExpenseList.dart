import 'package:flutter/material.dart';
import '../DTO/Expense.dart';
import '../DatabaseHelper.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({super.key});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  late Future<List<Expense>> _expensesFuture;
  late double countX = 0;
  @override
  void initState() {
    super.initState();
    _expensesFuture = DatabaseHelper.instance.getAllExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense List'),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            for (final expense in snapshot.data!) {
                countX += expense.amount;
            }

            return Container(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(0),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Category'),),
                    DataColumn(label: Text('Amount'),),
                    DataColumn(label: Text('Delete'))

                  ],
                  rows: snapshot.data!
                      .map((expense) => DataRow(
                            cells: [
                              DataCell(Text(expense.name.toUpperCase())),
                              DataCell(Text(expense.category.toString())),
                              DataCell(Text(expense.amount.toString())),
                              DataCell(ElevatedButton(
                                onPressed: () {
                                  // Handle button click
                                },
                                child: const Icon(Icons.delete,),
                              ))
                            ],
                          ))
                      .toList(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total'),
              Text('ZMK $countX'),
            ],
          ),
        ),
      ),
    );
  }
}
