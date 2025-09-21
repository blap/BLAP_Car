import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
              
              // Cost Distribution Chart
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
                        child: _buildCostDistributionChart(context, reportProvider),
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

  Widget _buildCostDistributionChart(BuildContext context, ReportProvider reportProvider) {
    // Get cost data from different sources
    final double refuelingCost = (reportProvider.refuelingStats['totalCost'] as double?) ?? 0.0;
    final double expenseCost = (reportProvider.expenseStats['totalCost'] as double?) ?? 0.0;
    final double maintenanceCost = (reportProvider.maintenanceStats['totalCost'] as double?) ?? 0.0;
    
    final totalCost = refuelingCost + expenseCost + maintenanceCost;
    
    if (totalCost <= 0) {
      return Center(
        child: Text(
          'No cost data available for chart',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    // Prepare data for the pie chart
    List<PieChartSectionData> sections = [];
    final colors = [Colors.blue, Colors.green, Colors.orange];
    
    if (refuelingCost > 0) {
      sections.add(
        PieChartSectionData(
          value: refuelingCost,
          title: 'Refueling\n${(refuelingCost/totalCost*100).toStringAsFixed(1)}%',
          color: colors[0],
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    if (expenseCost > 0) {
      sections.add(
        PieChartSectionData(
          value: expenseCost,
          title: 'Expenses\n${(expenseCost/totalCost*100).toStringAsFixed(1)}%',
          color: colors[1],
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    if (maintenanceCost > 0) {
      sections.add(
        PieChartSectionData(
          value: maintenanceCost,
          title: 'Maintenance\n${(maintenanceCost/totalCost*100).toStringAsFixed(1)}%',
          color: colors[2],
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        // Make the chart responsive to touch
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
        ),
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
              
              // Fuel Consumption Trend Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fuel Consumption Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildConsumptionChart(context, reportProvider),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cost per Liter Trend Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cost per Liter Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildCostPerLiterChart(context, reportProvider),
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

  Widget _buildConsumptionChart(BuildContext context, ReportProvider reportProvider) {
    if (reportProvider.fuelConsumptionTrend.isEmpty) {
      return Center(
        child: Text(
          'No refueling data available for chart',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    // Prepare data for the line chart
    List<FlSpot> spots = [];
    for (int i = 0; i < reportProvider.fuelConsumptionTrend.length; i++) {
      final dataPoint = reportProvider.fuelConsumptionTrend[i];
      // Using index as x-axis value for simplicity
      spots.add(FlSpot(i.toDouble(), dataPoint['consumption'].toDouble()));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget _buildCostPerLiterChart(BuildContext context, ReportProvider reportProvider) {
    if (reportProvider.costPerLiterTrend.isEmpty) {
      return Center(
        child: Text(
          'No refueling data available for chart',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    // Prepare data for the line chart
    List<FlSpot> spots = [];
    for (int i = 0; i < reportProvider.costPerLiterTrend.length; i++) {
      final dataPoint = reportProvider.costPerLiterTrend[i];
      // Using index as x-axis value for simplicity
      spots.add(FlSpot(i.toDouble(), dataPoint['costPerLiter'].toDouble()));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
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
              
              // Expense Trend Chart
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
                        child: _buildExpenseTrendChart(context, reportProvider),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Expense Type Distribution Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expense Type Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildExpenseTypeDistributionChart(context, reportProvider),
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

  Widget _buildExpenseTrendChart(BuildContext context, ReportProvider reportProvider) {
    if (reportProvider.expenseTrend.isEmpty) {
      return Center(
        child: Text(
          'No expense data available for chart',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    // Prepare data for the line chart
    List<FlSpot> spots = [];
    for (int i = 0; i < reportProvider.expenseTrend.length; i++) {
      final dataPoint = reportProvider.expenseTrend[i];
      // Using index as x-axis value for simplicity
      spots.add(FlSpot(i.toDouble(), dataPoint['totalCost'].toDouble()));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget _buildExpenseTypeDistributionChart(BuildContext context, ReportProvider reportProvider) {
    if (reportProvider.expenseTypeDistribution.isEmpty) {
      return Center(
        child: Text(
          'No expense data available for chart',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    // Prepare data for the pie chart
    List<PieChartSectionData> sections = [];
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];
    int colorIndex = 0;
    
    reportProvider.expenseTypeDistribution.forEach((type, cost) {
      sections.add(
        PieChartSectionData(
          value: cost,
          title: type,
          color: colors[colorIndex % colors.length],
        ),
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
      ),
    );
  }
}
