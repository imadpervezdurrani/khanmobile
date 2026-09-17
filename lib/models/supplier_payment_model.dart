class SupplierPaymentModel {
  final String id;
  final String supplierId;
  final String supplierName;
  final double amount;
  final DateTime date;
  final String paymentMethod; // 'Cash', 'Bank Transfer', 'Cheque', 'Online'
  final String? referenceNumber;
  final String? notes;

  SupplierPaymentModel({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.amount,
    required this.date,
    this.paymentMethod = 'Cash',
    this.referenceNumber,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'amount': amount,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
      'notes': notes,
    };
  }

  factory SupplierPaymentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SupplierPaymentModel(
      id: docId ?? map['id'] ?? '',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      referenceNumber: map['referenceNumber'],
      notes: map['notes'],
    );
  }
}
