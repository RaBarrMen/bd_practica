import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class ProductsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  int? _selectedCategoryId;

  // Getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;

  // Cargar todos los productos
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _dbHelper.query('products', orderBy: 'name ASC');
      _products = data.map((map) => Product.fromMap(map)).toList();
      _filteredProducts = [];
    } catch (e) {
      _error = 'Error al cargar productos: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar productos por categoría
  Future<void> filterByCategory(int categoryId) async {
    _isLoading = true;
    _selectedCategoryId = categoryId;
    _error = null;
    notifyListeners();

    try {
      final data = await _dbHelper.query(
        'products',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'name ASC',
      );
      _filteredProducts = data.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      _error = 'Error al filtrar productos: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar filtro
  void clearFilter() {
    _filteredProducts = [];
    _selectedCategoryId = null;
    notifyListeners();
  }

  // Obtener producto por ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((prod) => prod.id == id);
    } catch (e) {
      return null;
    }
  }

  // Crear nuevo producto
  Future<bool> createProduct(
    int categoryId,
    String name,
    double price, {
    String? description,
    int stock = 0,
    String? unit,
    String? imageUrl,
  }) async {
    try {
      final newProduct = {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'unit': unit,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _dbHelper.insert('products', newProduct);
      await loadProducts();
      return true;
    } catch (e) {
      _error = 'Error al crear producto: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Actualizar producto
  Future<bool> updateProduct(
    int id,
    int categoryId,
    String name,
    double price, {
    String? description,
    int? stock,
    String? unit,
    String? imageUrl,
  }) async {
    try {
      final updates = {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'unit': unit,
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _dbHelper.update(
        'products',
        updates,
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadProducts();
      return true;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Eliminar producto
  Future<bool> deleteProduct(int id) async {
    try {
      // Verificar si tiene ventas asociadas
      final saleDetails = await _dbHelper.query(
        'sale_details',
        where: 'product_id = ?',
        whereArgs: [id],
      );

      if (saleDetails.isNotEmpty) {
        _error = 'No se puede eliminar el producto porque tiene ventas asociadas';
        notifyListeners();
        return false;
      }

      await _dbHelper.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadProducts();
      return true;
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}