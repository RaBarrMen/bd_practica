import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

class CategoriesProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar todas las categorías
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _dbHelper.query('categories', orderBy: 'name ASC');
      _categories = data.map((map) => Category.fromMap(map)).toList();
    } catch (e) {
      _error = 'Error al cargar categorías: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener categoría por ID
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Crear nueva categoría
  Future<bool> createCategory(String name, {String? description, String? icon}) async {
    try {
      final newCategory = {
        'name': name,
        'description': description,
        'icon': icon,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final id = await _dbHelper.insert('categories', newCategory);
      
      // Recargar categorías
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Error al crear categoría: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Actualizar categoría
  Future<bool> updateCategory(
    int id,
    String name, {
    String? description,
    String? icon,
  }) async {
    try {
      final updates = {
        'name': name,
        'description': description,
        'icon': icon,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _dbHelper.update(
        'categories',
        updates,
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Error al actualizar categoría: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Eliminar categoría (con validación de integridad referencial)
  Future<bool> deleteCategory(int id) async {
    try {
      // Verificar si tiene productos asociados
      final products = await _dbHelper.query(
        'products',
        where: 'category_id = ?',
        whereArgs: [id],
      );

      if (products.isNotEmpty) {
        _error = 'No se puede eliminar la categoría porque tiene productos asociados';
        notifyListeners();
        return false;
      }

      await _dbHelper.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Error al eliminar categoría: $e';
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