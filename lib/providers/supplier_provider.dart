import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/supplier_model.dart';
import '../models/supplier_payment_model.dart';
import '../services/firebase_service.dart';

class SupplierProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _supSub;
  StreamSubscription? _paySub;

  List<SupplierModel> _suppliers = [];
  List<SupplierPaymentModel> _payments = [];
  bool _isLoading = true;
  String _searchQuery = '';

  SupplierProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();

    _supSub = _firebaseService.getSuppliersStream().listen((data) {
      _suppliers = data;
      _isLoading = false;
      notifyListeners();
    });

    _paySub = _firebaseService.getSupplierPaymentsStream().listen((data) {
      _payments = data;
      notifyListeners();
    });
  }

  List<SupplierModel> get allSuppliers => _suppliers;
  List<SupplierPaymentModel> get allPayments => _payments;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<SupplierModel> get filteredSuppliers {
    if (_searchQuery.isEmpty) return _suppliers;
    final query = _searchQuery.toLowerCase();
    return _suppliers.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.companyName.toLowerCase().contains(query) ||
          s.phone.contains(query);
    }).toList();
  }

  // Suppliers with pending dues (payable > 0)
  List<SupplierModel> get suppliersWithPayables =>
      _suppliers.where((s) => s.hasOutstandingPayable).toList();

  // Total shop payables to all suppliers
  double get totalAccountsPayable =>
      _suppliers.fold(0.0, (sum, s) => sum + s.balanceDue);

  double get totalBilledFromSuppliers =>
      _suppliers.fold(0.0, (sum, s) => sum + s.totalBilled);

  double get totalPaidToSuppliers =>
      _suppliers.fold(0.0, (sum, s) => sum + s.totalPaid);

  List<SupplierPaymentModel> getPaymentsForSupplier(String supplierId) {
    return _payments.where((p) => p.supplierId == supplierId).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addSupplier({
    required String name,
    required String phone,
    required String companyName,
    String? address,
    double initialBilled = 0.0,
    double initialPaid = 0.0,
    String? notes,
  }) async {
    final supplier = SupplierModel(
      id: const Uuid().v4(),
      name: name.trim(),
      phone: phone.trim(),
      companyName: companyName.trim(),
      address: address?.trim(),
      totalBilled: initialBilled,
      totalPaid: initialPaid,
      createdAt: DateTime.now(),
      notes: notes,
    );

    await _firebaseService.addSupplier(supplier);
  }

  Future<void> recordPayment({
    required SupplierModel supplier,
    required double amount,
    required DateTime date,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    final payment = SupplierPaymentModel(
      id: const Uuid().v4(),
      supplierId: supplier.id,
      supplierName: supplier.companyName.isNotEmpty
          ? supplier.companyName
          : supplier.name,
      amount: amount,
      date: date,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber?.trim(),
      notes: notes,
    );

    await _firebaseService.recordSupplierPayment(payment);
  }

  @override
  void dispose() {
    _supSub?.cancel();
    _paySub?.cancel();
    super.dispose();
  }
}
