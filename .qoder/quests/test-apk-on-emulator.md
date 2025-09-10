# APK Testing on Emulator - Design Document

## 1. Overview

This document outlines the process and requirements for testing the BLAP Car APK on an Android emulator. BLAP Car is a Flutter-based mobile application for vehicle fleet management that includes features for tracking vehicles, refueling, expenses, maintenance, reminders, reports, checklists, and data management.

## 2. Prerequisites

### 2.1 Software Requirements
- Android Studio with Android SDK
- Flutter SDK (version 3.9.0 or higher)
- Android Emulator (API level 21 or higher)
- Java Development Kit (JDK 11 or higher)

### 2.2 Hardware Requirements
- Minimum 8GB RAM (16GB recommended)
- At least 4GB free disk space
- Intel i5 processor or equivalent

### 2.3 Project Dependencies
The application requires the following Flutter packages:
- provider: ^6.1.2 (State management)
- sqflite: ^2.3.3 (Database)
- geolocator: ^14.0.2 (Location services)
- permission_handler: ^12.0.1 (Permissions)
- flutter_local_notifications: ^19.0.0 (Local notifications)
- mobile_scanner: ^7.0.1 (QR/Barcode scanning)
- And several other dependencies as defined in pubspec.yaml

## 3. Environment Setup

### 3.1 Android Emulator Configuration
1. Open Android Studio
2. Navigate to AVD Manager (Tools > AVD Manager)
3. Create a new Virtual Device with the following specifications:
   - Device: Pixel 4 or similar
   - Target: Android 12 (API Level 31) or higher
   - ABI: x86_64
   - RAM: 2GB
   - VM Heap: 256MB
   - Internal Storage: 2GB
   - SD Card: 512MB

### 3.2 Flutter Environment Setup
1. Ensure Flutter SDK is properly installed
2. Verify Flutter installation with `flutter doctor`
3. Configure Flutter to use Android Studio's Android SDK

## 4. APK Building Process

### 4.1 Generate Release APK
```bash
# Navigate to the project root directory
cd blap_car

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

The generated APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### 4.2 Generate Debug APK (Alternative)
```bash
# Build debug APK
flutter build apk --debug
```

## 5. APK Installation and Testing

### 5.1 Install APK on Emulator
1. Start the Android Emulator from AVD Manager
2. Drag and drop the APK file onto the emulator screen, OR
3. Use ADB command:
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

### 5.2 Manual Testing Procedure
1. Launch the BLAP Car application
2. Verify the main dashboard loads correctly
3. Test navigation between different modules:
   - Vehicle management
   - Refueling tracking
   - Expense tracking
   - Maintenance records
   - Reminders
   - Reports
   - Checklists
   - Data management
4. Verify database operations (create, read, update, delete)
5. Test location services functionality
6. Validate notification system
7. Check data persistence across app restarts

## 6. Automated Testing

### 6.1 Unit Tests
Run existing unit tests:
```bash
flutter test
```

### 6.2 Widget Tests
Run widget tests for UI components:
```bash
flutter test test/widget_test.dart
```

### 6.3 Integration Tests
Create and run integration tests for critical user flows:
```bash
flutter drive --target=test_driver/app.dart
```

## 7. Testing Checklist

### 7.1 Core Functionality
- [ ] Application launches without crashes
- [ ] Main dashboard displays correctly
- [ ] Navigation between modules works
- [ ] Data input and storage functions properly
- [ ] Reports generate correctly
- [ ] Notifications are triggered appropriately

### 7.2 Device Compatibility
- [ ] App functions on different screen sizes
- [ ] Orientation changes handled properly
- [ ] Back button behavior is correct
- [ ] Memory usage is within acceptable limits

### 7.3 Performance Testing
- [ ] App starts within 3 seconds
- [ ] Database operations complete within 1 second
- [ ] No memory leaks detected
- [ ] Battery consumption is reasonable

## 8. Troubleshooting

### 8.1 Common Issues
1. **APK installation fails**:
   - Ensure emulator is running Android API level 21 or higher
   - Check available storage space on emulator
   - Uninstall previous versions if conflicts occur

2. **App crashes on launch**:
   - Check logcat output for error messages
   - Verify all permissions are granted
   - Confirm database initialization

3. **Features not working**:
   - Check if required permissions are granted
   - Verify network connectivity for cloud-dependent features
   - Confirm proper configuration of external services

### 8.2 Diagnostic Commands
```bash
# View device logs
adb logcat

# Check connected devices
adb devices

# Uninstall app from emulator
adb uninstall com.blap.blapcar.blap_car
```

## 9. Test Reporting

### 9.1 Test Results Documentation
- Record all test cases executed
- Document any failures with steps to reproduce
- Capture screenshots for UI issues
- Log performance metrics

### 9.2 Bug Reporting
For any issues found:
1. Create detailed bug report with:
   - Steps to reproduce
   - Expected vs actual behavior
   - Device/emulator specifications
   - Screenshots or videos if applicable
   - Log files if available

## 10. Conclusion

This testing process ensures the BLAP Car APK functions correctly on Android emulators before deployment to physical devices or distribution. Following this structured approach will help identify and resolve issues early in the development cycle.