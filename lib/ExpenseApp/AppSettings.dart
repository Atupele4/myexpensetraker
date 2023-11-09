import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
                child: Text(
              'Select Preferred Currency',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )),
            Row(
              children: [
                Radio(
                  value: 'ZMK',
                  groupValue: Utils.selectedCurrency,
                  onChanged: (value) {
                    setState(() {
                      Utils.selectedCurrency = value!;
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('Currency', value);
                      });
                    });
                  },
                ),
                const Text('ZMK'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 'USD',
                  groupValue: Utils.selectedCurrency,
                  onChanged: (value) {
                    setState(() {
                      Utils.selectedCurrency = value!;
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('Currency', value);
                      });
                    });
                  },
                ),
                const Text('USD'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 'EUR',
                  groupValue: Utils.selectedCurrency,
                  onChanged: (value) {
                    setState(() {
                      Utils.selectedCurrency = value!;
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('Currency', value);
                      });
                    });
                  },
                ),
                const Text('EUR'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        Utils.selectedCurrency = Utils.prefs.getString('Currency') ?? 'ZMK';
      });
    });
  }
}
