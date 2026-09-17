class SaleModel {
  final String id;
  final String invoiceNumber;
  final String deviceId;
  final String deviceBrand;
  final String deviceModel;
  final String deviceStorage;
  final String imei1;
  final double purchasePrice; // Cost of goods sold (COGS)
  final double sellingPrice; // Regular price
  final double discount;
  final double finalPrice; // sellingPrice - discount (Actual Revenue)
  final double profit; // finalPrice - purchasePrice
  final String customerName;
  final String customerPhone;
  final String paymentMethod; // 'Cash', 'Card', 'Bank Transfer', 'Credit'
  final DateTime saleDate;
  final String? notes;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.deviceId,
    required this.deviceBrand,
    required this.deviceModel,
    required this.deviceStorage,
    required this.imei1,
    required this.purchasePrice,
    required this.sellingPrice,
    this.discount = 0.0,
    required this.finalPrice,
    required this.profit,
    required this.customerName,
    required this.customerPhone,
    required this.paymentMethod,
    required this.saleDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'deviceId': deviceId,
      'deviceBrand': deviceBrand,
      'deviceModel': deviceModel,
      'deviceStorage': deviceStorage,
      'imei1': imei1,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'discount': discount,
      'finalPrice': finalPrice,
      'profit': profit,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'saleDate': saleDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final purchase = (map['purchasePrice'] as num?)?.toDouble() ?? 0.0;
    final sell = (map['sellingPrice'] as num?)?.toDouble() ?? 0.0;
    final disc = (map['discount'] as num?)?.toDouble() ?? 0.0;
    final finalP = (map['finalPrice'] as num?)?.toDouble() ?? (sell - disc);
    final prof = (map['profit'] as num?)?.toDouble() ?? (finalP - purchase);

    return SaleModel(
      id: docId ?? map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      deviceId: map['deviceId'] ?? '',
      deviceBrand: map['deviceBrand'] ?? '',
      deviceModel: map['deviceModel'] ?? '',
      deviceStorage: map['deviceStorage'] ?? '',
      imei1: map['imei1'] ?? '',
      purchasePrice: purchase,
      sellingPrice: sell,
      discount: disc,
      finalPrice: finalP,
      profit: prof,
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      saleDate: map['saleDate'] != null
          ? DateTime.tryParse(map['saleDate']) ?? DateTime.now()
          : DateTime.now(),
      notes: map['notes'],
    );
  }
}
