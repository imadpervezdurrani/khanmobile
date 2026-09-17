import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/sale_model.dart';
import '../models/device_model.dart';
import '../services/firebase_service.dart';

class SalesProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _subscription;

  List<SaleModel> _sales = [];
  bool _isLoading = true;
  String _searchQuery = '';

  SalesProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();

    _subscription = _firebaseService.getSalesStream().listen((data) {
      _sales = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<SaleModel> get allSales => _sales;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<SaleModel> get filteredSales {
    if (_searchQuery.isEmpty) return _sales;
    final query = _searchQuery.toLowerCase();
    return _sales.where((s) {
      return s.invoiceNumber.toLowerCase().contains(query) ||
          s.customerName.toLowerCase().contains(query) ||
          s.customerPhone.contains(query) ||
          s.deviceModel.toLowerCase().contains(query) ||
          s.imei1.contains(query);
    }).toList();
  }

  // Summary Metrics
  double get totalRevenue =>
      _sales.fold(0.0, (sum, s) => sum + s.finalPrice);

  double get totalCOGS =>
      _sales.fold(0.0, (sum, s) => sum + s.purchasePrice);

  double get totalSalesProfit =>
      _sales.fold(0.0, (sum, s) => sum + s.profit);

  // Today's Sales
  List<SaleModel> get todaySales {
    final now = DateTime.now();
    return _sales.where((s) {
      return s.saleDate.year == now.year &&
          s.saleDate.month == now.month &&
          s.saleDate.day == now.day;
    }).toList();
  }

  double get todayRevenue =>
      todaySales.fold(0.0, (sum, s) => sum + s.finalPrice);

  double get todayProfit =>
      todaySales.fold(0.0, (sum, s) => sum + s.profit);

  int get todaySalesCount => todaySales.length;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  String _generateInvoiceNumber() {
    final count = _sales.length + 1001;
    return 'INV-$count';
  }

  Future<SaleModel> recordSale({
    required DeviceModel device,
    required double sellingPrice,
    required double discount,
    required String customerName,
    required String customerPhone,
    required String paymentMethod,
    String? notes,
  }) async {
    final finalPrice = sellingPrice - discount;
    final profit = finalPrice - device.purchasePrice;

    final sale = SaleModel(
      id: const Uuid().v4(),
      invoiceNumber: _generateInvoiceNumber(),
      deviceId: device.id,
      deviceBrand: device.brand,
      deviceModel: device.model,
      deviceStorage: device.storage,
      imei1: device.imei1,
      purchasePrice: device.purchasePrice,
      sellingPrice: sellingPrice,
      discount: discount,
      finalPrice: finalPrice,
      profit: profit,
      customerName: customerName.trim(),
      customerPhone: customerPhone.trim(),
      paymentMethod: paymentMethod,
      saleDate: DateTime.now(),
      notes: notes,
    );

    await _firebaseService.recordSale(sale);
    return sale;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
