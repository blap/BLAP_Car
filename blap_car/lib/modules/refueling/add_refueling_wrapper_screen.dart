import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/refueling/refueling_screen.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';
import 'package:blap_car/modules/vehicle/vehicle_selection_screen.dart';

class AddRefuelingWrapperScreen extends StatelessWidget {
  const AddRefuelingWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        // Load vehicles if not already loaded
        if (vehicleProvider.vehicles.isEmpty) {
          vehicleProvider.loadVehicles();
        }

        // Check if vehicles exist
        if (vehicleProvider.vehicles.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add Refueling')),
            body: const Center(
              child: Text('Please register a vehicle first'),
            ),
          );
        }

        // If there's only one vehicle, use it directly
        if (vehicleProvider.vehicles.length == 1) {
          return AddRefuelingScreen(vehicleId: vehicleProvider.vehicles.first.id!);
        }

        // If there are multiple vehicles, show selection screen
        return VehicleSelectionScreen(
          actionType: 'Refueling',
          onVehicleSelected: (vehicleId) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddRefuelingScreen(vehicleId: vehicleId),
              ),
            );
          },
        );
      },
    );
  }
}