
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myexpensetraker/DTO/Expense.dart';
import 'package:myexpensetraker/DatabaseHelper.dart';
import 'package:myexpensetraker/Utils.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  String expenseName = '';
  String expenseCategory = '';
  DateTime expenseDate = DateTime.now();
  double expenseAmount = 0.0;
  List<String> dropdownItems = [];
  String selectedItem = '';

  @override
  void initState() {
    super.initState();
    Utils.getExpenseCategories().then((dropdownItems) {
      setState(() {
        this.dropdownItems = dropdownItems;
        selectedItem = dropdownItems[0];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ADD EXPENSE'),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                ),
                validator: (expenseName_) {
                  if (expenseName_ == null || expenseName_.isEmpty) {
                    return 'Please enter an expense name.';
                  }
                  return null;
                },
                onChanged: (expenseName_) {
                  setState(() {
                    expenseName = expenseName_.toUpperCase();
                  });
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters:[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                  labelText: 'Expense Amount',
                ),
                validator: (expenseAmount_) {
                  if (expenseAmount_ == null || expenseAmount_.isEmpty) {
                    return 'Please enter an expense amount.';
                  }
                  try {
                    double.parse(expenseAmount_);
                  } catch (e) {
                    return 'Please enter a valid expense amount.';
                  }
                  return null;
                },
                onChanged: (expenseAmount_) {
                  setState(() {
                    expenseAmount = double.parse(expenseAmount_);
                  });
                },
              ),
              Container(margin: const EdgeInsets.fromLTRB(5,10, 5, 10), child: const Text('Pick Expense Category')),
              DropdownButton<String>(
                value: selectedItem,
                items: dropdownItems.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedItem = value!;
                    expenseCategory = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    var expense = Expense(
                      name: expenseName,
                      category: expenseCategory,
                      amount: expenseAmount,
                    );
                    // Save the expense to the database or other storage.
                    DatabaseHelper.instance.insertExpense(expense);

                    // Show a dialog message box indicating that the item has been added.
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Expense Added'),
                        content: const Text('Your expense has been added successfully.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      );
  }
}