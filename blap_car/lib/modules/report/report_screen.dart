import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/report/report_provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Select a vehicle and report type to generate reports.',
                  style: TextStyle(fontSize: 16),
                ),
                // Additional report UI would go here
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReportListScreen extends StatelessWidget {
  final int vehicleId;

  const ReportListScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Refueling'),
              Tab(text: 'Expenses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GeneralReportScreen(vehicleId: vehicleId),
            RefuelingReportScreen(vehicleId: vehicleId),
            ExpenseReportScreen(vehicleId: vehicleId),
          ],
        ),
      ),
    );
  }
}

class GeneralReportScreen extends StatelessWidget {
  final int vehicleId;

  const GeneralReportScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        // Load statistics when the screen is built
        if (reportProvider.generalStats.isEmpty) {
          reportProvider.loadStatistics(vehicleId);
        }

        if (reportProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
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
                      const Text('General Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildStatRow('Total Records', reportProvider.generalStats['totalRecords']?.toString() ?? '0'),
                      _buildStatRow('Total Cost', 'R\$ ${reportProvider.generalStats['totalCost']?.toStringAsFixed(2) ?? '0.00'}'),
                      _buildStatRow('Total Distance', '${reportProvider.generalStats['totalDistance']?.toStringAsFixed(0) ?? '0'} km'),
                      _buildStatRow('Average Daily Cost', 'R\$ ${reportProvider.generalStats['averageDailyCost']?.toStringAsFixed(2) ?? '0.00'}'),
                      _buildStatRow('Cost per Kilometer', 'R\$ ${reportProvider.generalStats['costPerKm']?.toStringAsFixed(2) ?? '0.00'}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Chart placeholder
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cost Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('Chart will be displayed here'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Text(value, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class RefuelingReportScreen extends StatelessWidget {
  final int vehicleId;

  const RefuelingReportScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        // Load statistics when the screen is built
        if (reportProvider.refuelingStats.isEmpty) {
          reportProvider.loadStatistics(vehicleId);
        }

        if (reportProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
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
                      const Text('Refueling Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildStatRow('Total Refuelings', reportProvider.refuelingStats['totalRefuelings']?.toString() ?? '0'),
                      _buildStatRow('Total Cost', 'R\$ ${reportProvider.refuelingStats['totalCost']?.toStringAsFixed(2) ?? '0.00'}'),
                      _buildStatRow('Total Liters', '${reportProvider.refuelingStats['totalLiters']?.toStringAsFixed(2) ?? '0.00'} L'),
                      _buildStatRow('Total Distance', '${reportProvider.refuelingStats['totalDistance']?.toStringAsFixed(0) ?? '0'} km'),
                      _buildStatRow('Average Consumption', '${reportProvider.refuelingStats['averageConsumption']?.toStringAsFixed(2) ?? '0.00'} km/L'),
                      _buildStatRow('Cost per Kilometer', 'R\$ ${reportProvider.refuelingStats['costPerKm']?.toStringAsFixed(2) ?? '0.00'}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Fuel type statistics
              if (reportProvider.refuelingStats['fuelTypeStats'] != null && 
                  (reportProvider.refuelingStats['fuelTypeStats'] as Map).isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('By Fuel Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ..._buildFuelTypeStats(reportProvider.refuelingStats['fuelTypeStats'] as Map<String, dynamic>),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
              
              // Chart placeholder
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Consumption Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('Chart will be displayed here'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFuelTypeStats(Map<String, dynamic> fuelTypeStats) {
    List<Widget> widgets = [];
    
    fuelTypeStats.forEach((fuelType, stats) {
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fuelType, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStatRow('  Total Cost', 'R\$ ${stats['totalCost']?.toStringAsFixed(2) ?? '0.00'}'),
            _buildStatRow('  Total Liters', '${stats['totalLiters']?.toStringAsFixed(2) ?? '0.00'} L'),
            _buildStatRow('  Total Distance', '${stats['totalDistance']?.toStringAsFixed(0) ?? '0'} km'),
            _buildStatRow('  Average Consumption', '${(stats['totalDistance'] / stats['totalLiters'])?.toStringAsFixed(2) ?? '0.00'} km/L'),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
    
    return widgets;
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 1,
            child: Text(value, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class ExpenseReportScreen extends StatelessWidget {
  final int vehicleId;

  const ExpenseReportScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        // Load statistics when the screen is built
        if (reportProvider.expenseStats.isEmpty) {
          reportProvider.loadStatistics(vehicleId);
        }

        if (reportProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
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
                      const Text('Expense Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildStatRow('Total Expenses', reportProvider.expenseStats['totalExpenses']?.toString() ?? '0'),
                      _buildStatRow('Total Cost', 'R\$ ${reportProvider.expenseStats['totalCost']?.toStringAsFixed(2) ?? '0.00'}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Expense type statistics
              if (reportProvider.expenseStats['expenseTypeStats'] != null && 
                  (reportProvider.expenseStats['expenseTypeStats'] as Map).isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('By Expense Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ..._buildExpenseTypeStats(reportProvider.expenseStats['expenseTypeStats'] as Map<String, dynamic>),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
              
              // Chart placeholder
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expense Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('Chart will be displayed here'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildExpenseTypeStats(Map<String, dynamic> expenseTypeStats) {
    List<Widget> widgets = [];
    
    expenseTypeStats.forEach((expenseType, stats) {
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expenseType, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStatRow('  Count', stats['count']?.toString() ?? '0'),
            _buildStatRow('  Total Cost', 'R\$ ${stats['totalCost']?.toStringAsFixed(2) ?? '0.00'}'),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
    
    return widgets;
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 1,
            child: Text(value, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}