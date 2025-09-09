import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/models/checklist.dart';
import 'package:blap_car/modules/checklist/checklist_provider.dart';

class ChecklistCompletionListScreen extends StatelessWidget {
  final int vehicleId;

  const ChecklistCompletionListScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Completions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to select checklist screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectChecklistScreen(vehicleId: vehicleId),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          // Load completions when the screen is built
          if (checklistProvider.completions.isEmpty) {
            checklistProvider.loadCompletions(vehicleId);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await checklistProvider.loadCompletions(vehicleId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: checklistProvider.completions.length,
              itemBuilder: (context, index) {
                final completion = checklistProvider.completions[index];
                return Card(
                  child: ListTile(
                    title: Text('Checklist Completion'),
                    subtitle: Text('Completed on: ${completion.completedAt.toString().split(' ')[0]}'),
                    trailing: Text(completion.notes ?? ''),
                    onTap: () {
                      // Navigate to completion details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChecklistCompletionDetailsScreen(completionId: completion.id!),
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

class SelectChecklistScreen extends StatelessWidget {
  final int vehicleId;

  const SelectChecklistScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Checklist'),
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          // Load checklists when the screen is built
          if (checklistProvider.checklists.isEmpty) {
            checklistProvider.loadChecklists();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: checklistProvider.checklists.length,
            itemBuilder: (context, index) {
              final checklist = checklistProvider.checklists[index];
              return Card(
                child: ListTile(
                  title: Text(checklist.name),
                  subtitle: Text(checklist.description ?? ''),
                  onTap: () {
                    // Navigate to complete checklist screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompleteChecklistScreen(
                          vehicleId: vehicleId,
                          checklist: checklist,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CompleteChecklistScreen extends StatefulWidget {
  final int vehicleId;
  final Checklist checklist;

  const CompleteChecklistScreen({
    super.key,
    required this.vehicleId,
    required this.checklist,
  });

  @override
  State<CompleteChecklistScreen> createState() => _CompleteChecklistScreenState();
}

class _CompleteChecklistScreenState extends State<CompleteChecklistScreen> {
  final _notesController = TextEditingController();
  List<bool> _itemCompletionStatus = [];
  List<TextEditingController> _itemNotesControllers = [];

  @override
  void initState() {
    super.initState();
    // Load checklist items
    Provider.of<ChecklistProvider>(context, listen: false)
        .loadChecklistItems(widget.checklist.id!);
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (var controller in _itemNotesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveCompletion() async {
    final checklistProvider = Provider.of<ChecklistProvider>(context, listen: false);
    
    // Create checklist completion
    final completion = ChecklistCompletion(
      checklistId: widget.checklist.id!,
      vehicleId: widget.vehicleId,
      completedAt: DateTime.now(),
      notes: _notesController.text,
    );
    
    final completionId = await checklistProvider.addCompletion(completion);
    
    // Create item completions
    for (int i = 0; i < checklistProvider.checklistItems.length; i++) {
      final item = checklistProvider.checklistItems[i];
      final itemCompletion = ChecklistItemCompletion(
        checklistCompletionId: completionId,
        checklistItemId: item.id!,
        isCompleted: _itemCompletionStatus.length > i ? _itemCompletionStatus[i] : false,
        notes: _itemNotesControllers.length > i ? _itemNotesControllers[i].text : '',
        completedAt: DateTime.now(),
      );
      
      await checklistProvider.addItemCompletion(itemCompletion);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete: ${widget.checklist.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCompletion,
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          // Initialize completion status and notes controllers when items are loaded
          if (checklistProvider.checklistItems.isNotEmpty && _itemCompletionStatus.isEmpty) {
            _itemCompletionStatus = List.generate(checklistProvider.checklistItems.length, (index) => false);
            _itemNotesControllers = List.generate(
              checklistProvider.checklistItems.length,
              (index) => TextEditingController(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.checklist.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (widget.checklist.description != null) ...[
                  const SizedBox(height: 8),
                  Text(widget.checklist.description!),
                ],
                const SizedBox(height: 16),
                
                const Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                if (checklistProvider.checklistItems.isEmpty)
                  const Center(child: Text('No items in this checklist'))
                else
                  Column(
                    children: List.generate(checklistProvider.checklistItems.length, (index) {
                      final item = checklistProvider.checklistItems[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _itemCompletionStatus.length > index 
                                        ? _itemCompletionStatus[index] 
                                        : false,
                                    onChanged: (value) {
                                      setState(() {
                                        if (_itemCompletionStatus.length > index) {
                                          _itemCompletionStatus[index] = value ?? false;
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: item.isRequired ? FontWeight.bold : FontWeight.normal,
                                        decoration: _itemCompletionStatus.length > index && _itemCompletionStatus[index]
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.description != null) ...[
                                const SizedBox(height: 8),
                                Text(item.description!),
                              ],
                              const SizedBox(height: 8),
                              TextField(
                                controller: _itemNotesControllers.length > index 
                                    ? _itemNotesControllers[index] 
                                    : TextEditingController(),
                                decoration: const InputDecoration(
                                  labelText: 'Notes',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                
                const SizedBox(height: 16),
                const Text('Completion Notes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    hintText: 'Enter any additional notes about this completion',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChecklistCompletionDetailsScreen extends StatelessWidget {
  final int completionId;

  const ChecklistCompletionDetailsScreen({super.key, required this.completionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completion Details'),
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          // Load completion details when the screen is built
          if (checklistProvider.itemCompletions.isEmpty) {
            checklistProvider.loadItemCompletions(completionId);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Completion Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                if (checklistProvider.itemCompletions.isEmpty)
                  const Center(child: Text('No completion details available'))
                else
                  Column(
                    children: List.generate(checklistProvider.itemCompletions.length, (index) {
                      final itemCompletion = checklistProvider.itemCompletions[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    itemCompletion.isCompleted 
                                        ? Icons.check_circle 
                                        : Icons.radio_button_unchecked,
                                    color: itemCompletion.isCompleted ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Item ${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: itemCompletion.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (itemCompletion.notes != null && itemCompletion.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Notes: ${itemCompletion.notes}'),
                              ],
                              if (itemCompletion.completedAt != null) ...[
                                const SizedBox(height: 4),
                                Text('Completed: ${itemCompletion.completedAt.toString().split(' ')[0]}'),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}