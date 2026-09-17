import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/device_model.dart';
import '../services/firebase_service.dart';

class InventoryProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _subscription;

  List<DeviceModel> _devices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedBrand = 'All';
  String _selectedStatus = 'All'; // 'All', 'in_stock', 'sold'
  String _selectedCondition = 'All'; // 'All', 'New', 'Used'

  InventoryProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();

    _subscription = _firebaseService.getDevicesStream().listen((data) {
      _devices = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<DeviceModel> get allDevices => _devices;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedBrand => _selectedBrand;
  String get selectedStatus => _selectedStatus;
  String get selectedCondition => _selectedCondition;

  // Filtered devices based on search query, brand, condition, and status
  List<DeviceModel> get filteredDevices {
    return _devices.where((device) {
      final matchesSearch = _searchQuery.isEmpty ||
          device.model.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          device.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          device.imei1.contains(_searchQuery) ||
          (device.imei2?.contains(_searchQuery) ?? false);

      final matchesBrand =
          _selectedBrand == 'All' || device.brand == _selectedBrand;

      final matchesStatus =
          _selectedStatus == 'All' || device.status == _selectedStatus;

      final matchesCondition =
          _selectedCondition == 'All' || device.condition == _selectedCondition;

      return matchesSearch && matchesBrand && matchesStatus && matchesCondition;
    }).toList();
  }

  List<DeviceModel> get inStockDevices =>
      _devices.where((d) => d.isInStock).toList();

  List<String> get availableBrands {
    final brands = _devices.map((d) => d.brand).toSet().toList();
    brands.sort();
    return ['All', ...brands];
  }

  // Stock Analytics
  int get inStockCount => _devices.where((d) => d.isInStock).length;
  int get soldCount => _devices.where((d) => d.status == 'sold').length;

  double get totalStockCostValue => _devices
      .where((d) => d.isInStock)
      .fold(0.0, (sum, item) => sum + item.purchasePrice);

  double get totalStockRetailValue => _devices
      .where((d) => d.isInStock)
      .fold(0.0, (sum, item) => sum + item.sellingPrice);

  double get potentialStockProfit =>
      totalStockRetailValue - totalStockCostValue;

  // Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedBrand(String brand) {
    _selectedBrand = brand;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSelectedCondition(String condition) {
    _selectedCondition = condition;
    notifyListeners();
  }

  DeviceModel? findDeviceByImei(String imei) {
    final clean = imei.trim();
    try {
      return _devices.firstWhere(
        (d) => d.imei1 == clean || d.imei2 == clean,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> addDevice({
    required String brand,
    required String model,
    required String storage,
    required String ram,
    required String color,
    required String condition,
    required String imei1,
    String? imei2,
    required double purchasePrice,
    required double sellingPrice,
    String? supplierId,
    String? supplierName,
    String? notes,
  }) async {
    final newDevice = DeviceModel(
      id: const Uuid().v4(),
      brand: brand,
      model: model,
      storage: storage,
      ram: ram,
      color: color,
      condition: condition,
      imei1: imei1.trim(),
      imei2: imei2?.trim().isNotEmpty == true ? imei2!.trim() : null,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      status: 'in_stock',
      supplierId: supplierId,
      supplierName: supplierName,
      dateAdded: DateTime.now(),
      notes: notes,
    );

    await _firebaseService.addDevice(newDevice);
  }

  Future<void> updateDevice(DeviceModel device) async {
    await _firebaseService.updateDevice(device);
  }

  Future<void> deleteDevice(String id) async {
    await _firebaseService.deleteDevice(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
