import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myexpensetraker/DatabaseHelper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../DTO/ExpenseChartData.dart';

class ExpenseStatistics extends StatefulWidget {
  const ExpenseStatistics({super.key});

  @override
  State<ExpenseStatistics> createState() => _ExpenseStatisticsState();
}

class _ExpenseStatisticsState extends State<ExpenseStatistics> {

  List<ExpenseChartData> data = [
    ExpenseChartData('2023','Jan','Food',7),
    ExpenseChartData('2023','Feb','Transport',16),
  ];

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
            return Container(
              margin: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            // Chart title
                            title: ChartTitle(text: 'Monthly Expense'),
                            // Enable legend
                            legend: const Legend(isVisible: true),
                            // Enable tooltip
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <ChartSeries<ExpenseChartData, String>>[
                              LineSeries<ExpenseChartData, String>(
                                  dataSource: data,
                                  xValueMapper: (ExpenseChartData sales, _) => sales.month,
                                  yValueMapper: (ExpenseChartData sales, _) => sales.totalItems,
                                  name: 'Sales',
                                  // Enable data label
                                  dataLabelSettings: const DataLabelSettings(isVisible: true))
                            ]),
                      ),
                    ],
                  ),
                ],
              ),
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