class DeviceModel {
  final String id;
  final String brand;
  final String model;
  final String storage; // e.g. 128GB, 256GB
  final String ram; // e.g. 6GB, 8GB
  final String color;
  final String condition; // 'New' or 'Used'
  final String imei1;
  final String? imei2;
  final double purchasePrice;
  final double sellingPrice;
  final String status; // 'in_stock', 'sold'
  final String? supplierId;
  final String? supplierName;
  final DateTime dateAdded;
  final String? notes;

  DeviceModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.storage,
    required this.ram,
    required this.color,
    required this.condition,
    required this.imei1,
    this.imei2,
    required this.purchasePrice,
    required this.sellingPrice,
    this.status = 'in_stock',
    this.supplierId,
    this.supplierName,
    required this.dateAdded,
    this.notes,
  });

  double get potentialProfit => sellingPrice - purchasePrice;
  double get profitMarginPercent =>
      purchasePrice > 0 ? ((sellingPrice - purchasePrice) / purchasePrice) * 100 : 0.0;
  bool get isInStock => status == 'in_stock';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'storage': storage,
      'ram': ram,
      'color': color,
      'condition': condition,
      'imei1': imei1,
      'imei2': imei2,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'status': status,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'dateAdded': dateAdded.toIso8601String(),
      'notes': notes,
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return DeviceModel(
      id: docId ?? map['id'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      storage: map['storage'] ?? '',
      ram: map['ram'] ?? '',
      color: map['color'] ?? '',
      condition: map['condition'] ?? 'New',
      imei1: map['imei1'] ?? '',
      imei2: map['imei2'],
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'in_stock',
      supplierId: map['supplierId'],
      supplierName: map['supplierName'],
      dateAdded: map['dateAdded'] != null
          ? DateTime.tryParse(map['dateAdded']) ?? DateTime.now()
          : DateTime.now(),
      notes: map['notes'],
    );
  }

  DeviceModel copyWith({
    String? id,
    String? brand,
    String? model,
    String? storage,
    String? ram,
    String? color,
    String? condition,
    String? imei1,
    String? imei2,
    double? purchasePrice,
    double? sellingPrice,
    String? status,
    String? supplierId,
    String? supplierName,
    DateTime? dateAdded,
    String? notes,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      storage: storage ?? this.storage,
      ram: ram ?? this.ram,
      color: color ?? this.color,
      condition: condition ?? this.condition,
      imei1: imei1 ?? this.imei1,
      imei2: imei2 ?? this.imei2,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      status: status ?? this.status,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      dateAdded: dateAdded ?? this.dateAdded,
      notes: notes ?? this.notes,
    );
  }
}
