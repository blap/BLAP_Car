import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';
import 'package:blap_car/modules/vehicle/vehicle_list_screen.dart';
import 'package:blap_car/widgets/custom_app_bar.dart';
import 'package:blap_car/services/recent_activity_service.dart';
import 'package:blap_car/models/recent_activity.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final RecentActivityService _recentActivityService = RecentActivityService();
  List<RecentActivity> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentActivities();
  }

  Future<void> _loadRecentActivities() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final activities = await _recentActivityService.getRecentActivities(limit: 10);
      setState(() {
        _recentActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error silently or show a message
      debugPrint('Error loading recent activities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'BLAP Car Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        onVehicleTap: () {
          // Navigate to vehicle selection
          Navigator.pushNamed(context, '/vehicles');
        },
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          // Load vehicles if not already loaded, but not during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vehicleProvider.vehicles.isEmpty) {
              vehicleProvider.loadVehicles();
            }
          });
          
          // If no vehicles are registered, show a special message
          if (vehicleProvider.vehicles.isEmpty) {
            return _buildNoVehiclesView(context);
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to BLAP Car',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Manage your vehicle fleet efficiently with our comprehensive solution.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                
                // Quick actions section
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Use Column with IntrinsicWidth to prevent buttons from disappearing
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate directly to add refueling screen
                          Navigator.pushNamed(context, '/add-refueling');
                        },
                        icon: const Icon(Icons.local_gas_station),
                        label: const Text('Add Refueling'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate directly to add expense screen
                          Navigator.pushNamed(context, '/add-expense');
                        },
                        icon: const Icon(Icons.attach_money),
                        label: const Text('Add Expense'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate directly to add reminder screen
                          Navigator.pushNamed(context, '/add-reminder');
                        },
                        icon: const Icon(Icons.notifications),
                        label: const Text('Add Reminder'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate directly to add vehicle screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddVehicleScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions_car),
                        label: const Text('Add Vehicle'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Reports section
                const Text(
                  'Reports',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to reports screen
                        Navigator.pushNamed(context, '/report');
                      },
                      child: const Text('View Reports'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to reports screen
                        Navigator.pushNamed(context, '/report');
                      },
                      child: const Text('Generate Report'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Recent Activities section (replacing "Your Vehicles")
                const Text(
                  'Recent Activities',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _recentActivities.isEmpty
                          ? const Center(
                              child: Text(
                                'No recent activities found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _recentActivities.length,
                              itemBuilder: (context, index) {
                                final activity = _recentActivities[index];
                                return ListTile(
                                  title: Text(activity.description),
                                  subtitle: Text(
                                    '${activity.vehicleName} • ${activity.type}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${activity.date.day}/${activity.date.month}/${activity.date.year}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      if (activity.cost != null)
                                        Text(
                                          '\$${activity.cost!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildNoVehiclesView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Welcome to BLAP Car',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'To get started, please register your first vehicle.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Illustration or icon
          const Icon(
            Icons.directions_car,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 32),
          
          // Add Vehicle button
          ElevatedButton.icon(
            onPressed: () {
              // Navigate directly to add vehicle screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddVehicleScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Vehicle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          
          // Information text
          const Text(
            'After adding a vehicle, you can record refueling, expenses, and set reminders for maintenance.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Reports section
          const Text(
            'Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: null, // Disabled when no vehicles
                child: const Text('View Reports'),
              ),
              ElevatedButton(
                onPressed: null, // Disabled when no vehicles
                child: const Text('Generate Report'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Recent Activities section
          const Text(
            'Recent Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recentActivities.isEmpty
                    ? const Center(
                        child: Text(
                          'No recent activities found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _recentActivities.length,
                        itemBuilder: (context, index) {
                          final activity = _recentActivities[index];
                          return ListTile(
                            title: Text(activity.description),
                            subtitle: Text(
                              '${activity.vehicleName} • ${activity.type}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${activity.date.day}/${activity.date.month}/${activity.date.year}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (activity.cost != null)
                                  Text(
                                    '\$${activity.cost!.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}