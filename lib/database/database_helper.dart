import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ventas_servicios.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tablas
    await db.execute(DatabaseMigrations.createCategoriesTable);
    await db.execute(DatabaseMigrations.createProductsTable);
    await db.execute(DatabaseMigrations.createSalesTable);
    await db.execute(DatabaseMigrations.createSaleDetailsTable);
    await db.execute(DatabaseMigrations.createRemindersTable);

    // Crear índices
    final indexStatements = DatabaseMigrations.createIndexes.split(';');
    for (final statement in indexStatements) {
      if (statement.trim().isNotEmpty) {
        await db.execute(statement);
      }
    }

    // Insertar datos iniciales
    await db.execute(DatabaseMigrations.insertInitialCategories);
    await db.execute(DatabaseMigrations.insertInitialProducts);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Aquí irán las migraciones futuras
    // Por ahora dejamos vacío
  }

  // MÉTODOS GENÉRICOS
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<Map<String, dynamic>?> queryOne(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    final results = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Transacciones
  Future<T> transaction<T>(Future<T> Function(Transaction) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Cerrar base de datos
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }

  // Resetear base de datos (solo para desarrollo)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ventas_servicios.db');
    await deleteDatabase();
  }
}