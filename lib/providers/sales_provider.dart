import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/sale_detail.dart';
import '../services/database_service.dart';

class SalesProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Sale> _sales = [];
  List<Sale> _filteredSales = [];
  Map<int, List<SaleDetail>> _saleDetails = {};
  bool _isLoading = false;
  String? _error;
  SaleStatus? _filterStatus;

  // Getters
  List<Sale> get sales => _filteredSales.isEmpty ? _sales : _filteredSales;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SaleStatus? get filterStatus => _filterStatus;

  // Cargar todas las ventas
  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _databaseService.getSales();
      _sales = data.map((map) => Sale.fromMap(map)).toList();
      _filteredSales = [];
      
      // Cargar detalles de cada venta
      for (var sale in _sales) {
        await _loadSaleDetails(sale.id);
      }
    } catch (e) {
      _error = 'Error al cargar ventas: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar detalles de una venta específica
  Future<void> _loadSaleDetails(int saleId) async {
    try {
      final data = await _databaseService.getSaleDetails(saleId);
      _saleDetails[saleId] = data.map((map) => SaleDetail.fromMap(map)).toList();
    } catch (e) {
      print('Error al cargar detalles de venta: $e');
    }
  }

  // Obtener detalles de una venta
  List<SaleDetail> getSaleDetails(int saleId) {
    return _saleDetails[saleId] ?? [];
  }

  // Filtrar por estatus
  void filterByStatus(SaleStatus? status) {
    _filterStatus = status;
    
    if (status == null) {
      _filteredSales = [];
    } else {
      _filteredSales = _sales.where((sale) => sale.status == status).toList();
    }
    
    notifyListeners();
  }

  // Obtener ventas por fecha
  List<Sale> getSalesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _sales.where((sale) {
      return !sale.saleDate.isBefore(startOfDay) &&
          !sale.saleDate.isAfter(endOfDay);
    }).toList();
  }

  // Obtener venta por ID
  Sale? getSaleById(int id) {
    try {
      return _sales.firstWhere((sale) => sale.id == id);
    } catch (e) {
      return null;
    }
  }

  // Crear nueva venta
  Future<Sale?> createSale({
    required String clientName,
    required SaleType saleType,
    required DateTime saleDate,
    String? clientPhone,
    String? clientEmail,
    String? notes,
    double totalAmount = 0.0,
    SaleStatus initialStatus = SaleStatus.pending,
    bool reminderEnabled = true,
  }) async {
    try {
      final saleNumber = 'VENTA-${DateTime.now().millisecondsSinceEpoch}';
      
      final newSale = {
        'sale_number': saleNumber,
        'client_name': clientName,
        'client_phone': clientPhone,
        'client_email': clientEmail,
        'sale_type': saleType.toShortString(),
        'status': initialStatus.toShortString(),
        'total_amount': totalAmount,
        'notes': notes,
        'sale_date': saleDate.toIso8601String(),
        'completion_date': initialStatus == SaleStatus.completed
            ? DateTime.now().toIso8601String()
            : null,
        'reminder_enabled': reminderEnabled ? 1 : 0,
        'reminder_date': reminderEnabled 
            ? saleDate.subtract(const Duration(days: 2)).toIso8601String()
            : null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final saleId = await _databaseService.createSale(newSale);
      await loadSales();
      
      return getSaleById(saleId);
    } catch (e) {
      _error = 'Error al crear venta: $e';
      print(_error);
      notifyListeners();
      return null;
    }
  }

  // Agregar detalle a la venta
  Future<bool> addSaleDetail({
    required int saleId,
    required int productId,
    required double quantity,
    required double unitPrice,
  }) async {
    try {
      final subtotal = quantity * unitPrice;

      final detail = {
        'sale_id': saleId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'subtotal': subtotal,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _databaseService.createSaleDetail(detail);

      // Actualizar total de la venta
      await _updateSaleTotal(saleId);
      await _loadSaleDetails(saleId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar detalle: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Actualizar total de la venta
  Future<void> _updateSaleTotal(int saleId) async {
    try {
      final details = await _databaseService.getSaleDetails(saleId);

      double total = 0;
      for (var detail in details) {
        total += (detail['subtotal'] as num).toDouble();
      }

      await _databaseService.updateSale(
        saleId,
        {
          'total_amount': total,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error al actualizar total: $e');
    }
  }

  // Actualizar estatus de la venta
  Future<bool> updateSaleStatus(int saleId, SaleStatus newStatus) async {
    try {
      final completionDate = newStatus == SaleStatus.completed 
          ? DateTime.now()
          : null;

      await _databaseService.updateSale(
        saleId,
        {
          'status': newStatus.toShortString(),
          'completion_date': completionDate?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      await loadSales();
      return true;
    } catch (e) {
      _error = 'Error al actualizar estatus: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Eliminar detalle de venta
  Future<bool> removeSaleDetail(int detailId, int saleId) async {
    try {
      await _databaseService.deleteSaleDetail(detailId);

      await _updateSaleTotal(saleId);
      await _loadSaleDetails(saleId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar detalle: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Eliminar venta
  Future<bool> deleteSale(int saleId) async {
    try {
      await _databaseService.deleteSale(saleId);

      await loadSales();
      return true;
    } catch (e) {
      _error = 'Error al eliminar venta: $e';
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