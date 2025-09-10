import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/models/reminder.dart';
import 'package:blap_car/models/expense_reminder.dart';
import 'package:blap_car/modules/reminder/reminder_provider.dart';
import 'package:blap_car/modules/reminder/add_expense_reminder_wrapper_screen.dart';
import 'package:blap_car/services/reminder_service.dart';

class ReminderListScreen extends StatefulWidget {
  final int vehicleId;

  const ReminderListScreen({super.key, required this.vehicleId});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  final ReminderService _reminderService = ReminderService();
  List<dynamic> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final reminders = await _reminderService.getRemindersByVehicleId(widget.vehicleId);
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Show options for adding different types of reminders
              _showAddReminderOptions(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadReminders();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reminders.isEmpty
                ? const Center(
                    child: Text(
                      'No reminders found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _reminders[index];
                      return _buildReminderCard(reminder);
                    },
                  ),
      ),
    );
  }

  Widget _buildReminderCard(dynamic reminder) {
    if (reminder is Reminder) {
      return _buildGeneralReminderCard(reminder);
    } else if (reminder is ExpenseReminder) {
      return _buildExpenseReminderCard(reminder);
    }
    return const SizedBox();
  }

  Widget _buildGeneralReminderCard(Reminder reminder) {
    return Card(
      child: ListTile(
        title: Text(reminder.type ?? 'General Reminder'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description != null)
              Text(reminder.description!),
            if (reminder.date != null)
              Text(
                'Date: ${reminder.date!.day}/${reminder.date!.month}/${reminder.date!.year}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reminder.completed == true)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              const Icon(Icons.pending, color: Colors.orange),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _confirmDeleteReminder(reminder.id!);
              },
            ),
          ],
        ),
        onTap: () {
          // Navigate to reminder details
          _showGeneralReminderDetails(reminder);
        },
      ),
    );
  }

  Widget _buildExpenseReminderCard(ExpenseReminder reminder) {
    return Card(
      child: ListTile(
        title: Text(reminder.expenseType ?? 'Expense Reminder'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.triggerDate != null)
              Text(
                'Date: ${reminder.triggerDate!.day}/${reminder.triggerDate!.month}/${reminder.triggerDate!.year}',
                style: const TextStyle(fontSize: 12),
              ),
            if (reminder.triggerKm != null)
              Text(
                'KM: ${reminder.triggerKm!.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
            if (reminder.isRecurring == true)
              const Text(
                'Recurring',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _confirmDeleteExpenseReminder(reminder.id!);
          },
        ),
        onTap: () {
          // Navigate to expense reminder details
          _showExpenseReminderDetails(reminder);
        },
      ),
    );
  }

  void _showAddReminderOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('General Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddGeneralReminder();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Expense Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddExpenseReminder();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddGeneralReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGeneralReminderScreen(vehicleId: widget.vehicleId),
      ),
    );
  }

  void _navigateToAddExpenseReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseReminderWrapperScreen(),
      ),
    );
  }

  void _showGeneralReminderDetails(Reminder reminder) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.type ?? 'General Reminder',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (reminder.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(reminder.description!),
                  ),
                if (reminder.date != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Date: ${reminder.date!.day}/${reminder.date!.month}/${reminder.date!.year}'),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExpenseReminderDetails(ExpenseReminder reminder) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.expenseType ?? 'Expense Reminder',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (reminder.triggerDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Date: ${reminder.triggerDate!.day}/${reminder.triggerDate!.month}/${reminder.triggerDate!.year}'),
                  ),
                if (reminder.triggerKm != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('KM: ${reminder.triggerKm!.toStringAsFixed(0)}'),
                  ),
                if (reminder.isRecurring == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Recurring'),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteReminder(int reminderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteReminder(reminderId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteExpenseReminder(int reminderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense Reminder'),
          content: const Text('Are you sure you want to delete this expense reminder?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteExpenseReminder(reminderId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReminder(int reminderId) async {
    try {
      await _reminderService.deleteReminder(reminderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder deleted successfully')),
        );
        await _loadReminders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting reminder: $e')),
        );
      }
    }
  }

  Future<void> _deleteExpenseReminder(int reminderId) async {
    try {
      await _reminderService.deleteExpenseReminder(reminderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense reminder deleted successfully')),
        );
        await _loadReminders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting expense reminder: $e')),
        );
      }
    }
  }
}

class AddGeneralReminderScreen extends StatefulWidget {
  final int vehicleId;

  const AddGeneralReminderScreen({super.key, required this.vehicleId});

  @override
  State<AddGeneralReminderScreen> createState() => _AddGeneralReminderScreenState();
}

class _AddGeneralReminderScreenState extends State<AddGeneralReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String();
      });
    }
  }

  void _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final reminder = Reminder(
        vehicleId: widget.vehicleId,
        type: _titleController.text,
        description: _descriptionController.text,
        date: _dateController.text.isNotEmpty ? DateTime.parse(_dateController.text) : null,
        completed: false,
      );

      // Save to database through the provider
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      final success = await provider.addReminder(reminder);
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder saved successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving reminder')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add General Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveReminder,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}