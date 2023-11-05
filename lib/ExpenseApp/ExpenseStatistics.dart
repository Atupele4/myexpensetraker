import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myexpensetraker/DatabaseHelper.dart';

class ExpenseStatistics extends StatelessWidget {
  const ExpenseStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Statistics'),
        ),
        body: FutureBuilder(
          future: DatabaseHelper.instance.getExpensesTotals(),
          builder: (BuildContext context, AsyncSnapshot<Map<String, double>> snapshot) {
            if (snapshot.hasData) {
              // The data has been loaded from SQLite.
              final totals = snapshot.data!;

              // Return a ListView of the totals for each category.
              return ListView.builder(
                itemCount: totals.length,
                itemBuilder: (context, index) {
                  final category = totals.keys.elementAt(index);
                  final total = totals[category];

                  return ListTile(
                    title: Text(category),
                    subtitle: Text('ZMK ${total.toString()}'),
                  );
                },
              );
            } else if (snapshot.hasError) {
              // An error occurred while loading the data from SQLite.
              return Text('An error occurred while loading the data.');
            } else {
              // The data is still loading.
              return CircularProgressIndicator();
            }
          },
        ),
      );
  }
}
