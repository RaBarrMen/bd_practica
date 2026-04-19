enum SaleStatus { pending, completed, cancelled }
enum SaleType { venta, servicio }

extension SaleStatusExtension on SaleStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static SaleStatus fromString(String value) {
    return SaleStatus.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => SaleStatus.pending,
    );
  }
}

extension SaleTypeExtension on SaleType {
  String toShortString() {
    return toString().split('.').last;
  }

  static SaleType fromString(String value) {
    return SaleType.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => SaleType.venta,
    );
  }
}

class Sale {
  final int id;
  final String saleNumber;
  final String clientName;
  final String? clientPhone;
  final String? clientEmail;
  final SaleType saleType;
  final SaleStatus status;
  final double totalAmount;
  final String? notes;
  final DateTime saleDate;
  final DateTime? completionDate;
  final bool reminderEnabled;
  final DateTime? reminderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sale({
    required this.id,
    required this.saleNumber,
    required this.clientName,
    this.clientPhone,
    this.clientEmail,
    required this.saleType,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.saleDate,
    this.completionDate,
    this.reminderEnabled = true,
    this.reminderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int,
      saleNumber: map['sale_number'] as String,
      clientName: map['client_name'] as String,
      clientPhone: map['client_phone'] as String?,
      clientEmail: map['client_email'] as String?,
      saleType: SaleTypeExtension.fromString(map['sale_type'] as String),
      status: SaleStatusExtension.fromString(map['status'] as String),
      totalAmount: (map['total_amount'] as num).toDouble(),
      notes: map['notes'] as String?,
      saleDate: DateTime.parse(map['sale_date'] as String),
      completionDate: map['completion_date'] != null
          ? DateTime.parse(map['completion_date'] as String)
          : null,
      reminderEnabled: (map['reminder_enabled'] as int?) == 1,
      reminderDate: map['reminder_date'] != null
          ? DateTime.parse(map['reminder_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_number': saleNumber,
      'client_name': clientName,
      'client_phone': clientPhone,
      'client_email': clientEmail,
      'sale_type': saleType.toShortString(),
      'status': status.toShortString(),
      'total_amount': totalAmount,
      'notes': notes,
      'sale_date': saleDate.toIso8601String(),
      'completion_date': completionDate?.toIso8601String(),
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_date': reminderDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Sale copyWith({
    int? id,
    String? saleNumber,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    SaleType? saleType,
    SaleStatus? status,
    double? totalAmount,
    String? notes,
    DateTime? saleDate,
    DateTime? completionDate,
    bool? reminderEnabled,
    DateTime? reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sale(
      id: id ?? this.id,
      saleNumber: saleNumber ?? this.saleNumber,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      saleType: saleType ?? this.saleType,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      saleDate: saleDate ?? this.saleDate,
      completionDate: completionDate ?? this.completionDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Sale(id: $id, saleNumber: $saleNumber, client: $clientName, status: $status)';
}