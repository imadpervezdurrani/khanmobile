class SupplierModel {
  final String id;
  final String name;
  final String phone;
  final String companyName;
  final String? address;
  final double totalBilled; // Total cost of inventory supplied
  final double totalPaid; // Total amount paid to supplier
  final DateTime createdAt;
  final String? notes;

  SupplierModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.companyName,
    this.address,
    this.totalBilled = 0.0,
    this.totalPaid = 0.0,
    required this.createdAt,
    this.notes,
  });

  // Outstanding Payable (Khata balance)
  double get balanceDue => totalBilled - totalPaid;
  bool get hasOutstandingPayable => balanceDue > 0.01;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'companyName': companyName,
      'address': address,
      'totalBilled': totalBilled,
      'totalPaid': totalPaid,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SupplierModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      companyName: map['companyName'] ?? '',
      address: map['address'],
      totalBilled: (map['totalBilled'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (map['totalPaid'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      notes: map['notes'],
    );
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? companyName,
    String? address,
    double? totalBilled,
    double? totalPaid,
    DateTime? createdAt,
    String? notes,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      totalBilled: totalBilled ?? this.totalBilled,
      totalPaid: totalPaid ?? this.totalPaid,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}
