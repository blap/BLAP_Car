import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLAP Car Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to BLAP Car',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Manage your vehicle fleet efficiently with our comprehensive solution.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 32),
                // Quick action buttons would go here
              ],
            ),
          );
        },
      ),
    );
  }
}