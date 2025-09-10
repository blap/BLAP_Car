import 'package:flutter/material.dart';
import 'package:blap_car/modules/refueling/refueling_screen.dart';

class RefuelingWrapperScreen extends StatelessWidget {
  const RefuelingWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we'll use a default vehicleId of 1
    // In a real app, you would select a vehicle first
    return RefuelingListScreen(vehicleId: 1);
  }
}