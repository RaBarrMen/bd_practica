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

  // Getters
  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  // Agregar al carrito
  void addItem(Product product, double quantity) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        unitPrice: product.price,
      ));
    }

    notifyListeners();
  }

  // Actualizar cantidad
  void updateQuantity(int productId, double newQuantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
      }
      notifyListeners();
    }
  }

  // Eliminar del carrito
  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Limpiar carrito
  void clear() {
    _items = [];
    notifyListeners();
  }

  // Obtener item del carrito
  CartItem? getItem(int productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
}