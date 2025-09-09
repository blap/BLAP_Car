# Database Schema Documentation

## Overview
The BLAP Car application uses SQLite for local data storage. The database schema is designed to support all features of the vehicle fleet management system.

## Tables

### 1. vehicles
Stores information about vehicles in the fleet.

```sql
CREATE TABLE vehicles (
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
```

**Fields:**
- `id`: Primary key
- `name`: Vehicle name (required)
- `make`: Vehicle manufacturer
- `model`: Vehicle model
- `year`: Manufacturing year
- `plate`: License plate number
- `fuel_tank_volume`: Fuel tank capacity in liters
- `vin`: Vehicle Identification Number
- `renavam`: Brazilian vehicle registration number
- `initial_odometer`: Initial odometer reading
- `created_at`: Creation timestamp

### 2. refueling
Stores refueling records for vehicles.

```sql
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
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
)
```

**Fields:**
- `id`: Primary key
- `vehicle_id`: Foreign key to vehicles table
- `date`: Refueling date
- `time`: Refueling time
- `odometer`: Odometer reading
- `liters`: Quantity of fuel
- `price_per_liter`: Price per liter
- `total_cost`: Total cost
- `fuel_type`: Type of fuel
- `station`: Gas station name
- `full_tank`: Whether tank was filled completely (1 = true, 0 = false)
- `previous_refueling_missing`: Whether previous refueling record is missing (1 = true, 0 = false)
- `driver`: Driver name
- `payment_method`: Payment method used
- `observation`: Additional notes
- `attachment_path`: Path to attached documents/photos

### 3. expenses
Stores expense records for vehicles.

```sql
CREATE TABLE expenses (
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
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
)
```

**Fields:**
- `id`: Primary key
- `vehicle_id`: Foreign key to vehicles table
- `type`: Expense type
- `description`: Expense description
- `cost`: Expense amount
- `date`: Expense date
- `time`: Expense time
- `odometer`: Odometer reading
- `location`: Location where expense occurred
- `driver`: Driver name
- `payment_method`: Payment method used
- `observation`: Additional notes
- `attachment_path`: Path to attached documents/photos
- `category`: Expense category
- `FOREIGN KEY`: Links to vehicles table

### 4. maintenance
Stores maintenance records for vehicles.

```sql
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
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
)
```

**Fields:**
- `id`: Primary key
- `vehicle_id`: Foreign key to vehicles table
- `type`: Maintenance type
- `description`: Maintenance description
- `cost`: Maintenance cost
- `date`: Maintenance date
- `next_date`: Next maintenance date
- `odometer`: Odometer reading
- `status`: Maintenance status
- `FOREIGN KEY`: Links to vehicles table

### 5. expense_reminders
Stores expense reminders for vehicles.

```sql
CREATE TABLE expense_reminders (
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
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
)
```

**Fields:**
- `id`: Primary key
- `vehicle_id`: Foreign key to vehicles table
- `expense_type`: Type of expense to remind
- `is_recurring`: Whether reminder is recurring (1 = true, 0 = false)
- `trigger_km_enabled`: Whether odometer trigger is enabled (1 = true, 0 = false)
- `trigger_km`: Odometer trigger value
- `trigger_date_enabled`: Whether date trigger is enabled (1 = true, 0 = false)
- `trigger_date`: Date trigger value
- `recurring_km_enabled`: Whether recurring by km is enabled (1 = true, 0 = false)
- `recurring_km_interval`: Recurring km interval
- `recurring_time_enabled`: Whether recurring by time is enabled (1 = true, 0 = false)
- `recurring_days_interval`: Recurring days interval
- `recurring_months_interval`: Recurring months interval
- `recurring_years_interval`: Recurring years interval
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp
- `FOREIGN KEY`: Links to vehicles table

### 6. reminders
Stores general reminders for vehicles.

```sql
CREATE TABLE reminders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  type TEXT,
  description TEXT,
  date TEXT,
  completed INTEGER,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
)
```

**Fields:**
- `id`: Primary key
- `vehicle_id`: Foreign key to vehicles table
- `type`: Reminder type
- `description`: Reminder description
- `date`: Reminder date
- `completed`: Whether reminder is completed (1 = true, 0 = false)
- `FOREIGN KEY`: Links to vehicles table

### 7. drivers
Stores information about drivers.

```sql
CREATE TABLE drivers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  license_number TEXT,
  license_expiry_date TEXT,
  contact_info TEXT,
  created_at TEXT NOT NULL
)
```

**Fields:**
- `id`: Primary key
- `name`: Driver name (required)
- `license_number`: Driver's license number
- `license_expiry_date`: License expiration date
- `contact_info`: Contact information
- `created_at`: Creation timestamp

### 8. checklist
Stores checklist templates.

```sql
CREATE TABLE checklist (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT
)
```

**Fields:**
- `id`: Primary key
- `name`: Checklist name (required)
- `description`: Checklist description
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### 9. checklist_item
Stores items within checklists.

```sql
CREATE TABLE checklist_item (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  checklist_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  is_required INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (checklist_id) REFERENCES checklist (id) ON DELETE CASCADE
)
```

**Fields:**
- `id`: Primary key
- `checklist_id`: Foreign key to checklist table
- `name`: Item name (required)
- `description`: Item description
- `is_required`: Whether item is required (1 = true, 0 = false)
- `created_at`: Creation timestamp
- `FOREIGN KEY`: Links to checklist table

### 10. checklist_completion
Stores checklist completion records.

```sql
CREATE TABLE checklist_completion (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  checklist_id INTEGER NOT NULL,
  vehicle_id INTEGER NOT NULL,
  completed_at TEXT NOT NULL,
  notes TEXT,
  FOREIGN KEY (checklist_id) REFERENCES checklist (id) ON DELETE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
)
```

**Fields:**
- `id`: Primary key
- `checklist_id`: Foreign key to checklist table
- `vehicle_id`: Foreign key to vehicles table
- `completed_at`: Completion timestamp
- `notes`: Additional notes
- `FOREIGN KEY`: Links to checklist and vehicles tables

### 11. checklist_item_completion
Stores completion status for individual checklist items.

```sql
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
```

**Fields:**
- `id`: Primary key
- `checklist_completion_id`: Foreign key to checklist_completion table
- `checklist_item_id`: Foreign key to checklist_item table
- `is_completed`: Whether item is completed (1 = true, 0 = false)
- `notes`: Additional notes
- `completed_at`: Completion timestamp
- `FOREIGN KEY`: Links to checklist_completion and checklist_item tables

## Relationships

The database schema implements the following relationships:

1. **One-to-Many**: Vehicles to Refueling records
2. **One-to-Many**: Vehicles to Expense records
3. **One-to-Many**: Vehicles to Maintenance records
4. **One-to-Many**: Vehicles to Expense Reminders
5. **One-to-Many**: Vehicles to General Reminders
6. **One-to-Many**: Checklists to Checklist Items
7. **One-to-Many**: Vehicles to Checklist Completions
8. **One-to-Many**: Checklist Completions to Checklist Item Completions

## Data Access

Data access is implemented through DAO (Data Access Object) classes:
- VehicleDao
- RefuelingDao
- ExpenseDao
- MaintenanceDao
- ExpenseReminderDao
- ReminderDao
- DriverDao
- ChecklistDao

Each DAO provides methods for CRUD operations on its respective table(s).

## Migrations

Database migrations are handled in the DatabaseHelper class. When the database version is updated, the onUpgrade method is called to apply necessary schema changes.