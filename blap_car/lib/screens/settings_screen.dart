import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blap_car/widgets/custom_app_bar.dart';
import 'package:blap_car/services/theme_service.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = false;
  String _currency = 'USD';
  String _language = 'English';
  bool _autoBackupEnabled = false;
  String _backupFrequency = 'Weekly';
  bool _remindersEnabled = true;
  String _distanceUnit = 'Kilometers';
  String _fuelUnit = 'Liters';
  bool _showFuelCosts = true;
  bool _showMaintenanceCosts = true;
  
  // Advanced notification preferences
  bool _fuelCostAlertsEnabled = true;
  bool _maintenanceDueAlertsEnabled = true;
  bool _expenseThresholdAlertsEnabled = true;
  String _notificationSound = 'Default';
  String _notificationPriority = 'Normal';
  
  // Advanced configuration options
  String _defaultExportFormat = 'Excel';
  String _chartVisualizationStyle = 'Line';
  bool _dataCompressionEnabled = false;
  bool _advancedReminderAlgorithmsEnabled = false;
  bool _autoDataCleanupEnabled = false;
  String _dataRetentionPeriod = 'Forever';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _locationEnabled = prefs.getBool('location_enabled') ?? false;
      _currency = prefs.getString('currency') ?? 'USD';
      _language = prefs.getString('language') ?? 'English';
      _autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? false;
      _backupFrequency = prefs.getString('backup_frequency') ?? 'Weekly';
      _remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
      _distanceUnit = prefs.getString('distance_unit') ?? 'Kilometers';
      _fuelUnit = prefs.getString('fuel_unit') ?? 'Liters';
      _showFuelCosts = prefs.getBool('show_fuel_costs') ?? true;
      _showMaintenanceCosts = prefs.getBool('show_maintenance_costs') ?? true;
      
      // Load advanced notification preferences
      _fuelCostAlertsEnabled = prefs.getBool('fuel_cost_alerts_enabled') ?? true;
      _maintenanceDueAlertsEnabled = prefs.getBool('maintenance_due_alerts_enabled') ?? true;
      _expenseThresholdAlertsEnabled = prefs.getBool('expense_threshold_alerts_enabled') ?? true;
      _notificationSound = prefs.getString('notification_sound') ?? 'Default';
      _notificationPriority = prefs.getString('notification_priority') ?? 'Normal';
      
      // Load advanced configuration options
      _defaultExportFormat = prefs.getString('default_export_format') ?? 'Excel';
      _chartVisualizationStyle = prefs.getString('chart_visualization_style') ?? 'Line';
      _dataCompressionEnabled = prefs.getBool('data_compression_enabled') ?? false;
      _advancedReminderAlgorithmsEnabled = prefs.getBool('advanced_reminder_algorithms_enabled') ?? false;
      _autoDataCleanupEnabled = prefs.getBool('auto_data_cleanup_enabled') ?? false;
      _dataRetentionPeriod = prefs.getString('data_retention_period') ?? 'Forever';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('location_enabled', _locationEnabled);
    await prefs.setString('currency', _currency);
    await prefs.setString('language', _language);
    await prefs.setBool('auto_backup_enabled', _autoBackupEnabled);
    await prefs.setString('backup_frequency', _backupFrequency);
    await prefs.setBool('reminders_enabled', _remindersEnabled);
    await prefs.setString('distance_unit', _distanceUnit);
    await prefs.setString('fuel_unit', _fuelUnit);
    await prefs.setBool('show_fuel_costs', _showFuelCosts);
    await prefs.setBool('show_maintenance_costs', _showMaintenanceCosts);
    
    // Save advanced notification preferences
    await prefs.setBool('fuel_cost_alerts_enabled', _fuelCostAlertsEnabled);
    await prefs.setBool('maintenance_due_alerts_enabled', _maintenanceDueAlertsEnabled);
    await prefs.setBool('expense_threshold_alerts_enabled', _expenseThresholdAlertsEnabled);
    await prefs.setString('notification_sound', _notificationSound);
    await prefs.setString('notification_priority', _notificationPriority);
    
    // Save advanced configuration options
    await prefs.setString('default_export_format', _defaultExportFormat);
    await prefs.setString('chart_visualization_style', _chartVisualizationStyle);
    await prefs.setBool('data_compression_enabled', _dataCompressionEnabled);
    await prefs.setBool('advanced_reminder_algorithms_enabled', _advancedReminderAlgorithmsEnabled);
    await prefs.setBool('auto_data_cleanup_enabled', _autoDataCleanupEnabled);
    await prefs.setString('data_retention_period', _dataRetentionPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Settings',
            onVehicleTap: () {
              // Navigate to vehicle selection
              Navigator.pushNamed(context, '/vehicles');
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // General Settings
                const Text(
                  'General',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Enable dark theme'),
                  value: themeService.darkModeEnabled,
                  onChanged: (value) {
                    themeService.toggleDarkMode(value);
                  },
                ),
                _buildDropdownListTile(
                  'Language',
                  _language,
                  ['English', 'Portuguese', 'Spanish'],
                  (value) {
                    setState(() {
                      _language = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildDropdownListTile(
                  'Currency',
                  _currency,
                  ['USD', 'EUR', 'GBP', 'BRL', 'CAD', 'AUD'],
                  (value) {
                    setState(() {
                      _currency = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildDropdownListTile(
                  'Distance Unit',
                  _distanceUnit,
                  ['Kilometers', 'Miles'],
                  (value) {
                    setState(() {
                      _distanceUnit = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildDropdownListTile(
                  'Fuel Unit',
                  _fuelUnit,
                  ['Liters', 'Gallons (US)', 'Gallons (UK)'],
                  (value) {
                    setState(() {
                      _fuelUnit = value;
                    });
                    _saveSettings();
                  },
                ),
                
                const Divider(height: 32),
                
                // Notifications
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSwitchListTile(
                  'Enable Notifications',
                  'Receive app notifications',
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchListTile(
                  'Enable Reminders',
                  'Receive maintenance reminders',
                  _remindersEnabled,
                  (value) {
                    setState(() {
                      _remindersEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                
                // Advanced Notification Preferences
                _buildSwitchListTile(
                  'Fuel Cost Alerts',
                  'Notify when fuel costs exceed average',
                  _fuelCostAlertsEnabled,
                  (value) {
                    setState(() {
                      _fuelCostAlertsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchListTile(
                  'Maintenance Due Alerts',
                  'Notify when maintenance is due',
                  _maintenanceDueAlertsEnabled,
                  (value) {
                    setState(() {
                      _maintenanceDueAlertsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchListTile(
                  'Expense Threshold Alerts',
                  'Notify when expenses exceed threshold',
                  _expenseThresholdAlertsEnabled,
                  (value) {
                    setState(() {
                      _expenseThresholdAlertsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildDropdownListTile(
                  'Notification Sound',
                  _notificationSound,
                  ['Default', 'Ringtone', 'Alarm', 'None'],
                  (value) {
                    setState(() {
                      _notificationSound = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildDropdownListTile(
                  'Notification Priority',
                  _notificationPriority,
                  ['Low', 'Normal', 'High'],
                  (value) {
                    setState(() {
                      _notificationPriority = value;
                    });
                    _saveSettings();
                  },
                ),
                
                const Divider(height: 32),
                
                // Privacy & Location
                const Text(
                  'Privacy & Location',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSwitchListTile(
                  'Location Services',
                  'Allow app to access location',
                  _locationEnabled,
                  (value) {
                    setState(() {
                      _locationEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                
                const Divider(height: 32),
                
                // Data & Backup
                const Text(
                  'Data & Backup',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSwitchListTile(
                  'Auto Backup',
                  'Automatically backup data',
                  _autoBackupEnabled,
                  (value) {
                    setState(() {
                      _autoBackupEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildDropdownListTile(
                  'Backup Frequency',
                  _backupFrequency,
                  ['Daily', 'Weekly', 'Monthly'],
                  (value) {
                    setState(() {
                      _backupFrequency = value;
                    });
                    _saveSettings();
                  },
                ),
                
                const Divider(height: 32),
                
                // Display Preferences
                const Text(
                  'Display Preferences',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSwitchListTile(
                  'Show Fuel Costs',
                  'Display fuel costs in reports',
                  _showFuelCosts,
                  (value) {
                    setState(() {
                      _showFuelCosts = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchListTile(
                  'Show Maintenance Costs',
                  'Display maintenance costs in reports',
                  _showMaintenanceCosts,
                  (value) {
                    setState(() {
                      _showMaintenanceCosts = value;
                    });
                    _saveSettings();
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Advanced Configuration
                const Text(
                  'Advanced Configuration',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDropdownListTile(
                  'Default Export Format',
                  _defaultExportFormat,
                  ['Excel', 'CSV', 'JSON'],
                  (value) {
                    setState(() {
                      _defaultExportFormat = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildDropdownListTile(
                  'Chart Visualization Style',
                  _chartVisualizationStyle,
                  ['Line', 'Bar', 'Area'],
                  (value) {
                    setState(() {
                      _chartVisualizationStyle = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchListTile(
                  'Enable Data Compression',
                  'Compress exported data files',
                  _dataCompressionEnabled,
                  (value) {
                    setState(() {
                      _dataCompressionEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchListTile(
                  'Advanced Reminder Algorithms',
                  'Use advanced prediction for reminders',
                  _advancedReminderAlgorithmsEnabled,
                  (value) {
                    setState(() {
                      _advancedReminderAlgorithmsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchListTile(
                  'Automatic Data Cleanup',
                  'Automatically remove old data',
                  _autoDataCleanupEnabled,
                  (value) {
                    setState(() {
                      _autoDataCleanupEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildDropdownListTile(
                  'Data Retention Period',
                  _dataRetentionPeriod,
                  ['30 days', '90 days', '1 year', 'Forever'],
                  (value) {
                    setState(() {
                      _dataRetentionPeriod = value;
                    });
                    _saveSettings();
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Export/Import Settings
                const Text(
                  'Export/Import',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Export Settings'),
                  subtitle: const Text('Export current configuration to a file'),
                  trailing: ElevatedButton(
                    onPressed: _exportSettings,
                    child: const Text('Export'),
                  ),
                ),
                ListTile(
                  title: const Text('Import Settings'),
                  subtitle: const Text('Import configuration from a file'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _importSettings(context);
                    },
                    child: const Text('Import'),
                  ),
                ),
                
                // Add Backup & Restore option
                ListTile(
                  title: const Text('Backup & Restore'),
                  subtitle: const Text('Create backups and restore data'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/backup');
                    },
                    child: const Text('Manage'),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Reset Settings
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      _resetSettings(context);
                    },
                    child: const Text('Reset to Default Settings'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchListTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownListTile(String title, String value, List<String> options, Function(String) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Future<void> _exportSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all settings
      final settings = {
        'notifications_enabled': prefs.getBool('notifications_enabled'),
        'location_enabled': prefs.getBool('location_enabled'),
        'dark_mode_enabled': prefs.getBool('dark_mode_enabled'),
        'currency': prefs.getString('currency'),
        'language': prefs.getString('language'),
        'auto_backup_enabled': prefs.getBool('auto_backup_enabled'),
        'backup_frequency': prefs.getString('backup_frequency'),
        'reminders_enabled': prefs.getBool('reminders_enabled'),
        'distance_unit': prefs.getString('distance_unit'),
        'fuel_unit': prefs.getString('fuel_unit'),
        'show_fuel_costs': prefs.getBool('show_fuel_costs'),
        'show_maintenance_costs': prefs.getBool('show_maintenance_costs'),
        // Advanced notification preferences
        'fuel_cost_alerts_enabled': prefs.getBool('fuel_cost_alerts_enabled'),
        'maintenance_due_alerts_enabled': prefs.getBool('maintenance_due_alerts_enabled'),
        'expense_threshold_alerts_enabled': prefs.getBool('expense_threshold_alerts_enabled'),
        'notification_sound': prefs.getString('notification_sound'),
        'notification_priority': prefs.getString('notification_priority'),
        // Advanced configuration options
        'default_export_format': prefs.getString('default_export_format'),
        'chart_visualization_style': prefs.getString('chart_visualization_style'),
        'data_compression_enabled': prefs.getBool('data_compression_enabled'),
        'advanced_reminder_algorithms_enabled': prefs.getBool('advanced_reminder_algorithms_enabled'),
        'auto_data_cleanup_enabled': prefs.getBool('auto_data_cleanup_enabled'),
        'data_retention_period': prefs.getString('data_retention_period'),
      };
      
      // Convert to JSON
      final jsonString = jsonEncode(settings);
      
      // Let user choose where to save the file
      final fileName = 'blap_car_settings_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save settings file:',
        fileName: fileName,
        allowedExtensions: ['json'],
        type: FileType.custom,
      );
      
      if (filePath == null) {
        // User canceled the save dialog
        return;
      }
      
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      // Check if widget is still mounted before using context
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings exported to $filePath')),
      );
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting settings: $e')),
      );
    }
  }

  Future<void> _importSettings(BuildContext context) async {
    try {
      // Pick a JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) {
        // User canceled the picker
        return;
      }
      
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final settings = jsonDecode(jsonString) as Map<String, dynamic>;

      // Apply settings
      final prefs = await SharedPreferences.getInstance();
      if (settings['notifications_enabled'] is bool) {
        await prefs.setBool('notifications_enabled', settings['notifications_enabled'] as bool);
      }
      if (settings['location_enabled'] is bool) {
        await prefs.setBool('location_enabled', settings['location_enabled'] as bool);
      }
      if (settings['dark_mode_enabled'] is bool) {
        await prefs.setBool('dark_mode_enabled', settings['dark_mode_enabled'] as bool);
        // Update theme service
        if (mounted) {
          // Check if widget is still mounted before using context
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          Provider.of<ThemeService>(context, listen: false)
              .toggleDarkMode(settings['dark_mode_enabled'] as bool);
        }
      }
      if (settings['currency'] is String) {
        await prefs.setString('currency', settings['currency'] as String);
      }
      if (settings['language'] is String) {
        await prefs.setString('language', settings['language'] as String);
      }
      if (settings['auto_backup_enabled'] is bool) {
        await prefs.setBool('auto_backup_enabled', settings['auto_backup_enabled'] as bool);
      }
      if (settings['backup_frequency'] is String) {
        await prefs.setString('backup_frequency', settings['backup_frequency'] as String);
      }
      if (settings['reminders_enabled'] is bool) {
        await prefs.setBool('reminders_enabled', settings['reminders_enabled'] as bool);
      }
      if (settings['distance_unit'] is String) {
        await prefs.setString('distance_unit', settings['distance_unit'] as String);
      }
      if (settings['fuel_unit'] is String) {
        await prefs.setString('fuel_unit', settings['fuel_unit'] as String);
      }
      if (settings['show_fuel_costs'] is bool) {
        await prefs.setBool('show_fuel_costs', settings['show_fuel_costs'] as bool);
      }
      if (settings['show_maintenance_costs'] is bool) {
        await prefs.setBool('show_maintenance_costs', settings['show_maintenance_costs'] as bool);
      }
      
      // Apply advanced notification preferences
      if (settings['fuel_cost_alerts_enabled'] is bool) {
        await prefs.setBool('fuel_cost_alerts_enabled', settings['fuel_cost_alerts_enabled'] as bool);
      }
      if (settings['maintenance_due_alerts_enabled'] is bool) {
        await prefs.setBool('maintenance_due_alerts_enabled', settings['maintenance_due_alerts_enabled'] as bool);
      }
      if (settings['expense_threshold_alerts_enabled'] is bool) {
        await prefs.setBool('expense_threshold_alerts_enabled', settings['expense_threshold_alerts_enabled'] as bool);
      }
      if (settings['notification_sound'] is String) {
        await prefs.setString('notification_sound', settings['notification_sound'] as String);
      }
      if (settings['notification_priority'] is String) {
        await prefs.setString('notification_priority', settings['notification_priority'] as String);
      }
      
      // Apply advanced configuration options
      if (settings['default_export_format'] is String) {
        await prefs.setString('default_export_format', settings['default_export_format'] as String);
      }
      if (settings['chart_visualization_style'] is String) {
        await prefs.setString('chart_visualization_style', settings['chart_visualization_style'] as String);
      }
      if (settings['data_compression_enabled'] is bool) {
        await prefs.setBool('data_compression_enabled', settings['data_compression_enabled'] as bool);
      }
      if (settings['advanced_reminder_algorithms_enabled'] is bool) {
        await prefs.setBool('advanced_reminder_algorithms_enabled', settings['advanced_reminder_algorithms_enabled'] as bool);
      }
      if (settings['auto_data_cleanup_enabled'] is bool) {
        await prefs.setBool('auto_data_cleanup_enabled', settings['auto_data_cleanup_enabled'] as bool);
      }
      if (settings['data_retention_period'] is String) {
        await prefs.setString('data_retention_period', settings['data_retention_period'] as String);
      }
      
      // Reload settings
      if (mounted) {
        await _loadSettings();
      }
      
      // Check if widget is still mounted before using context
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings imported successfully')),
      );
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing settings: $e')),
      );
    }
  }

  Future<void> _resetSettings(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Reload default settings
    if (mounted) {
      setState(() {
        _notificationsEnabled = true;
        _locationEnabled = false;
        _currency = 'USD';
        _language = 'English';
        _autoBackupEnabled = false;
        _backupFrequency = 'Weekly';
        _remindersEnabled = true;
        _distanceUnit = 'Kilometers';
        _fuelUnit = 'Liters';
        _showFuelCosts = true;
        _showMaintenanceCosts = true;
        
        // Reset advanced notification preferences
        _fuelCostAlertsEnabled = true;
        _maintenanceDueAlertsEnabled = true;
        _expenseThresholdAlertsEnabled = true;
        _notificationSound = 'Default';
        _notificationPriority = 'Normal';
        
        // Reset advanced configuration options
        _defaultExportFormat = 'Excel';
        _chartVisualizationStyle = 'Line';
        _dataCompressionEnabled = false;
        _advancedReminderAlgorithmsEnabled = false;
        _autoDataCleanupEnabled = false;
        _dataRetentionPeriod = 'Forever';
      });
    }
    
    // Reset dark mode
    if (mounted) {
      // Check if widget is still mounted before using context
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Provider.of<ThemeService>(context, listen: false).toggleDarkMode(false);
    }
    
    // Check if widget is still mounted before using context
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to default')),
    );
  }
}