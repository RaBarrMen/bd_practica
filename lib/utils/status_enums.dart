import 'package:flutter/material.dart';

enum SaleStatus { pending, completed, cancelled }

extension SaleStatusExtension on SaleStatus {
  String get label {
    switch (this) {
      case SaleStatus.pending:
        return 'En Proceso';
      case SaleStatus.completed:
        return 'Completado';
      case SaleStatus.cancelled:
        return 'Cancelado';
    }
  }

  String toShortString() {
    return toString().split('.').last;
  }

  Color get color {
    switch (this) {
      case SaleStatus.pending:
        return Colors.orange;
      case SaleStatus.completed:
        return Colors.green;
      case SaleStatus.cancelled:
        return Colors.red;
    }
  }

  Color get dotColor {
    switch (this) {
      case SaleStatus.pending:
        return Colors.green;
      case SaleStatus.completed:
        return Colors.white;
      case SaleStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case SaleStatus.pending:
        return Icons.schedule;
      case SaleStatus.completed:
        return Icons.check_circle;
      case SaleStatus.cancelled:
        return Icons.cancel;
    }
  }

  static SaleStatus fromString(String value) {
    return SaleStatus.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => SaleStatus.pending,
    );
  }
}

enum SaleType { venta, servicio }

extension SaleTypeExtension on SaleType {
  String get label {
    switch (this) {
      case SaleType.venta:
        return 'Venta';
      case SaleType.servicio:
        return 'Servicio';
    }
  }

  String toShortString() {
    return toString().split('.').last;
  }

  IconData get icon {
    switch (this) {
      case SaleType.venta:
        return Icons.shopping_bag;
      case SaleType.servicio:
        return Icons.handyman;
    }
  }

  static SaleType fromString(String value) {
    return SaleType.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => SaleType.venta,
    );
  }
}