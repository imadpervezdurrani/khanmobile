class ExpenseModel {
  final String id;
  final String title;
  final String category; // 'Shop Rent', 'Electricity & Bills', 'Staff Salaries', 'Tea & Refreshments', 'Shop Maintenance', 'Packaging & Supplies', 'Other'
  final double amount;
  final DateTime date;
  final String paymentMethod; // 'Cash', 'Bank Transfer', 'Online'
  final String? notes;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.paymentMethod = 'Cash',
    this.notes,
  });

  static const List<String> categories = [
    'Shop Rent',
    'Electricity & Bills',
    'Staff Salaries',
    'Tea & Refreshments',
    'Shop Maintenance',
    'Packaging & Supplies',
    'Marketing & Ads',
    'Other Expenses',
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ExpenseModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'Other Expenses',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      notes: map['notes'],
    );
  }
}
