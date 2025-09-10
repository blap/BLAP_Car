import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';

class VehicleSelectionScreen extends StatelessWidget {
  final String actionType; // 'refueling', 'expense', 'reminder'
  final Function(int) onVehicleSelected;

  const VehicleSelectionScreen({
    super.key,
    required this.actionType,
    required this.onVehicleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Vehicle for $actionType'),
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          if (vehicleProvider.vehicles.isEmpty) {
            return const Center(
              child: Text('No vehicles registered. Please add a vehicle first.'),
            );
          }

          // If there's only one vehicle, select it automatically
          if (vehicleProvider.vehicles.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onVehicleSelected(vehicleProvider.vehicles.first.id!);
            });
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
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
                    onVehicleSelected(vehicle.id!);
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