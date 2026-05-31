import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  double quantity;
  final double unitPrice;

  CartItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  CartItem copyWith({
    Product? product,
    double? quantity,
    double? unitPrice,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity.toInt());

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get total => totalPrice;

  void addItem(Product product, double quantity) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          unitPrice: product.price,
        ),
      );
    }

    notifyListeners();
  }

  void updateQuantity(int productId, double newQuantity) {
    final index = _items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(
          quantity: newQuantity,
        );
      }

      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _items.removeWhere(
      (item) => item.product.id == productId,
    );

    notifyListeners();
  }

  void clear() {
    _items = [];
    notifyListeners();
  }

  CartItem? getItem(int productId) {
    try {
      return _items.firstWhere(
        (item) => item.product.id == productId,
      );
    } catch (_) {
      return null;
    }
  }

  double getProductQuantity(int productId) {
    final item = getItem(productId);
    return item?.quantity ?? 0;
  }
}