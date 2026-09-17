import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../firebase_options.dart';
import '../models/device_model.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../models/supplier_model.dart';
import '../models/supplier_payment_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _firestore;
  bool _isFirebaseInitialized = false;

  bool get isFirebaseInitialized => _isFirebaseInitialized;

  // StreamControllers for in-memory / offline reactive state
  final _deviceController = StreamController<List<DeviceModel>>.broadcast();
  final _saleController = StreamController<List<SaleModel>>.broadcast();
  final _expenseController = StreamController<List<ExpenseModel>>.broadcast();
  final _supplierController = StreamController<List<SupplierModel>>.broadcast();
  final _paymentController =
      StreamController<List<SupplierPaymentModel>>.broadcast();

  // Local in-memory caches
  List<DeviceModel> _localDevices = [];
  List<SaleModel> _localSales = [];
  List<ExpenseModel> _localExpenses = [];
  List<SupplierModel> _localSuppliers = [];
  List<SupplierPaymentModel> _localPayments = [];

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      _isFirebaseInitialized = true;
      debugPrint("Firebase initialized successfully.");
    } catch (e) {
      _isFirebaseInitialized = false;
      debugPrint("Running in Offline/Demo Mode (Firebase initialization note: $e)");
    }

    _seedDemoData();
    _broadcastAll();
  }

  void _seedDemoData() {
    final now = DateTime.now();

    // 1. Initial Suppliers
    _localSuppliers = [
      SupplierModel(
        id: 'sup-1',
        name: 'Tariq Electronics',
        phone: '+92 300 1234567',
        companyName: 'Tariq Wholesale Mobiles',
        address: 'Hafeez Centre, Lahore',
        totalBilled: 750000.0,
        totalPaid: 600000.0, // Remaining balance 150,000
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      SupplierModel(
        id: 'sup-2',
        name: 'Farhan Traders',
        phone: '+92 321 9876543',
        companyName: 'Global Mobile Distributors',
        address: 'Star City Mall, Karachi',
        totalBilled: 1200000.0,
        totalPaid: 1100000.0, // Remaining balance 100,000
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      SupplierModel(
        id: 'sup-3',
        name: 'Usman Ali Parts & Phones',
        phone: '+92 333 5554433',
        companyName: 'Al-Madina Telecom',
        address: 'Saddar, Rawalpindi',
        totalBilled: 420000.0,
        totalPaid: 420000.0, // Fully paid
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ];

    // 2. Initial Devices
    _localDevices = [
      DeviceModel(
        id: 'dev-1',
        brand: 'Apple',
        model: 'iPhone 15 Pro Max',
        storage: '256GB',
        ram: '8GB',
        color: 'Natural Titanium',
        condition: 'New',
        imei1: '358941108492019',
        imei2: '358941108492027',
        purchasePrice: 410000.0,
        sellingPrice: 445000.0,
        status: 'in_stock',
        supplierId: 'sup-1',
        supplierName: 'Tariq Wholesale Mobiles',
        dateAdded: now.subtract(const Duration(days: 4)),
      ),
      DeviceModel(
        id: 'dev-2',
        brand: 'Samsung',
        model: 'Galaxy S24 Ultra',
        storage: '512GB',
        ram: '12GB',
        color: 'Titanium Black',
        condition: 'New',
        imei1: '359920194827103',
        imei2: '359920194827111',
        purchasePrice: 360000.0,
        sellingPrice: 395000.0,
        status: 'in_stock',
        supplierId: 'sup-2',
        supplierName: 'Global Mobile Distributors',
        dateAdded: now.subtract(const Duration(days: 5)),
      ),
      DeviceModel(
        id: 'dev-3',
        brand: 'Apple',
        model: 'iPhone 13',
        storage: '128GB',
        ram: '4GB',
        color: 'Midnight Blue',
        condition: 'Used',
        imei1: '354819203847291',
        purchasePrice: 135000.0,
        sellingPrice: 152000.0,
        status: 'in_stock',
        supplierId: 'sup-1',
        supplierName: 'Tariq Wholesale Mobiles',
        dateAdded: now.subtract(const Duration(days: 7)),
      ),
      DeviceModel(
        id: 'dev-4',
        brand: 'Xiaomi',
        model: 'Redmi Note 13 Pro',
        storage: '256GB',
        ram: '8GB',
        color: 'Aurora Green',
        condition: 'New',
        imei1: '869201847201948',
        imei2: '869201847201955',
        purchasePrice: 62000.0,
        sellingPrice: 70000.0,
        status: 'in_stock',
        supplierId: 'sup-3',
        supplierName: 'Al-Madina Telecom',
        dateAdded: now.subtract(const Duration(days: 2)),
      ),
      DeviceModel(
        id: 'dev-5',
        brand: 'OnePlus',
        model: 'OnePlus 12',
        storage: '256GB',
        ram: '16GB',
        color: 'Emerald Green',
        condition: 'New',
        imei1: '864810293847192',
        purchasePrice: 195000.0,
        sellingPrice: 220000.0,
        status: 'sold',
        supplierId: 'sup-2',
        supplierName: 'Global Mobile Distributors',
        dateAdded: now.subtract(const Duration(days: 10)),
      ),
    ];

    // 3. Initial Sales
    _localSales = [
      SaleModel(
        id: 'sale-1',
        invoiceNumber: 'INV-1001',
        deviceId: 'dev-5',
        deviceBrand: 'OnePlus',
        deviceModel: 'OnePlus 12',
        deviceStorage: '256GB',
        imei1: '864810293847192',
        purchasePrice: 195000.0,
        sellingPrice: 220000.0,
        discount: 3000.0,
        finalPrice: 217000.0,
        profit: 22000.0, // 217,000 - 195,000
        customerName: 'Muhammad Hamza',
        customerPhone: '+92 301 4455667',
        paymentMethod: 'Cash',
        saleDate: now.subtract(const Duration(days: 1)),
      ),
      SaleModel(
        id: 'sale-2',
        invoiceNumber: 'INV-1002',
        deviceId: 'dev-prev-1',
        deviceBrand: 'Samsung',
        deviceModel: 'Galaxy A54 5G',
        deviceStorage: '128GB',
        imei1: '351982039485721',
        purchasePrice: 78000.0,
        sellingPrice: 89000.0,
        discount: 1000.0,
        finalPrice: 88000.0,
        profit: 10000.0, // 88,000 - 78,000
        customerName: 'Zubair Ahmed',
        customerPhone: '+92 345 8899112',
        paymentMethod: 'Bank Transfer',
        saleDate: now.subtract(const Duration(days: 3)),
      ),
    ];

    // 4. Initial Expenses
    _localExpenses = [
      ExpenseModel(
        id: 'exp-1',
        title: 'Shop Monthly Rent',
        category: 'Shop Rent',
        amount: 35000.0,
        date: now.subtract(const Duration(days: 10)),
        paymentMethod: 'Bank Transfer',
        notes: 'Paid to Hafeez Centre Plaza Management',
      ),
      ExpenseModel(
        id: 'exp-2',
        title: 'Electricity & UPS Bill',
        category: 'Electricity & Bills',
        amount: 8500.0,
        date: now.subtract(const Duration(days: 6)),
        paymentMethod: 'Cash',
      ),
      ExpenseModel(
        id: 'exp-3',
        title: 'Sales Staff Weekly Allowance',
        category: 'Staff Salaries',
        amount: 15000.0,
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'Cash',
      ),
      ExpenseModel(
        id: 'exp-4',
        title: 'Daily Tea & Customer Refreshments',
        category: 'Tea & Refreshments',
        amount: 2400.0,
        date: now.subtract(const Duration(days: 1)),
        paymentMethod: 'Cash',
      ),
    ];

    // 5. Initial Supplier Payments
    _localPayments = [
      SupplierPaymentModel(
        id: 'pay-1',
        supplierId: 'sup-1',
        supplierName: 'Tariq Wholesale Mobiles',
        amount: 150000.0,
        date: now.subtract(const Duration(days: 8)),
        paymentMethod: 'Bank Transfer',
        referenceNumber: 'TXN-948201',
        notes: 'Partial settlement for iPhone shipment',
      ),
      SupplierPaymentModel(
        id: 'pay-2',
        supplierId: 'sup-2',
        supplierName: 'Global Mobile Distributors',
        amount: 200000.0,
        date: now.subtract(const Duration(days: 12)),
        paymentMethod: 'Bank Transfer',
        referenceNumber: 'HBL-0049281',
      ),
    ];
  }

  void _broadcastAll() {
    _deviceController.add(List.unmodifiable(_localDevices));
    _saleController.add(List.unmodifiable(_localSales));
    _expenseController.add(List.unmodifiable(_localExpenses));
    _supplierController.add(List.unmodifiable(_localSuppliers));
    _paymentController.add(List.unmodifiable(_localPayments));
  }

  // ==================== DEVICES ====================

  Stream<List<DeviceModel>> getDevicesStream() {
    if (_isFirebaseInitialized && _firestore != null) {
      return _firestore!
          .collection('devices')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => DeviceModel.fromMap(doc.data(), docId: doc.id))
              .toList())
          .handleError((e) {
        debugPrint("Firestore stream error (devices): $e, falling back to local");
        return _localDevices;
      });
    }
    return _deviceController.stream;
  }

  Future<void> addDevice(DeviceModel device) async {
    _localDevices.insert(0, device);

    // If device was purchased from supplier, increment supplier billed amount
    if (device.supplierId != null && device.supplierId!.isNotEmpty) {
      final supIndex =
          _localSuppliers.indexWhere((s) => s.id == device.supplierId);
      if (supIndex != -1) {
        final currentSup = _localSuppliers[supIndex];
        _localSuppliers[supIndex] = currentSup.copyWith(
          totalBilled: currentSup.totalBilled + device.purchasePrice,
        );
      }
    }

    _broadcastAll();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        await _firestore!.collection('devices').doc(device.id).set(device.toMap());
        if (device.supplierId != null && device.supplierId!.isNotEmpty) {
          await _firestore!
              .collection('suppliers')
              .doc(device.supplierId)
              .update({
            'totalBilled': FieldValue.increment(device.purchasePrice),
          });
        }
      } catch (e) {
        debugPrint("Error writing device to Firestore: $e");
      }
    }
  }

  Future<void> updateDevice(DeviceModel device) async {
    final index = _localDevices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      _localDevices[index] = device;
      _broadcastAll();
    }

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        await _firestore!
            .collection('devices')
            .doc(device.id)
            .update(device.toMap());
      } catch (e) {
        debugPrint("Error updating device in Firestore: $e");
      }
    }
  }

  Future<void> deleteDevice(String id) async {
    _localDevices.removeWhere((d) => d.id == id);
    _broadcastAll();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        await _firestore!.collection('devices').doc(id).delete();
      } catch (e) {
        debugPrint("Error deleting device from Firestore: $e");
      }
    }
  }

  // ==================== SALES (POS) ====================

  Stream<List<SaleModel>> getSalesStream() {
    if (_isFirebaseInitialized && _firestore != null) {
      return _firestore!
          .collection('sales')
          .orderBy('saleDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => SaleModel.fromMap(doc.data(), docId: doc.id))
              .toList())
          .handleError((e) {
        debugPrint("Firestore stream error (sales): $e, using local");
        return _localSales;
      });
    }
    return _saleController.stream;
  }

  Future<void> recordSale(SaleModel sale) async {
    _localSales.insert(0, sale);

    // Update device status to 'sold'
    final devIndex = _localDevices.indexWhere((d) => d.id == sale.deviceId);
    if (devIndex != -1) {
      _localDevices[devIndex] =
          _localDevices[devIndex].copyWith(status: 'sold');
    }

    _broadcastAll();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final batch = _firestore!.batch();
        final saleRef = _firestore!.collection('sales').doc(sale.id);
        final devRef = _firestore!.collection('devices').doc(sale.deviceId);

        batch.set(saleRef, sale.toMap());
        batch.update(devRef, {'status': 'sold'});
        await batch.commit();
      } catch (e) {
        debugPrint("Error committing sale to Firestore: $e");
      }
    }
  }

  // ==================== EXPENSES ====================

  Stream<List<ExpenseModel>> getExpensesStream() {
    if (_isFirebaseInitialized && _firestore != null) {
      return _firestore!
          .collection('expenses')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
              .toList())
          .handleError((e) {
        debugPrint("Firestore stream error (expenses): $e, using local");
        return _localExpenses;
      });
    }
    return _expenseController.stream;
  }

  Future<void> addExpense(ExpenseModel expense) async {
    _localExpenses.insert(0, expense);
    _broadcastAll();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        await _firestore!
            .collection('expenses')
            .doc(expense.id)
            .set(expense.toMap());
      } catch (e) {
        debugPrint("Error adding expense to Firestore: $e");
      }
    }
  }

  Future<void> deleteExpense(String id) async {
    _localExpenses.removeWhere((e) => e.id == id);
    _broadcastAll();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        await _firestore!.collection('expenses').doc(id).delete();
      } catch (e) {
        debugPrint("Error deleting expense from Firestore: $e");
      }
    }
  }

  // ==================== SUPPLIERS & PAYABLES ====================

  Stream<List<SupplierModel>> getSuppliersStream() {
    if (_isFirebaseInitialized && _firestore != null) {
      return _firestore!
          .collection('suppliers')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => SupplierModel.fromMap(doc.data(), docId: doc.id))
              .toList())
          .handleError((e) {
        debugPrint("Firestore stream error (suppliers): $e, using local");
        return _localSuppliers;
      });
    }
    return _supplierController.stream;
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    _localSuppliers.insert(0, supplier);
    _broadcastAll();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        await _firestore!
            .collection('suppliers')
            .doc(supplier.id)
            .set(supplier.toMap());
      } catch (e) {
        debugPrint("Error adding supplier to Firestore: $e");
      }
    }
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    final index = _localSuppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      _localSuppliers[index] = supplier;
      _broadcastAll();
    }

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        await _firestore!
            .collection('suppliers')
            .doc(supplier.id)
            .update(supplier.toMap());
      } catch (e) {
        debugPrint("Error updating supplier in Firestore: $e");
      }
    }
  }

  // Record Payment to Supplier (Khata hisaab)
  Stream<List<SupplierPaymentModel>> getSupplierPaymentsStream() {
    if (_isFirebaseInitialized && _firestore != null) {
      return _firestore!
          .collection('supplier_payments')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  SupplierPaymentModel.fromMap(doc.data(), docId: doc.id))
              .toList())
          .handleError((e) {
        debugPrint("Firestore stream error (payments): $e, using local");
        return _localPayments;
      });
    }
    return _paymentController.stream;
  }

  Future<void> recordSupplierPayment(SupplierPaymentModel payment) async {
    _localPayments.insert(0, payment);

    // Update supplier total paid amount
    final supIndex =
        _localSuppliers.indexWhere((s) => s.id == payment.supplierId);
    if (supIndex != -1) {
      final sup = _localSuppliers[supIndex];
      _localSuppliers[supIndex] = sup.copyWith(
        totalPaid: sup.totalPaid + payment.amount,
      );
    }

    _broadcastAll();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final batch = _firestore!.batch();
        final paymentRef =
            _firestore!.collection('supplier_payments').doc(payment.id);
        final supRef =
            _firestore!.collection('suppliers').doc(payment.supplierId);

        batch.set(paymentRef, payment.toMap());
        batch.update(supRef, {
          'totalPaid': FieldValue.increment(payment.amount),
        });

        await batch.commit();
      } catch (e) {
        debugPrint("Error recording supplier payment in Firestore: $e");
      }
    }
  }
}
