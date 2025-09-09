import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/models/checklist.dart';
import 'package:blap_car/modules/checklist/checklist_provider.dart';

class ChecklistListScreen extends StatelessWidget {
  const ChecklistListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddChecklistScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          // Load checklists when the screen is built
          if (checklistProvider.checklists.isEmpty) {
            checklistProvider.loadChecklists();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await checklistProvider.loadChecklists();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: checklistProvider.checklists.length,
              itemBuilder: (context, index) {
                final checklist = checklistProvider.checklists[index];
                return Card(
                  child: ListTile(
                    title: Text(checklist.name),
                    subtitle: Text(checklist.description ?? ''),
                    trailing: Text(checklist.createdAt.toString().split(' ')[0]),
                    onTap: () {
                      // Navigate to checklist details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChecklistDetailsScreen(checklist: checklist),
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

class AddChecklistScreen extends StatefulWidget {
  const AddChecklistScreen({super.key});

  @override
  State<AddChecklistScreen> createState() => _AddChecklistScreenState();
}

class _AddChecklistScreenState extends State<AddChecklistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChecklist() {
    if (_formKey.currentState!.validate()) {
      final checklist = Checklist(
        name: _nameController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
      );

      Provider.of<ChecklistProvider>(context, listen: false).addChecklist(checklist);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChecklist,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name', 'Enter checklist name', true),
              _buildTextField(_descriptionController, 'Description', 'Enter description'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, [bool required = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
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

class ChecklistDetailsScreen extends StatelessWidget {
  final Checklist checklist;

  const ChecklistDetailsScreen({super.key, required this.checklist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(checklist.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit checklist screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditChecklistScreen(checklist: checklist),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add checklist item screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddChecklistItemScreen(checklistId: checklist.id!),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          // Load checklist items when the screen is built
          if (checklistProvider.checklistItems.isEmpty) {
            checklistProvider.loadChecklistItems(checklist.id!);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await checklistProvider.loadChecklistItems(checklist.id!);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: checklistProvider.checklistItems.length,
              itemBuilder: (context, index) {
                final item = checklistProvider.checklistItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.description ?? ''),
                    trailing: item.isRequired 
                      ? const Chip(label: Text('Required')) 
                      : const Chip(label: Text('Optional')),
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

class EditChecklistScreen extends StatefulWidget {
  final Checklist checklist;

  const EditChecklistScreen({super.key, required this.checklist});

  @override
  State<EditChecklistScreen> createState() => _EditChecklistScreenState();
}

class _EditChecklistScreenState extends State<EditChecklistScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.checklist.name);
    _descriptionController = TextEditingController(text: widget.checklist.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateChecklist() {
    if (_formKey.currentState!.validate()) {
      final updatedChecklist = Checklist(
        id: widget.checklist.id,
        name: _nameController.text,
        description: _descriptionController.text,
        createdAt: widget.checklist.createdAt,
        updatedAt: DateTime.now(),
      );

      Provider.of<ChecklistProvider>(context, listen: false).updateChecklist(updatedChecklist);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateChecklist,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name', 'Enter checklist name', true),
              _buildTextField(_descriptionController, 'Description', 'Enter description'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, [bool required = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
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

class AddChecklistItemScreen extends StatefulWidget {
  final int checklistId;

  const AddChecklistItemScreen({super.key, required this.checklistId});

  @override
  State<AddChecklistItemScreen> createState() => _AddChecklistItemScreenState();
}

class _AddChecklistItemScreenState extends State<AddChecklistItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isRequired = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChecklistItem() {
    if (_formKey.currentState!.validate()) {
      final item = ChecklistItem(
        checklistId: widget.checklistId,
        name: _nameController.text,
        description: _descriptionController.text,
        isRequired: _isRequired,
        createdAt: DateTime.now(),
      );

      Provider.of<ChecklistProvider>(context, listen: false).addChecklistItem(item);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Checklist Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChecklistItem,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name', 'Enter item name', true),
              _buildTextField(_descriptionController, 'Description', 'Enter description'),
              _buildCheckboxField('Required', _isRequired, (value) {
                setState(() {
                  _isRequired = value ?? false;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, [bool required = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
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

  Widget _buildCheckboxField(String label, bool value, Function(bool?) onChanged) {
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