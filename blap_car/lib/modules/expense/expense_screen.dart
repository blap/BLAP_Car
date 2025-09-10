import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/modules/expense/expense_provider.dart';

class ExpenseListScreen extends StatelessWidget {
  final int vehicleId;

  const ExpenseListScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExpenseScreen(vehicleId: vehicleId),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          // Load expenses when the screen is built
          if (expenseProvider.expenses.isEmpty) {
            expenseProvider.loadExpenses(vehicleId);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await expenseProvider.loadExpenses(vehicleId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: expenseProvider.expenses.length,
              itemBuilder: (context, index) {
                final expense = expenseProvider.expenses[index];
                return Card(
                  child: ListTile(
                    title: Text('${expense.type} - ${expense.cost?.toStringAsFixed(2) ?? 'N/A'}'),
                    subtitle: Text('Odometer: ${expense.odometer?.toStringAsFixed(0) ?? 'N/A'} km'),
                    trailing: Text(expense.date.toString().split(' ')[0]),
                    onTap: () {
                      // Navigate to expense details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpenseDetailsScreen(expense: expense),
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
}

class AddExpenseScreen extends StatefulWidget {
  final int vehicleId;

  const AddExpenseScreen({super.key, required this.vehicleId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _locationController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _observationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedExpenseType;
  String? _selectedCategory;

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
    'Insurance'
  ];

  final List<String> _categories = [
    'Fine',
    'Licensing',
    'Taxes (IPVA/DPVAT)',
    'Toll',
    'Insurance'
  ];

  @override
  void initState() {
    super.initState();
    // Set default date and time to current
    final now = DateTime.now();
    _dateController.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _timeController.text = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _locationController.dispose();
    _paymentMethodController.dispose();
    _observationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        vehicleId: widget.vehicleId,
        type: _selectedExpenseType,
        description: _descriptionController.text,
        cost: double.tryParse(_costController.text),
        date: DateTime.parse(_dateController.text),
        time: _timeController.text.isNotEmpty ? DateTime.parse('${_dateController.text} ${_timeController.text}') : null,
        odometer: double.tryParse(_odometerController.text),
        location: _locationController.text,
        paymentMethod: _paymentMethodController.text,
        observation: _observationController.text,
        category: _selectedCategory,
      );

      Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExpense,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDateField(),
              _buildTimeField(),
              _buildTextField(_odometerController, 'Odometer', 'Enter odometer reading', false, TextInputType.number),
              _buildDropdownField('Expense Type', _expenseTypes, _selectedExpenseType, (value) {
                setState(() {
                  _selectedExpenseType = value;
                });
              }, required: true),
              _buildTextField(_descriptionController, 'Description', 'Enter description'),
              _buildTextField(_costController, 'Cost', 'Enter cost', true, TextInputType.number),
              _buildTextField(_locationController, 'Location', 'Enter location'),
              _buildTextField(_paymentMethodController, 'Payment Method', 'Enter payment method'),
              _buildDropdownField('Category', _categories, _selectedCategory, (value) {
                setState(() {
                  _selectedCategory = value;
                });
              }),
              _buildTextField(_observationController, 'Observation', 'Enter observation'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _dateController,
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
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
              _dateController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            });
          }
        },
      ),
    );
  }

  Widget _buildTimeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _timeController,
        decoration: const InputDecoration(
          labelText: 'Time',
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            setState(() {
              _timeController.text = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, [bool required = false, TextInputType keyboardType = TextInputType.text]) {
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

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        initialValue: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
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
}

class ExpenseDetailsScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit expense screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditExpenseScreen(expense: expense),
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
                    const Text('Expense Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Date', expense.date.toString().split(' ')[0]),
                    _buildInfoRow('Time', expense.time?.toString().split(' ')[1].split(':').take(2).join(':') ?? 'N/A'),
                    _buildInfoRow('Expense Type', expense.type ?? 'N/A'),
                    _buildInfoRow('Description', expense.description ?? 'N/A'),
                    _buildInfoRow('Cost', expense.cost?.toStringAsFixed(2) ?? 'N/A'),
                    _buildInfoRow('Odometer', expense.odometer?.toStringAsFixed(0) ?? 'N/A'),
                    _buildInfoRow('Location', expense.location ?? 'N/A'),

                    _buildInfoRow('Payment Method', expense.paymentMethod ?? 'N/A'),
                    _buildInfoRow('Category', expense.category ?? 'N/A'),
                    _buildInfoRow('Observation', expense.observation ?? 'N/A'),
                  ],
                ),
              ),
            ),
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
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _odometerController;
  late final TextEditingController _costController;
  late final TextEditingController _locationController;
  late final TextEditingController _paymentMethodController;
  late final TextEditingController _observationController;
  late final TextEditingController _descriptionController;

  late String? _selectedExpenseType;
  late String? _selectedCategory;

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
    'Insurance'
  ];

  final List<String> _categories = [
    'Fine',
    'Licensing',
    'Taxes (IPVA/DPVAT)',
    'Toll',
    'Insurance'
  ];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.expense.date.toString().split(' ')[0]);
    _timeController = TextEditingController(text: widget.expense.time?.toString().split(' ')[1].split(':').take(2).join(':') ?? '');
    _odometerController = TextEditingController(text: widget.expense.odometer?.toString() ?? '');
    _costController = TextEditingController(text: widget.expense.cost?.toString() ?? '');
    _locationController = TextEditingController(text: widget.expense.location ?? '');
    _paymentMethodController = TextEditingController(text: widget.expense.paymentMethod ?? '');
    _observationController = TextEditingController(text: widget.expense.observation ?? '');
    _descriptionController = TextEditingController(text: widget.expense.description ?? '');
    
    _selectedExpenseType = widget.expense.type;
    _selectedCategory = widget.expense.category;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _locationController.dispose();
    _paymentMethodController.dispose();
    _observationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateExpense() {
    if (_formKey.currentState!.validate()) {
      final updatedExpense = Expense(
        id: widget.expense.id,
        vehicleId: widget.expense.vehicleId,
        type: _selectedExpenseType,
        description: _descriptionController.text,
        cost: double.tryParse(_costController.text),
        date: DateTime.parse(_dateController.text),
        time: _timeController.text.isNotEmpty ? DateTime.parse('${_dateController.text} ${_timeController.text}') : null,
        odometer: double.tryParse(_odometerController.text),
        location: _locationController.text,
        paymentMethod: _paymentMethodController.text,
        observation: _observationController.text,
        category: _selectedCategory,
      );

      Provider.of<ExpenseProvider>(context, listen: false).updateExpense(updatedExpense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateExpense,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDateField(),
              _buildTimeField(),
              _buildTextField(_odometerController, 'Odometer', 'Enter odometer reading', false, TextInputType.number),
              _buildDropdownField('Expense Type', _expenseTypes, _selectedExpenseType, (value) {
                setState(() {
                  _selectedExpenseType = value;
                });
              }, required: true),
              _buildTextField(_descriptionController, 'Description', 'Enter description'),
              _buildTextField(_costController, 'Cost', 'Enter cost', true, TextInputType.number),
              _buildTextField(_locationController, 'Location', 'Enter location'),
              _buildTextField(_paymentMethodController, 'Payment Method', 'Enter payment method'),
              _buildDropdownField('Category', _categories, _selectedCategory, (value) {
                setState(() {
                  _selectedCategory = value;
                });
              }),
              _buildTextField(_observationController, 'Observation', 'Enter observation'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _dateController,
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.parse(_dateController.text),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              _dateController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            });
          }
        },
      ),
    );
  }

  Widget _buildTimeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _timeController,
        decoration: const InputDecoration(
          labelText: 'Time',
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: _timeController.text.isNotEmpty 
              ? TimeOfDay(hour: int.parse(_timeController.text.split(':')[0]), 
                         minute: int.parse(_timeController.text.split(':')[1]))
              : TimeOfDay.now(),
          );
          if (pickedTime != null) {
            setState(() {
              _timeController.text = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, [bool required = false, TextInputType keyboardType = TextInputType.text]) {
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

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        initialValue: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
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
}