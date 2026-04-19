class SaleDetail {
  final int id;
  final int saleId;
  final int productId;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final String? notes;
  final DateTime createdAt;

  SaleDetail({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.notes,
    required this.createdAt,
  });

  factory SaleDetail.fromMap(Map<String, dynamic> map) {
    return SaleDetail(
      id: map['id'] as int,
      saleId: map['sale_id'] as int,
      productId: map['product_id'] as int,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SaleDetail copyWith({
    int? id,
    int? saleId,
    int? productId,
    double? quantity,
    double? unitPrice,
    double? subtotal,
    String? notes,
    DateTime? createdAt,
  }) {
    return SaleDetail(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'SaleDetail(productId: $productId, quantity: $quantity, subtotal: $subtotal)';
}