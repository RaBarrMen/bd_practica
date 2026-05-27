import '../database/database_helper.dart';

class DatabaseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getSales() {
    return _dbHelper.query('sales', orderBy: 'sale_date DESC');
  }

  Future<List<Map<String, dynamic>>> getSaleDetails(int saleId) {
    return _dbHelper.query(
      'sale_details',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
  }

  Future<int> createSale(Map<String, dynamic> values) {
    return _dbHelper.insert('sales', values);
  }

  Future<int> updateSale(
    int saleId,
    Map<String, dynamic> values,
  ) {
    return _dbHelper.update(
      'sales',
      values,
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }

  Future<int> deleteSale(int saleId) {
    return _dbHelper.delete('sales', where: 'id = ?', whereArgs: [saleId]);
  }

  Future<int> createSaleDetail(Map<String, dynamic> values) {
    return _dbHelper.insert('sale_details', values);
  }

  Future<int> deleteSaleDetail(int detailId) {
    return _dbHelper.delete(
      'sale_details',
      where: 'id = ?',
      whereArgs: [detailId],
    );
  }
}
