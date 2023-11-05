import 'package:flutter/material.dart';
import 'package:myexpensetraker/DTO/ExpenseChartData.dart';
import 'package:myexpensetraker/ExpenseApp/ExpenseStatistics.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../Utils.dart';
import 'AddExpens.dart';
import 'ExpenseCategories.dart';
import 'ExpenseList.dart';

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  List<ExpenseChartData> data = [
    ExpenseChartData('Jan', 35),
    ExpenseChartData('Feb', 28),
    ExpenseChartData('Mar', 34),
    ExpenseChartData('Apr', 32),
    ExpenseChartData('May', 40),
    ExpenseChartData('Jun', 40),
    ExpenseChartData('Jul', 40),
    ExpenseChartData('Aug', 25),
    ExpenseChartData('Sep', 70),
    ExpenseChartData('Oct', 45),
    ExpenseChartData('Nov', 40),
    ExpenseChartData('Dec', 60),
  ];
  final int _selectedIndex = 0;

  final String? loggedInUser = Utils.prefs.getString('loggedInUser');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/drawer.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  Text(
                    "Menu",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.add),
                  Text(" "),
                  Text("Add Expense"),
                ],
              ),
              selected: _selectedIndex == 1,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddExpense()),
                );
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.category),
                  Text(" "),
                  Text("Expense Category"),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExpenseCategories()),
                );
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.list),
                  Text(" "),
                  Text("Expense Listing"),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpenseList()),
                );
              },
            ),
            ListTile(
              title: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.stacked_bar_chart),
                  Text(" "),
                  Text("Statistics"),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExpenseStatistics()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
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
                            xValueMapper: (ExpenseChartData sales, _) => sales.year,
                            yValueMapper: (ExpenseChartData sales, _) => sales.sales,
                            name: 'Sales',
                            // Enable data label
                            dataLabelSettings: const DataLabelSettings(isVisible: true))
                      ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
