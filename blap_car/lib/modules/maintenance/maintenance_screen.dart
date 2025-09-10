import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/modules/maintenance/maintenance_provider.dart';

class MaintenanceListScreen extends StatelessWidget {
  final int vehicleId;

  const MaintenanceListScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: () async {
              final provider = Provider.of<MaintenanceProvider>(context, listen: false);
              await provider.autoScheduleMaintenance(vehicleId);
              // Show a snackbar to inform the user
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Maintenance auto-scheduled successfully')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMaintenanceScreen(vehicleId: vehicleId),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MaintenanceProvider>(
        builder: (context, maintenanceProvider, child) {
          // Load maintenance records when the screen is built
          if (maintenanceProvider.maintenances.isEmpty) {
            maintenanceProvider.loadMaintenances(vehicleId);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await maintenanceProvider.loadMaintenances(vehicleId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: maintenanceProvider.maintenances.length,
              itemBuilder: (context, index) {
                final maintenance = maintenanceProvider.maintenances[index];
                return Card(
                  child: ListTile(
                    title: Text('${maintenance.type} - ${maintenance.cost?.toStringAsFixed(2) ?? 'N/A'}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${maintenance.status ?? 'N/A'}'),
                        if (maintenance.nextDate != null)
                          Text('Next: ${maintenance.nextDate.toString().split(' ')[0]}'),
                      ],
                    ),
                    trailing: Text(maintenance.date?.toString().split(' ')[0] ?? 'N/A'),
                    onTap: () {
                      // Navigate to maintenance details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaintenanceDetailsScreen(maintenance: maintenance),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = Provider.of<MaintenanceProvider>(context, listen: false);
          final suggestedMaintenance = await provider.suggestNextMaintenance(vehicleId);
          
          if (suggestedMaintenance != null && context.mounted) {
            // Show dialog to confirm suggested maintenance
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Suggested Maintenance'),
                  content: Text(
                      'We suggest scheduling a ${suggestedMaintenance.type} maintenance. Would you like to add it?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
            
            if (confirmed == true && context.mounted) {
              // Add the suggested maintenance
              await provider.addMaintenance(suggestedMaintenance);
              // Show confirmation
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Suggested maintenance added successfully')),
                );
              }
            }
          } else if (context.mounted) {
            // No suggestion available, navigate to add screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMaintenanceScreen(vehicleId: vehicleId),
              ),
            );
          }
        },
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}

class AddMaintenanceScreen extends StatefulWidget {
  final int vehicleId;

  const AddMaintenanceScreen({super.key, required this.vehicleId});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _nextDateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedMaintenanceType;
  String? _selectedStatus;

  final List<String> _maintenanceTypes = [
    'Oil Change',
    'Battery',
    'Lights',
    'Tires',
    'Inspection',
    'Brake Check',
    'Air Conditioning',
    'Filter Replacement',
    'Other'
  ];

  final List<String> _statuses = [
    'Scheduled',
    'In Progress',
    'Completed',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    // Set default date to current
    final now = DateTime.now();
    _dateController.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nextDateController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveMaintenance() {
    if (_formKey.currentState!.validate()) {
      final maintenance = Maintenance(
        vehicleId: widget.vehicleId,
        type: _selectedMaintenanceType,
        description: _descriptionController.text,
        cost: double.tryParse(_costController.text),
        date: _dateController.text.isNotEmpty ? DateTime.parse(_dateController.text) : null,
        nextDate: _nextDateController.text.isNotEmpty ? DateTime.parse(_nextDateController.text) : null,
        odometer: int.tryParse(_odometerController.text),
        status: _selectedStatus,
      );

      Provider.of<MaintenanceProvider>(context, listen: false).addMaintenance(maintenance);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMaintenance,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDateField(_dateController, 'Date', 'Select maintenance date'),
              _buildDateField(_nextDateController, 'Next Date', 'Select next maintenance date (optional)'),
              _buildTextField(_odometerController, 'Odometer', 'Enter odometer reading', false, TextInputType.number),
              _buildDropdownField('Maintenance Type', _maintenanceTypes, _selectedMaintenanceType, (value) {
                setState(() {
                  _selectedMaintenanceType = value;
                });
              }, required: true),
              _buildTextField(_descriptionController, 'Description', 'Enter description'),
              _buildTextField(_costController, 'Cost', 'Enter cost', false, TextInputType.number),
              _buildDropdownField('Status', _statuses, _selectedStatus, (value) {
                setState(() {
                  _selectedStatus = value;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label, String hint) {
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
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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

class MaintenanceDetailsScreen extends StatelessWidget {
  final Maintenance maintenance;

  const MaintenanceDetailsScreen({super.key, required this.maintenance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit maintenance screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMaintenanceScreen(maintenance: maintenance),
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
                    const Text('Maintenance Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Date', maintenance.date?.toString().split(' ')[0] ?? 'N/A'),
                    _buildInfoRow('Next Date', maintenance.nextDate?.toString().split(' ')[0] ?? 'N/A'),
                    _buildInfoRow('Maintenance Type', maintenance.type ?? 'N/A'),
                    _buildInfoRow('Description', maintenance.description ?? 'N/A'),
                    _buildInfoRow('Cost', maintenance.cost?.toStringAsFixed(2) ?? 'N/A'),
                    _buildInfoRow('Odometer', maintenance.odometer?.toString() ?? 'N/A'),
                    _buildInfoRow('Status', maintenance.status ?? 'N/A'),
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

class EditMaintenanceScreen extends StatefulWidget {
  final Maintenance maintenance;

  const EditMaintenanceScreen({super.key, required this.maintenance});

  @override
  State<EditMaintenanceScreen> createState() => _EditMaintenanceScreenState();
}

class _EditMaintenanceScreenState extends State<EditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _nextDateController;
  late final TextEditingController _odometerController;
  late final TextEditingController _costController;
  late final TextEditingController _descriptionController;

  late String? _selectedMaintenanceType;
  late String? _selectedStatus;

  final List<String> _maintenanceTypes = [
    'Oil Change',
    'Battery',
    'Lights',
    'Tires',
    'Inspection',
    'Brake Check',
    'Air Conditioning',
    'Filter Replacement',
    'Other'
  ];

  final List<String> _statuses = [
    'Scheduled',
    'In Progress',
    'Completed',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.maintenance.date?.toString().split(' ')[0] ?? '');
    _nextDateController = TextEditingController(text: widget.maintenance.nextDate?.toString().split(' ')[0] ?? '');
    _odometerController = TextEditingController(text: widget.maintenance.odometer?.toString() ?? '');
    _costController = TextEditingController(text: widget.maintenance.cost?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.maintenance.description ?? '');
    
    _selectedMaintenanceType = widget.maintenance.type;
    _selectedStatus = widget.maintenance.status;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nextDateController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateMaintenance() {
    if (_formKey.currentState!.validate()) {
      final updatedMaintenance = Maintenance(
        id: widget.maintenance.id,
        vehicleId: widget.maintenance.vehicleId,
        type: _selectedMaintenanceType,
        description: _descriptionController.text,
        cost: double.tryParse(_costController.text),
        date: _dateController.text.isNotEmpty ? DateTime.parse(_dateController.text) : null,
        nextDate: _nextDateController.text.isNotEmpty ? DateTime.parse(_nextDateController.text) : null,
        odometer: int.tryParse(_odometerController.text),
        status: _selectedStatus,
      );

      Provider.of<MaintenanceProvider>(context, listen: false).updateMaintenance(updatedMaintenance);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateMaintenance,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDateField(_dateController, 'Date', 'Select maintenance date'),
              _buildDateField(_nextDateController, 'Next Date', 'Select next maintenance date (optional)'),
              _buildTextField(_odometerController, 'Odometer', 'Enter odometer reading', false, TextInputType.number),
              _buildDropdownField('Maintenance Type', _maintenanceTypes, _selectedMaintenanceType, (value) {
                setState(() {
                  _selectedMaintenanceType = value;
                });
              }, required: true),
              _buildTextField(_descriptionController, 'Description', 'Enter description'),
              _buildTextField(_costController, 'Cost', 'Enter cost', false, TextInputType.number),
              _buildDropdownField('Status', _statuses, _selectedStatus, (value) {
                setState(() {
                  _selectedStatus = value;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label, String hint) {
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
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: controller.text.isNotEmpty ? DateTime.parse(controller.text) : DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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