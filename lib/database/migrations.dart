class DatabaseMigrations {
  // Tabla de Categorías
  static const String createCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      description TEXT,
      icon TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // Tabla de Productos
  static const String createProductsTable = '''
    CREATE TABLE IF NOT EXISTS products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      price REAL NOT NULL,
      stock INTEGER NOT NULL DEFAULT 0,
      unit TEXT,
      image_url TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
    )
  ''';

  // Tabla de Ventas/Servicios
  static const String createSalesTable = '''
    CREATE TABLE IF NOT EXISTS sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_number TEXT NOT NULL UNIQUE,
      client_name TEXT NOT NULL,
      client_phone TEXT,
      client_email TEXT,
      sale_type TEXT NOT NULL CHECK(sale_type IN ('venta', 'servicio')),
      status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'completed', 'cancelled')),
      total_amount REAL NOT NULL,
      notes TEXT,
      sale_date DATETIME NOT NULL,
      completion_date DATETIME,
      reminder_enabled INTEGER DEFAULT 1,
      reminder_date DATETIME,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // Tabla de Detalles de Ventas
  static const String createSaleDetailsTable = '''
    CREATE TABLE IF NOT EXISTS sale_details (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      quantity REAL NOT NULL,
      unit_price REAL NOT NULL,
      subtotal REAL NOT NULL,
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
    )
  ''';

  // Tabla de Recordatorios
  static const String createRemindersTable = '''
    CREATE TABLE IF NOT EXISTS reminders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id INTEGER NOT NULL UNIQUE,
      reminder_date DATETIME NOT NULL,
      is_sent INTEGER DEFAULT 0,
      notification_id INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE
    )
  ''';

  // Índices para mejorar búsquedas
  static const String createIndexes = '''
    CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
    CREATE INDEX IF NOT EXISTS idx_sales_sale_date ON sales(sale_date);
    CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
    CREATE INDEX IF NOT EXISTS idx_sale_details_sale ON sale_details(sale_id);
    CREATE INDEX IF NOT EXISTS idx_reminders_reminder_date ON reminders(reminder_date);
  ''';

  // Datos iniciales - Categorías predefinidas
  static const String insertInitialCategories = '''
    INSERT OR IGNORE INTO categories (id, name, description, icon) VALUES
    (1, 'Electrónica', 'Productos electrónicos en general', '📱'),
    (2, 'Ropa', 'Prendas de vestir', '👕'),
    (3, 'Alimentos', 'Productos alimenticios', '🍎'),
    (4, 'Servicios', 'Servicios profesionales', '🔧'),
    (5, 'Muebles', 'Muebles y decoración', '🛋️');
  ''';

  // Datos iniciales - Productos de ejemplo
  static const String insertInitialProducts = '''
    INSERT OR IGNORE INTO products (id, category_id, name, description, price, stock, unit) VALUES
    (1, 1, 'Smartphone', 'Teléfono inteligente 128GB', 499.99, 10, 'pcs'),
    (2, 1, 'Laptop', 'Computadora portátil i7', 1299.99, 5, 'pcs'),
    (3, 2, 'Camiseta', 'Camiseta de algodón', 19.99, 50, 'pcs'),
    (4, 3, 'Café', 'Café premium 500g', 12.99, 100, 'bolsas'),
    (5, 4, 'Reparación', 'Reparación de computadora', 50.00, 0, 'servicio');
  ''';
}