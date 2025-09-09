# BLAP Car - Vehicle Fleet Management System

BLAP Car is a comprehensive vehicle fleet management application built with Flutter for Android. It provides features for tracking vehicles, refueling, expenses, maintenance, reminders, and more.

## Recent Improvements

- Fixed Android build issues with flutter_local_notifications by implementing core library desugaring
- Resolved static analysis warnings and dead code issues
- Improved logging practices by replacing print() statements with debugPrint()
- Fixed async BuildContext usage for better performance and reliability
- Cleaned up unused code and optimized existing implementations
- Fixed share_plus API usage by updating Share.shareFiles to Share.shareXFiles
- Removed deprecated parameters in DropdownButtonFormField widgets
- Made service fields final to improve code quality
- Fixed various compilation errors and warnings
- Enhanced code documentation and comments
- Updated dependencies to latest versions for better security and performance
- Fixed file sharing functionality with proper error handling
- Improved notification scheduling with timezone support

## Features

### 1. Vehicle Management
- Add, edit, and delete vehicles
- Store vehicle details (make, model, year, plate, VIN, etc.)
- Track initial odometer readings

### 2. Refueling Tracking
- Record refueling events with detailed information
- Track fuel type, quantity, cost, and station
- Calculate fuel efficiency metrics

### 3. Expense Management
- Track all vehicle-related expenses
- Categorize expenses (maintenance, fuel, insurance, etc.)
- Attach notes and observations

### 4. Maintenance Scheduling
- Schedule and track maintenance activities
- Set next maintenance dates
- Track maintenance status (scheduled, in progress, completed)

### 5. Expense Reminders
- Create recurring expense reminders
- Trigger by date or odometer readings
- Flexible recurrence options (daily, monthly, yearly, or by km)

### 6. Reporting and Analytics
- Generate detailed reports on vehicle performance
- View fuel efficiency statistics
- Analyze expense patterns

### 7. Data Management
- Export data to CSV and Excel formats
- Import data from external sources
- Backup and restore functionality

### 8. Checklist System
- Create customizable checklists for vehicle inspections
- Track checklist completions
- Associate checklists with specific vehicles

### 9. Android-Specific Features
- Native notifications for reminders
- File sharing capabilities
- Permission handling for storage and location

## Architecture

### Project Structure
```
lib/
├── database/          # SQLite database implementation
├── models/            # Data models for all entities
├── modules/           # Feature modules (vehicle, refueling, expense, etc.)
├── screens/           # Main screen components
├── services/          # Business logic services
├── utils/             # Utility functions and helpers
└── widgets/           # Reusable UI components
```

### State Management
The application uses the Provider package for state management, with each module having its own provider class that manages the state for that specific feature.

### Data Layer
- SQLite database for local storage
- DAO (Data Access Object) pattern for database operations
- Models with toMap/fromMap methods for serialization

## Testing

The application includes comprehensive tests:
- Unit tests for all data models
- Service tests for business logic
- Widget tests for UI components

To run tests:
```bash
flutter test
```

## Dependencies

Key dependencies include:
- provider: State management
- sqflite: SQLite database
- path: File path utilities
- excel: Excel file generation
- permission_handler: Android permission management
- flutter_local_notifications: Local notifications
- share_plus: File sharing
- geolocator: Location services
- charts_flutter: Data visualization
- flutter_svg: SVG rendering
- fl_chart: Charting library
- file_picker: File selection
- path_provider: Directory paths
- intl: Internationalization and date formatting
- csv: CSV file handling
- image_picker: Image selection
- mobile_scanner: QR/Barcode scanning
- shared_preferences: Simple data persistence
- timezone: Timezone data

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Testing

To run all tests:
```bash
flutter test
```

To run specific test files:
```bash
flutter test test/vehicle_test.dart
flutter test test/refueling_test.dart
# ... etc
```

## Code Organization

### Models
All data models are located in `lib/models/` and include:
- Vehicle
- Refueling
- Expense
- Maintenance
- ExpenseReminder
- Checklist (and related models)
- Driver
- Reminder

### Database
Database implementation is in `lib/database/` and includes:
- DatabaseHelper: Main database connection and setup
- DAO classes for each entity (VehicleDao, RefuelingDao, etc.)

### Services
Business logic services in `lib/services/`:
- VehicleService
- RefuelingService
- ExpenseService
- MaintenanceService
- ExpenseReminderService
- ChecklistService
- ReportingService
- DataManagementService

### Modules
Feature modules in `lib/modules/`:
- Each module has its own provider and screens
- Providers manage state for that module
- Screens handle UI presentation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.