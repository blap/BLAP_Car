import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/models/expense_reminder.dart';
import 'package:blap_car/modules/reminder/expense_reminder_provider.dart';

class ExpenseReminderListScreen extends StatelessWidget {
  final int vehicleId;

  const ExpenseReminderListScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddExpenseReminderScreen(vehicleId: vehicleId),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpenseReminderProvider>(
        builder: (context, reminderProvider, child) {
          // Load reminders when the screen is built
          if (reminderProvider.expenseReminders.isEmpty) {
            reminderProvider.loadExpenseReminders(vehicleId);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await reminderProvider.loadExpenseReminders(vehicleId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reminderProvider.expenseReminders.length,
              itemBuilder: (context, index) {
                final reminder = reminderProvider.expenseReminders[index];
                return Card(
                  child: ListTile(
                    title: Text(reminder.expenseType ?? 'Reminder'),
                    subtitle: Text(_buildReminderDescription(reminder)),
                    trailing: reminder.isRecurring == true
                        ? const Chip(label: Text('Recurring'))
                        : const Chip(label: Text('One-time')),
                    onTap: () {
                      // Navigate to reminder details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpenseReminderDetailsScreen(reminder: reminder),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _buildReminderDescription(ExpenseReminder reminder) {
    List<String> descriptions = [];

    if (reminder.triggerDateEnabled == true && reminder.triggerDate != null) {
      descriptions.add(
        'Date: ${reminder.triggerDate.toString().split(' ')[0]}',
      );
    }

    if (reminder.triggerKmEnabled == true && reminder.triggerKm != null) {
      descriptions.add('KM: ${reminder.triggerKm?.toStringAsFixed(0)}');
    }

    if (reminder.recurringTimeEnabled == true) {
      if (reminder.recurringDaysInterval != null &&
          reminder.recurringDaysInterval! > 0) {
        descriptions.add('Every ${reminder.recurringDaysInterval} days');
      }
      if (reminder.recurringMonthsInterval != null &&
          reminder.recurringMonthsInterval! > 0) {
        descriptions.add('Every ${reminder.recurringMonthsInterval} months');
      }
      if (reminder.recurringYearsInterval != null &&
          reminder.recurringYearsInterval! > 0) {
        descriptions.add('Every ${reminder.recurringYearsInterval} years');
      }
    }

    if (reminder.recurringKmEnabled == true &&
        reminder.recurringKmInterval != null) {
      descriptions.add('Every ${reminder.recurringKmInterval} km');
    }

    return descriptions.isEmpty ? 'No details' : descriptions.join(', ');
  }
}

class AddExpenseReminderScreen extends StatefulWidget {
  final int vehicleId;

  const AddExpenseReminderScreen({super.key, required this.vehicleId});

  @override
  State<AddExpenseReminderScreen> createState() =>
      _AddExpenseReminderScreenState();
}

class _AddExpenseReminderScreenState extends State<AddExpenseReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _triggerDateController = TextEditingController();
  final _triggerKmController = TextEditingController();
  final _recurringKmIntervalController = TextEditingController();
  final _recurringDaysIntervalController = TextEditingController();
  final _recurringMonthsIntervalController = TextEditingController();
  final _recurringYearsIntervalController = TextEditingController();

  String? _selectedExpenseType;
  bool _isRecurring = false;
  bool _triggerDateEnabled = false;
  bool _triggerKmEnabled = false;
  bool _recurringKmEnabled = false;
  bool _recurringTimeEnabled = false;

  final List<String> _expenseTypes = [
    'Repair/Maintenance',
    'Parking',
    'Financing',
    'Taxes (IPVA/DPVAT)',
    'Car Wash',
    'Licensing',
    'Traffic Fine',
    'Toll',
    'Review',
    'Insurance',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _triggerDateController.dispose();
    _triggerKmController.dispose();
    _recurringKmIntervalController.dispose();
    _recurringDaysIntervalController.dispose();
    _recurringMonthsIntervalController.dispose();
    _recurringYearsIntervalController.dispose();
    super.dispose();
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      // Validate that at least one trigger is selected
      if (!_triggerDateEnabled && !_triggerKmEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one trigger (date or km)'),
          ),
        );
        return;
      }

      // Validate that at least one recurring option is selected if recurring is enabled
      if (_isRecurring && !_recurringKmEnabled && !_recurringTimeEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select at least one recurring option (km or time)',
            ),
          ),
        );
        return;
      }

      final reminder = ExpenseReminder(
        vehicleId: widget.vehicleId,
        expenseType: _selectedExpenseType,
        isRecurring: _isRecurring,
        triggerDateEnabled: _triggerDateEnabled,
        triggerDate: _triggerDateController.text.isNotEmpty
            ? DateTime.parse(_triggerDateController.text)
            : null,
        triggerKmEnabled: _triggerKmEnabled,
        triggerKm: double.tryParse(_triggerKmController.text),
        recurringKmEnabled: _recurringKmEnabled,
        recurringKmInterval: int.tryParse(_recurringKmIntervalController.text),
        recurringTimeEnabled: _recurringTimeEnabled,
        recurringDaysInterval: int.tryParse(
          _recurringDaysIntervalController.text,
        ),
        recurringMonthsInterval: int.tryParse(
          _recurringMonthsIntervalController.text,
        ),
        recurringYearsInterval: int.tryParse(
          _recurringYearsIntervalController.text,
        ),
        createdAt: DateTime.now(),
      );

      Provider.of<ExpenseReminderProvider>(
        context,
        listen: false,
      ).addExpenseReminder(reminder);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense Reminder'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveReminder),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDropdownField(
                'Expense Type',
                _expenseTypes,
                _selectedExpenseType,
                (value) {
                  setState(() {
                    _selectedExpenseType = value;
                  });
                },
                required: true,
              ),

              const SizedBox(height: 16),
              _buildCheckboxField('Recurring Reminder', _isRecurring, (value) {
                setState(() {
                  _isRecurring = value ?? false;
                });
              }),

              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Trigger Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              _buildCheckboxField('Trigger by Date', _triggerDateEnabled, (
                value,
              ) {
                setState(() {
                  _triggerDateEnabled = value ?? false;
                });
              }),

              if (_triggerDateEnabled)
                _buildDateField(
                  _triggerDateController,
                  'Trigger Date',
                  'Select trigger date',
                ),

              _buildCheckboxField('Trigger by Kilometer', _triggerKmEnabled, (
                value,
              ) {
                setState(() {
                  _triggerKmEnabled = value ?? false;
                });
              }),

              if (_triggerKmEnabled)
                _buildTextField(
                  _triggerKmController,
                  'Trigger Kilometer',
                  'Enter trigger kilometer',
                  TextInputType.number,
                ),

              if (_isRecurring) ...[
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Recurring Options',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                _buildCheckboxField(
                  'Recurring by Kilometer',
                  _recurringKmEnabled,
                  (value) {
                    setState(() {
                      _recurringKmEnabled = value ?? false;
                    });
                  },
                ),

                if (_recurringKmEnabled)
                  _buildTextField(
                    _recurringKmIntervalController,
                    'Kilometer Interval',
                    'Enter kilometer interval',
                    TextInputType.number,
                  ),

                _buildCheckboxField(
                  'Recurring by Time',
                  _recurringTimeEnabled,
                  (value) {
                    setState(() {
                      _recurringTimeEnabled = value ?? false;
                    });
                  },
                ),

                if (_recurringTimeEnabled) ...[
                  _buildTextField(
                    _recurringDaysIntervalController,
                    'Days Interval',
                    'Enter days interval (optional)',
                    TextInputType.number,
                  ),
                  _buildTextField(
                    _recurringMonthsIntervalController,
                    'Months Interval',
                    'Enter months interval (optional)',
                    TextInputType.number,
                  ),
                  _buildTextField(
                    _recurringYearsIntervalController,
                    'Years Interval',
                    'Enter years interval (optional)',
                    TextInputType.number,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        readOnly: true,
        validator: (value) {
          // Only validate if this field is visible and required
          return null;
        },
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text =
                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    TextInputType keyboardType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          // Only validate if this field is visible and required
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        initialValue: value,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildCheckboxField(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class ExpenseReminderDetailsScreen extends StatelessWidget {
  final ExpenseReminder reminder;

  const ExpenseReminderDetailsScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit reminder screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditExpenseReminderScreen(reminder: reminder),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminder Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Expense Type',
                      reminder.expenseType ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Type',
                      reminder.isRecurring == true ? 'Recurring' : 'One-time',
                    ),
                    _buildInfoRow(
                      'Created At',
                      reminder.createdAt.toString().split(' ')[0],
                    ),
                    _buildInfoRow(
                      'Updated At',
                      reminder.updatedAt?.toString().split(' ')[0] ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trigger Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Trigger by Date',
                      reminder.triggerDateEnabled == true ? 'Yes' : 'No',
                    ),
                    if (reminder.triggerDateEnabled == true &&
                        reminder.triggerDate != null)
                      _buildInfoRow(
                        'Trigger Date',
                        reminder.triggerDate.toString().split(' ')[0],
                      ),
                    _buildInfoRow(
                      'Trigger by Kilometer',
                      reminder.triggerKmEnabled == true ? 'Yes' : 'No',
                    ),
                    if (reminder.triggerKmEnabled == true &&
                        reminder.triggerKm != null)
                      _buildInfoRow(
                        'Trigger Kilometer',
                        reminder.triggerKm?.toStringAsFixed(0) ?? 'N/A',
                      ),
                  ],
                ),
              ),
            ),

            if (reminder.isRecurring == true) ...[
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recurring Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Recurring by Kilometer',
                        reminder.recurringKmEnabled == true ? 'Yes' : 'No',
                      ),
                      if (reminder.recurringKmEnabled == true &&
                          reminder.recurringKmInterval != null)
                        _buildInfoRow(
                          'Kilometer Interval',
                          reminder.recurringKmInterval?.toString() ?? 'N/A',
                        ),
                      _buildInfoRow(
                        'Recurring by Time',
                        reminder.recurringTimeEnabled == true ? 'Yes' : 'No',
                      ),
                      if (reminder.recurringTimeEnabled == true) ...[
                        if (reminder.recurringDaysInterval != null &&
                            reminder.recurringDaysInterval! > 0)
                          _buildInfoRow(
                            'Days Interval',
                            reminder.recurringDaysInterval?.toString() ?? 'N/A',
                          ),
                        if (reminder.recurringMonthsInterval != null &&
                            reminder.recurringMonthsInterval! > 0)
                          _buildInfoRow(
                            'Months Interval',
                            reminder.recurringMonthsInterval?.toString() ??
                                'N/A',
                          ),
                        if (reminder.recurringYearsInterval != null &&
                            reminder.recurringYearsInterval! > 0)
                          _buildInfoRow(
                            'Years Interval',
                            reminder.recurringYearsInterval?.toString() ??
                                'N/A',
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 2, child: Text(value)),
        ],
      ),
    );
  }
}

class EditExpenseReminderScreen extends StatefulWidget {
  final ExpenseReminder reminder;

  const EditExpenseReminderScreen({super.key, required this.reminder});

  @override
  State<EditExpenseReminderScreen> createState() =>
      _EditExpenseReminderScreenState();
}

class _EditExpenseReminderScreenState extends State<EditExpenseReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _triggerDateController;
  late final TextEditingController _triggerKmController;
  late final TextEditingController _recurringKmIntervalController;
  late final TextEditingController _recurringDaysIntervalController;
  late final TextEditingController _recurringMonthsIntervalController;
  late final TextEditingController _recurringYearsIntervalController;

  late String? _selectedExpenseType;
  late bool _isRecurring;
  late bool _triggerDateEnabled;
  late bool _triggerKmEnabled;
  late bool _recurringKmEnabled;
  late bool _recurringTimeEnabled;

  final List<String> _expenseTypes = [
    'Repair/Maintenance',
    'Parking',
    'Financing',
    'Taxes (IPVA/DPVAT)',
    'Car Wash',
    'Licensing',
    'Traffic Fine',
    'Toll',
    'Review',
    'Insurance',
  ];

  @override
  void initState() {
    super.initState();
    _triggerDateController = TextEditingController(
      text: widget.reminder.triggerDate?.toString().split(' ')[0] ?? '',
    );
    _triggerKmController = TextEditingController(
      text: widget.reminder.triggerKm?.toString() ?? '',
    );
    _recurringKmIntervalController = TextEditingController(
      text: widget.reminder.recurringKmInterval?.toString() ?? '',
    );
    _recurringDaysIntervalController = TextEditingController(
      text: widget.reminder.recurringDaysInterval?.toString() ?? '',
    );
    _recurringMonthsIntervalController = TextEditingController(
      text: widget.reminder.recurringMonthsInterval?.toString() ?? '',
    );
    _recurringYearsIntervalController = TextEditingController(
      text: widget.reminder.recurringYearsInterval?.toString() ?? '',
    );

    _selectedExpenseType = widget.reminder.expenseType;
    _isRecurring = widget.reminder.isRecurring ?? false;
    _triggerDateEnabled = widget.reminder.triggerDateEnabled ?? false;
    _triggerKmEnabled = widget.reminder.triggerKmEnabled ?? false;
    _recurringKmEnabled = widget.reminder.recurringKmEnabled ?? false;
    _recurringTimeEnabled = widget.reminder.recurringTimeEnabled ?? false;
  }

  @override
  void dispose() {
    _triggerDateController.dispose();
    _triggerKmController.dispose();
    _recurringKmIntervalController.dispose();
    _recurringDaysIntervalController.dispose();
    _recurringMonthsIntervalController.dispose();
    _recurringYearsIntervalController.dispose();
    super.dispose();
  }

  void _updateReminder() {
    if (_formKey.currentState!.validate()) {
      // Validate that at least one trigger is selected
      if (!_triggerDateEnabled && !_triggerKmEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one trigger (date or km)'),
          ),
        );
        return;
      }

      // Validate that at least one recurring option is selected if recurring is enabled
      if (_isRecurring && !_recurringKmEnabled && !_recurringTimeEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select at least one recurring option (km or time)',
            ),
          ),
        );
        return;
      }

      final updatedReminder = ExpenseReminder(
        id: widget.reminder.id,
        vehicleId: widget.reminder.vehicleId,
        expenseType: _selectedExpenseType,
        isRecurring: _isRecurring,
        triggerDateEnabled: _triggerDateEnabled,
        triggerDate: _triggerDateController.text.isNotEmpty
            ? DateTime.parse(_triggerDateController.text)
            : null,
        triggerKmEnabled: _triggerKmEnabled,
        triggerKm: double.tryParse(_triggerKmController.text),
        recurringKmEnabled: _recurringKmEnabled,
        recurringKmInterval: int.tryParse(_recurringKmIntervalController.text),
        recurringTimeEnabled: _recurringTimeEnabled,
        recurringDaysInterval: int.tryParse(
          _recurringDaysIntervalController.text,
        ),
        recurringMonthsInterval: int.tryParse(
          _recurringMonthsIntervalController.text,
        ),
        recurringYearsInterval: int.tryParse(
          _recurringYearsIntervalController.text,
        ),
        createdAt: widget.reminder.createdAt,
        updatedAt: DateTime.now(),
      );

      Provider.of<ExpenseReminderProvider>(
        context,
        listen: false,
      ).updateExpenseReminder(updatedReminder);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense Reminder'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _updateReminder),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDropdownField(
                'Expense Type',
                _expenseTypes,
                _selectedExpenseType,
                (value) {
                  setState(() {
                    _selectedExpenseType = value;
                  });
                },
                required: true,
              ),

              const SizedBox(height: 16),
              _buildCheckboxField('Recurring Reminder', _isRecurring, (value) {
                setState(() {
                  _isRecurring = value ?? false;
                });
              }),

              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Trigger Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              _buildCheckboxField('Trigger by Date', _triggerDateEnabled, (
                value,
              ) {
                setState(() {
                  _triggerDateEnabled = value ?? false;
                });
              }),

              if (_triggerDateEnabled)
                _buildDateField(
                  _triggerDateController,
                  'Trigger Date',
                  'Select trigger date',
                ),

              _buildCheckboxField('Trigger by Kilometer', _triggerKmEnabled, (
                value,
              ) {
                setState(() {
                  _triggerKmEnabled = value ?? false;
                });
              }),

              if (_triggerKmEnabled)
                _buildTextField(
                  _triggerKmController,
                  'Trigger Kilometer',
                  'Enter trigger kilometer',
                  TextInputType.number,
                ),

              if (_isRecurring) ...[
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Recurring Options',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                _buildCheckboxField(
                  'Recurring by Kilometer',
                  _recurringKmEnabled,
                  (value) {
                    setState(() {
                      _recurringKmEnabled = value ?? false;
                    });
                  },
                ),

                if (_recurringKmEnabled)
                  _buildTextField(
                    _recurringKmIntervalController,
                    'Kilometer Interval',
                    'Enter kilometer interval',
                    TextInputType.number,
                  ),

                _buildCheckboxField(
                  'Recurring by Time',
                  _recurringTimeEnabled,
                  (value) {
                    setState(() {
                      _recurringTimeEnabled = value ?? false;
                    });
                  },
                ),

                if (_recurringTimeEnabled) ...[
                  _buildTextField(
                    _recurringDaysIntervalController,
                    'Days Interval',
                    'Enter days interval (optional)',
                    TextInputType.number,
                  ),
                  _buildTextField(
                    _recurringMonthsIntervalController,
                    'Months Interval',
                    'Enter months interval (optional)',
                    TextInputType.number,
                  ),
                  _buildTextField(
                    _recurringYearsIntervalController,
                    'Years Interval',
                    'Enter years interval (optional)',
                    TextInputType.number,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        readOnly: true,
        validator: (value) {
          // Only validate if this field is visible and required
          return null;
        },
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: controller.text.isNotEmpty
                ? DateTime.parse(controller.text)
                : DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text =
                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    TextInputType keyboardType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          // Only validate if this field is visible and required
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        initialValue: value,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildCheckboxField(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
