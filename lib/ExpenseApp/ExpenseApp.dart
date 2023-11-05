import 'package:flutter/material.dart';
import 'package:myexpensetraker/DTO/ExpenseChartData.dart';
import 'package:myexpensetraker/ExpenseApp/ExpenseStatistics.dart';
import 'package:myexpensetraker/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
    ExpenseChartData('2023','Jan','Food',7),
    ExpenseChartData('2023','Feb','Transport',16),
  ];
  final int _selectedIndex = 0;

  Future<void> navigateToNewScreen() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

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
                ],
              ),
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.add),
                  Text(" Add Expense"),
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
                  Text(" Expense Category"),
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
                  Text(" Expense Listing"),
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
                  Text(" Statistics"),
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
            ListTile(
              title: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.stacked_bar_chart),
                  Text(" LogOut"),
                ],
              ),
              onTap: () async {

                final SharedPreferences prefs =
                await SharedPreferences.getInstance();
                await prefs.setString('loggedInUser', '');

                await navigateToNewScreen();
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
      ),
    );
  }
}
