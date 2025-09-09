import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';
import 'package:blap_car/models/vehicle.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add vehicle screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddVehicleScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await vehicleProvider.loadVehicles();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: vehicleProvider.vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicleProvider.vehicles[index];
                return Card(
                  child: ListTile(
                    title: Text(vehicle.name),
                    subtitle: Text('${vehicle.make} ${vehicle.model} (${vehicle.year})'),
                    trailing: Text(vehicle.plate ?? ''),
                    onTap: () {
                      // Navigate to vehicle details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
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

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _fuelTankVolumeController = TextEditingController();
  final _vinController = TextEditingController();
  final _renavamController = TextEditingController();
  final _initialOdometerController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _fuelTankVolumeController.dispose();
    _vinController.dispose();
    _renavamController.dispose();
    _initialOdometerController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        name: _nameController.text,
        make: _makeController.text,
        model: _modelController.text,
        year: int.tryParse(_yearController.text),
        plate: _plateController.text,
        fuelTankVolume: double.tryParse(_fuelTankVolumeController.text),
        vin: _vinController.text,
        renavam: _renavamController.text,
        initialOdometer: double.tryParse(_initialOdometerController.text),
        createdAt: DateTime.now(),
      );

      Provider.of<VehicleProvider>(context, listen: false).addVehicle(vehicle);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveVehicle,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name', 'Enter vehicle name', true),
              _buildTextField(_makeController, 'Make', 'Enter vehicle make'),
              _buildTextField(_modelController, 'Model', 'Enter vehicle model'),
              _buildTextField(_yearController, 'Year', 'Enter vehicle year'),
              _buildTextField(_plateController, 'License Plate', 'Enter license plate'),
              _buildTextField(_fuelTankVolumeController, 'Fuel Tank Volume', 'Enter fuel tank volume (L)'),
              _buildTextField(_vinController, 'VIN', 'Enter vehicle identification number'),
              _buildTextField(_renavamController, 'RENAVAM', 'Enter RENAVAM number'),
              _buildTextField(_initialOdometerController, 'Initial Odometer', 'Enter initial odometer reading'),
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

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit vehicle screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditVehicleScreen(vehicle: vehicle),
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
                    const Text('Vehicle Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Name', vehicle.name),
                    _buildInfoRow('Make', vehicle.make ?? 'N/A'),
                    _buildInfoRow('Model', vehicle.model ?? 'N/A'),
                    _buildInfoRow('Year', vehicle.year?.toString() ?? 'N/A'),
                    _buildInfoRow('License Plate', vehicle.plate ?? 'N/A'),
                    _buildInfoRow('Fuel Tank Volume', vehicle.fuelTankVolume?.toString() ?? 'N/A'),
                    _buildInfoRow('VIN', vehicle.vin ?? 'N/A'),
                    _buildInfoRow('RENAVAM', vehicle.renavam ?? 'N/A'),
                    _buildInfoRow('Initial Odometer', vehicle.initialOdometer?.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tabs for refueling, expenses, maintenance
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Refueling'),
                      Tab(text: 'Expenses'),
                      Tab(text: 'Maintenance'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        Center(child: Text('Refueling records for ${vehicle.name}')),
                        Center(child: Text('Expense records for ${vehicle.name}')),
                        Center(child: Text('Maintenance records for ${vehicle.name}')),
                      ],
                    ),
                  ),
                ],
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

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _plateController;
  late final TextEditingController _fuelTankVolumeController;
  late final TextEditingController _vinController;
  late final TextEditingController _renavamController;
  late final TextEditingController _initialOdometerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle.name);
    _makeController = TextEditingController(text: widget.vehicle.make);
    _modelController = TextEditingController(text: widget.vehicle.model);
    _yearController = TextEditingController(text: widget.vehicle.year?.toString());
    _plateController = TextEditingController(text: widget.vehicle.plate);
    _fuelTankVolumeController = TextEditingController(text: widget.vehicle.fuelTankVolume?.toString());
    _vinController = TextEditingController(text: widget.vehicle.vin);
    _renavamController = TextEditingController(text: widget.vehicle.renavam);
    _initialOdometerController = TextEditingController(text: widget.vehicle.initialOdometer?.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _fuelTankVolumeController.dispose();
    _vinController.dispose();
    _renavamController.dispose();
    _initialOdometerController.dispose();
    super.dispose();
  }

  void _updateVehicle() {
    if (_formKey.currentState!.validate()) {
      final updatedVehicle = Vehicle(
        id: widget.vehicle.id,
        name: _nameController.text,
        make: _makeController.text,
        model: _modelController.text,
        year: int.tryParse(_yearController.text),
        plate: _plateController.text,
        fuelTankVolume: double.tryParse(_fuelTankVolumeController.text),
        vin: _vinController.text,
        renavam: _renavamController.text,
        initialOdometer: double.tryParse(_initialOdometerController.text),
        createdAt: widget.vehicle.createdAt,
      );

      Provider.of<VehicleProvider>(context, listen: false).updateVehicle(updatedVehicle);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateVehicle,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name', 'Enter vehicle name', true),
              _buildTextField(_makeController, 'Make', 'Enter vehicle make'),
              _buildTextField(_modelController, 'Model', 'Enter vehicle model'),
              _buildTextField(_yearController, 'Year', 'Enter vehicle year'),
              _buildTextField(_plateController, 'License Plate', 'Enter license plate'),
              _buildTextField(_fuelTankVolumeController, 'Fuel Tank Volume', 'Enter fuel tank volume (L)'),
              _buildTextField(_vinController, 'VIN', 'Enter vehicle identification number'),
              _buildTextField(_renavamController, 'RENAVAM', 'Enter RENAVAM number'),
              _buildTextField(_initialOdometerController, 'Initial Odometer', 'Enter initial odometer reading'),
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