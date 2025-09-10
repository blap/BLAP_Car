import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/modules/refueling/refueling_provider.dart';

class RefuelingListScreen extends StatelessWidget {
  final int vehicleId;

  const RefuelingListScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refueling Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRefuelingScreen(vehicleId: vehicleId),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<RefuelingProvider>(
        builder: (context, refuelingProvider, child) {
          // Load refuelings when the screen is built
          if (refuelingProvider.refuelings.isEmpty) {
            refuelingProvider.loadRefuelings(vehicleId);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await refuelingProvider.loadRefuelings(vehicleId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: refuelingProvider.refuelings.length,
              itemBuilder: (context, index) {
                final refueling = refuelingProvider.refuelings[index];
                return Card(
                  child: ListTile(
                    title: Text('${refueling.fuelType} - ${refueling.totalCost?.toStringAsFixed(2) ?? 'N/A'}'),
                    subtitle: Text('Odometer: ${refueling.odometer.toStringAsFixed(0)} km'),
                    trailing: Text(refueling.date.toString().split(' ')[0]),
                    onTap: () {
                      // Navigate to refueling details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RefuelingDetailsScreen(refueling: refueling),
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

class AddRefuelingScreen extends StatefulWidget {
  final int vehicleId;

  const AddRefuelingScreen({super.key, required this.vehicleId});

  @override
  State<AddRefuelingScreen> createState() => _AddRefuelingScreenState();
}

class _AddRefuelingScreenState extends State<AddRefuelingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _odometerController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _litersController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _stationController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _observationController = TextEditingController();

  String? _selectedFuelType;
  bool _fullTank = false;
  bool _previousRefuelingMissing = false;

  final List<String> _fuelTypes = [
    'Gasoline (Regular)',
    'Ethanol',
    'Diesel',
    'LPG (Liquefied Petroleum Gas)',
    'CNG (Compressed Natural Gas)',
    'Electric'
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
    _pricePerLiterController.dispose();
    _litersController.dispose();
    _totalCostController.dispose();
    _stationController.dispose();
    _paymentMethodController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _saveRefueling() {
    if (_formKey.currentState!.validate()) {
      final refueling = Refueling(
        vehicleId: widget.vehicleId,
        date: DateTime.parse(_dateController.text),
        time: _timeController.text.isNotEmpty ? DateTime.parse('${_dateController.text} ${_timeController.text}') : null,
        odometer: double.tryParse(_odometerController.text) ?? 0,
        pricePerLiter: double.tryParse(_pricePerLiterController.text),
        liters: double.tryParse(_litersController.text),
        totalCost: double.tryParse(_totalCostController.text),
        fuelType: _selectedFuelType,
        station: _stationController.text,
        fullTank: _fullTank,
        previousRefuelingMissing: _previousRefuelingMissing,
        paymentMethod: _paymentMethodController.text,
        observation: _observationController.text,
      );

      Provider.of<RefuelingProvider>(context, listen: false).addRefueling(refueling);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Refueling'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRefueling,
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
              _buildTextField(_odometerController, 'Odometer', 'Enter odometer reading', true, TextInputType.number),
              _buildDropdownField('Fuel Type', _fuelTypes, _selectedFuelType, (value) {
                setState(() {
                  _selectedFuelType = value;
                });
              }),
              _buildTextField(_pricePerLiterController, 'Price per Liter', 'Enter price per liter', true, TextInputType.number),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_litersController, 'Liters', 'Enter liters', false, TextInputType.number),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(_totalCostController, 'Total Cost', 'Enter total cost', false, TextInputType.number),
                  ),
                ],
              ),
              _buildCheckboxField('Full Tank', _fullTank, (value) {
                setState(() {
                  _fullTank = value ?? false;
                });
              }),
              _buildCheckboxField('Previous Refueling Missing', _previousRefuelingMissing, (value) {
                setState(() {
                  _previousRefuelingMissing = value ?? false;
                });
              }),
              _buildTextField(_stationController, 'Gas Station', 'Enter gas station name'),
              _buildTextField(_paymentMethodController, 'Payment Method', 'Enter payment method'),
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

class RefuelingDetailsScreen extends StatelessWidget {
  final Refueling refueling;

  const RefuelingDetailsScreen({super.key, required this.refueling});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refueling Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit refueling screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditRefuelingScreen(refueling: refueling),
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
                    const Text('Refueling Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Date', refueling.date.toString().split(' ')[0]),
                    _buildInfoRow('Time', refueling.time?.toString().split(' ')[1].split(':').take(2).join(':') ?? 'N/A'),
                    _buildInfoRow('Odometer', '${refueling.odometer.toStringAsFixed(0)} km'),
                    _buildInfoRow('Fuel Type', refueling.fuelType ?? 'N/A'),
                    _buildInfoRow('Price per Liter', refueling.pricePerLiter?.toStringAsFixed(2) ?? 'N/A'),
                    _buildInfoRow('Liters', refueling.liters?.toStringAsFixed(2) ?? 'N/A'),
                    _buildInfoRow('Total Cost', refueling.totalCost?.toStringAsFixed(2) ?? 'N/A'),
                    _buildInfoRow('Gas Station', refueling.station ?? 'N/A'),
                    _buildInfoRow('Full Tank', refueling.fullTank == true ? 'Yes' : 'No'),
                    _buildInfoRow('Previous Refueling Missing', refueling.previousRefuelingMissing == true ? 'Yes' : 'No'),

                    _buildInfoRow('Payment Method', refueling.paymentMethod ?? 'N/A'),
                    _buildInfoRow('Observation', refueling.observation ?? 'N/A'),
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

class EditRefuelingScreen extends StatefulWidget {
  final Refueling refueling;

  const EditRefuelingScreen({super.key, required this.refueling});

  @override
  State<EditRefuelingScreen> createState() => _EditRefuelingScreenState();
}

class _EditRefuelingScreenState extends State<EditRefuelingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _odometerController;
  late final TextEditingController _pricePerLiterController;
  late final TextEditingController _litersController;
  late final TextEditingController _totalCostController;
  late final TextEditingController _stationController;
  late final TextEditingController _paymentMethodController;
  late final TextEditingController _observationController;

  late String? _selectedFuelType;
  late bool _fullTank;
  late bool _previousRefuelingMissing;

  final List<String> _fuelTypes = [
    'Gasoline (Regular)',
    'Ethanol',
    'Diesel',
    'LPG (Liquefied Petroleum Gas)',
    'CNG (Compressed Natural Gas)',
    'Electric'
  ];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.refueling.date.toString().split(' ')[0]);
    _timeController = TextEditingController(text: widget.refueling.time?.toString().split(' ')[1].split(':').take(2).join(':') ?? '');
    _odometerController = TextEditingController(text: widget.refueling.odometer.toString());
    _pricePerLiterController = TextEditingController(text: widget.refueling.pricePerLiter?.toString() ?? '');
    _litersController = TextEditingController(text: widget.refueling.liters?.toString() ?? '');
    _totalCostController = TextEditingController(text: widget.refueling.totalCost?.toString() ?? '');
    _stationController = TextEditingController(text: widget.refueling.station ?? '');
    _paymentMethodController = TextEditingController(text: widget.refueling.paymentMethod ?? '');
    _observationController = TextEditingController(text: widget.refueling.observation ?? '');
    
    _selectedFuelType = widget.refueling.fuelType;
    _fullTank = widget.refueling.fullTank ?? false;
    _previousRefuelingMissing = widget.refueling.previousRefuelingMissing ?? false;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _odometerController.dispose();
    _pricePerLiterController.dispose();
    _litersController.dispose();
    _totalCostController.dispose();
    _stationController.dispose();
    _paymentMethodController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _updateRefueling() {
    if (_formKey.currentState!.validate()) {
      final updatedRefueling = Refueling(
        id: widget.refueling.id,
        vehicleId: widget.refueling.vehicleId,
        date: DateTime.parse(_dateController.text),
        time: _timeController.text.isNotEmpty ? DateTime.parse('${_dateController.text} ${_timeController.text}') : null,
        odometer: double.tryParse(_odometerController.text) ?? 0,
        pricePerLiter: double.tryParse(_pricePerLiterController.text),
        liters: double.tryParse(_litersController.text),
        totalCost: double.tryParse(_totalCostController.text),
        fuelType: _selectedFuelType,
        station: _stationController.text,
        fullTank: _fullTank,
        previousRefuelingMissing: _previousRefuelingMissing,

        paymentMethod: _paymentMethodController.text,
        observation: _observationController.text,
      );

      Provider.of<RefuelingProvider>(context, listen: false).updateRefueling(updatedRefueling);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Refueling'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateRefueling,
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
              _buildTextField(_odometerController, 'Odometer', 'Enter odometer reading', true, TextInputType.number),
              _buildDropdownField('Fuel Type', _fuelTypes, _selectedFuelType, (value) {
                setState(() {
                  _selectedFuelType = value;
                });
              }),
              _buildTextField(_pricePerLiterController, 'Price per Liter', 'Enter price per liter', true, TextInputType.number),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_litersController, 'Liters', 'Enter liters', false, TextInputType.number),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(_totalCostController, 'Total Cost', 'Enter total cost', false, TextInputType.number),
                  ),
                ],
              ),
              _buildTextField(_stationController, 'Station', 'Enter station name'),
              // Removed _buildTextField(_driverController, 'Driver', 'Enter driver name'),
              _buildTextField(_paymentMethodController, 'Payment Method', 'Enter payment method'),
              _buildTextField(_observationController, 'Observation', 'Enter observation'),
              _buildCheckboxField('Full Tank', _fullTank, (value) {
                setState(() {
                  _fullTank = value ?? false;
                });
              }),
              _buildCheckboxField('Previous Refueling Missing', _previousRefuelingMissing, (value) {
                setState(() {
                  _previousRefuelingMissing = value ?? false;
                });
              }),
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