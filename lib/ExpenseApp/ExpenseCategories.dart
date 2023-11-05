import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myexpensetraker/Utils.dart';

class ExpenseCategories extends StatefulWidget {
  const ExpenseCategories({super.key});

  @override
  State<ExpenseCategories> createState() => _ExpenseCategoriesState();
}

class _ExpenseCategoriesState extends State<ExpenseCategories> {
  List<String> dropdownItems = [];
  String selectedItem = '';
  TextEditingController textEditingController = TextEditingController();

  void addItem() {
    String newItem = textEditingController.text.toUpperCase();
    if (newItem.isNotEmpty) {
      setState(() {
        dropdownItems.add(newItem);
        selectedItem = newItem;
        Utils.saveExpenseCategories(dropdownItems);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Utils.getExpenseCategories().then((dropdownItems) {
      setState(() {
        this.dropdownItems = dropdownItems;
        if(dropdownItems.isNotEmpty){
          selectedItem = dropdownItems[0];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Categories'),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedItem,
                  items: dropdownItems.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value!;
                    });
                  },
                ),
                TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(labelText: 'New Category Name'),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: addItem,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
