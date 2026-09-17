import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/firebase_service.dart';

class ExpenseProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _subscription;

  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  ExpenseProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();

    _subscription = _firebaseService.getExpensesStream().listen((data) {
      _expenses = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<ExpenseModel> get allExpenses => _expenses;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<ExpenseModel> get filteredExpenses {
    if (_selectedCategory == 'All') return _expenses;
    return _expenses.where((e) => e.category == _selectedCategory).toList();
  }

  // Summary
  double get totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get todayExpenses {
    final now = DateTime.now();
    return _expenses.where((e) {
      return e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day;
    }).fold(0.0, (sum, e) => sum + e.amount);
  }

  double get thisMonthExpenses {
    final now = DateTime.now();
    return _expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).fold(0.0, (sum, e) => sum + e.amount);
  }

  // Category breakdown for pie/bar charts
  Map<String, double> get categoryBreakdown {
    final Map<String, double> map = {};
    for (var cat in ExpenseModel.categories) {
      map[cat] = 0.0;
    }
    for (var exp in _expenses) {
      map[exp.category] = (map[exp.category] ?? 0.0) + exp.amount;
    }
    // Remove zero entries
    map.removeWhere((key, value) => value <= 0);
    return map;
  }

  void setSelectedCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  Future<void> addExpense({
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    required String paymentMethod,
    String? notes,
  }) async {
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      title: title.trim(),
      category: category,
      amount: amount,
      date: date,
      paymentMethod: paymentMethod,
      notes: notes,
    );

    await _firebaseService.addExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _firebaseService.deleteExpense(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
