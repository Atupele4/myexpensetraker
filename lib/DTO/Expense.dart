class Expense {
  final int? id;
  final String name;
  final String category;
  final double amount;
  final String description;
  final String expensedate;

  const Expense(
      {this.id,
        required this.name,
        required this.category,
        required this.amount,
        required this.description,
        required this.expensedate,
      });

  // Columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'description': description,
      'expensedate': expensedate,
    };
  }

  // Implement toString to make it easier to see information about
  // each expense when using the print statement.
  @override
  String toString() {
    return 'Expense{id: $id, name: $name, amount: $amount, category: $category, description: $description, expensedate: $expensedate}';
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      name: map['name'],
      category: map['category'],
      amount: map['amount'],
      description: map['description'],
      expensedate: map['expensedate'],
      id: map['id'],
    );
  }
}
