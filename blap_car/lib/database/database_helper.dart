import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'blap_car.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create VEHICLE table
    await db.execute('''
      CREATE TABLE vehicle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        make TEXT,
        model TEXT,
        year INTEGER,
        plate TEXT,
        fuel_tank_volume REAL,
        vin TEXT,
        renavam TEXT,
        initial_odometer REAL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create REFUELING table
    await db.execute('''
      CREATE TABLE refueling (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT,
        odometer REAL NOT NULL,
        liters REAL,
        price_per_liter REAL,
        total_cost REAL,
        fuel_type TEXT,
        station TEXT,
        full_tank INTEGER,
        previous_refueling_missing INTEGER,
        driver TEXT,
        payment_method TEXT,
        observation TEXT,
        attachment_path TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
      )
    ''');

    // Create EXPENSE table
    await db.execute('''
      CREATE TABLE expense (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        type TEXT,
        description TEXT,
        cost REAL,
        date TEXT NOT NULL,
        time TEXT,
        odometer REAL,
        location TEXT,
        driver TEXT,
        payment_method TEXT,
        observation TEXT,
        attachment_path TEXT,
        category TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
      )
    ''');

    // Create EXPENSE_REMINDER table
    await db.execute('''
      CREATE TABLE expense_reminder (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        expense_type TEXT,
        is_recurring INTEGER,
        trigger_km_enabled INTEGER,
        trigger_km REAL,
        trigger_date_enabled INTEGER,
        trigger_date TEXT,
        recurring_km_enabled INTEGER,
        recurring_km_interval INTEGER,
        recurring_time_enabled INTEGER,
        recurring_days_interval INTEGER,
        recurring_months_interval INTEGER,
        recurring_years_interval INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
      )
    ''');

    // Create MAINTENANCE table
    await db.execute('''
      CREATE TABLE maintenance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        type TEXT,
        description TEXT,
        cost REAL,
        date TEXT,
        next_date TEXT,
        odometer INTEGER,
        status TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
      )
    ''');

    // Create REMINDER table
    await db.execute('''
      CREATE TABLE reminder (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        type TEXT,
        description TEXT,
        date TEXT,
        completed INTEGER,
        FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
      )
    ''');

    // Create DRIVER table
    await db.execute('''
      CREATE TABLE driver (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        license_number TEXT,
        license_expiry_date TEXT,
        contact_info TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create VEHICLE_DRIVER table for many-to-many relationship
    await db.execute('''
      CREATE TABLE vehicle_driver (
        vehicle_id INTEGER NOT NULL,
        driver_id INTEGER NOT NULL,
        PRIMARY KEY (vehicle_id, driver_id),
        FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE,
        FOREIGN KEY (driver_id) REFERENCES driver (id) ON DELETE CASCADE
      )
    ''');

    // Create CHECKLIST table
    await db.execute('''
      CREATE TABLE checklist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create CHECKLIST_ITEM table
    await db.execute('''
      CREATE TABLE checklist_item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        checklist_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        is_required INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (checklist_id) REFERENCES checklist (id) ON DELETE CASCADE
      )
    ''');

    // Create CHECKLIST_COMPLETION table
    await db.execute('''
      CREATE TABLE checklist_completion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        checklist_id INTEGER NOT NULL,
        vehicle_id INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (checklist_id) REFERENCES checklist (id) ON DELETE CASCADE,
        FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
      )
    ''');

    // Create CHECKLIST_ITEM_COMPLETION table
    await db.execute('''
      CREATE TABLE checklist_item_completion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        checklist_completion_id INTEGER NOT NULL,
        checklist_item_id INTEGER NOT NULL,
        is_completed INTEGER NOT NULL,
        notes TEXT,
        completed_at TEXT,
        FOREIGN KEY (checklist_completion_id) REFERENCES checklist_completion (id) ON DELETE CASCADE,
        FOREIGN KEY (checklist_item_id) REFERENCES checklist_item (id) ON DELETE CASCADE
      )
    ''');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}