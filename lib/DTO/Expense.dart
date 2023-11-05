class Expense {
  final int? id;
  final String name;
  final String category;
  final double amount;
  final DateTime date;

  const Expense(
      {this.id,
        required this.name,
        required this.category,
        required this.amount,
        required this.date});

  // Columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'date': date.toString(),
    };
  }

  // Implement toString to make it easier to see information about
  // each expense when using the print statement.
  @override
  String toString() {
    return 'Expense{id: $id, name: $name, amount: $amount, category: $category, date: $date}';
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      name: map['name'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      id: map['id'],
    );
  }
}