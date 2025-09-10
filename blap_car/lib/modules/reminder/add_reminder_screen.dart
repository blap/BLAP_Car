import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/models/reminder.dart';
import 'package:blap_car/modules/reminder/reminder_provider.dart';

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