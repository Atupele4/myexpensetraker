import 'package:flutter/material.dart';
import 'package:myexpensetraker/DatabaseHelper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../DTO/Expense.dart';
import '../DTO/PieData.dart';

class ExpenseStatistics extends StatefulWidget {
  const ExpenseStatistics({super.key});

  @override
  State<ExpenseStatistics> createState() => _ExpenseStatisticsState();
}

class _ExpenseStatisticsState extends State<ExpenseStatistics> {
  List<Expense>? expenses = [];
  List<PieData> pieChartData = [];

  @override
  void initState() {
    super.initState();
    _getExpenses();
  }

  void _getExpenses() async {
    expenses = await DatabaseHelper.instance.expenses();
    _calculatePieChartData();
  }

  List<PieData> _calculatePieChartData() {
    Map<String, double> categoryTotals = {};

    for (Expense expense in expenses!) {
      categoryTotals[expense.category] ??= 0;
      final totalx = categoryTotals[expense.category] ?? 0;
      final newTotal = totalx + expense.amount;
      categoryTotals[expense.category] = newTotal;
    }

    if(categoryTotals.isNotEmpty){
      double totalExpenses = categoryTotals.values.reduce((a, b) => a + b);

      for (MapEntry<String, double> entry in categoryTotals.entries) {
        setState(() {
          pieChartData.add(PieData(entry.key, entry.value / totalExpenses * 100, entry.key));
        });
      }
    }

    return pieChartData;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder(
        future: DatabaseHelper.instance.getExpensesTotals(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, double>> snapshot) {
          if (snapshot.hasData) {
            return Center(
                child:SfCircularChart(
                    title: ChartTitle(text: 'Expenses Category allocation'),
                    legend: const Legend(isVisible: true),
                    series: <PieSeries<PieData, String>>[
                      PieSeries<PieData, String>(
                          explode: true,
                          explodeIndex: 0,
                          dataSource: pieChartData,
                          xValueMapper: (PieData data, _) => data.xData,
                          yValueMapper: (PieData data, _) => data.yData,
                          dataLabelMapper: (PieData data, _) => data.text,
                          dataLabelSettings: const DataLabelSettings(isVisible: true)),
                    ]
                )
            );
          } else if (snapshot.hasError) {
          // An error occurred while loading the data from SQLite.
          return const Text('An error occurred while loading the data.');
          } else {
          // The data is still loading.
          return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}