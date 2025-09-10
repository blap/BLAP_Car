import 'package:flutter/material.dart';
import 'package:blap_car/modules/report/report_screen.dart';

class ReportWrapperScreen extends StatelessWidget {
  const ReportWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we'll use a default vehicleId of 1
    // In a real app, you would select a vehicle first
    return ReportListScreen(vehicleId: 1);
  }
}