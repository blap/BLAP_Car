import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/database/maintenance_dao.dart';
import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/database/refueling_dao.dart';

class MaintenanceSchedulingService {
  final MaintenanceDao _maintenanceDao = MaintenanceDao();
  final VehicleDao _vehicleDao = VehicleDao();
  final RefuelingDao _refuelingDao = RefuelingDao();

  // Get recommended maintenance intervals based on maintenance type
  Map<String, Map<String, dynamic>> getMaintenanceIntervals() {
    return {
      'Oil Change': {
        'kmInterval': 5000,
        'timeInterval': const Duration(days: 180), // 6 months
      },
      'Tire Rotation': {
        'kmInterval': 10000,
        'timeInterval': const Duration(days: 365), // 1 year
      },
      'Brake Check': {
        'kmInterval': 20000,
        'timeInterval': const Duration(days: 365), // 1 year
      },
      'Air Filter': {
        'kmInterval': 30000,
        'timeInterval': const Duration(days: 365), // 1 year
      },
      'Transmission Fluid': {
        'kmInterval': 60000,
        'timeInterval': const Duration(days: 730), // 2 years
      },
      'Coolant Flush': {
        'kmInterval': 50000,
        'timeInterval': const Duration(days: 730), // 2 years
      },
      'Spark Plugs': {
        'kmInterval': 40000,
        'timeInterval': const Duration(days: 730), // 2 years
      },
      'Timing Belt': {
        'kmInterval': 100000,
        'timeInterval': const Duration(days: 1460), // 4 years
      },
      'Inspection': {
        'kmInterval': 15000,
        'timeInterval': const Duration(days: 365), // 1 year
      },
    };
  }

  // Calculate next maintenance date based on last maintenance and vehicle usage
  Future<DateTime?> calculateNextMaintenanceDate(
    int vehicleId,
    String maintenanceType,
    DateTime lastMaintenanceDate,
    int? lastOdometer,
  ) async {
    final intervals = getMaintenanceIntervals();
    if (!intervals.containsKey(maintenanceType)) {
      return null;
    }

    final kmInterval = intervals[maintenanceType]?['kmInterval'] as int?;
    final timeInterval = intervals[maintenanceType]?['timeInterval'] as Duration?;

    DateTime? nextDateByTime;
    if (timeInterval != null) {
      nextDateByTime = lastMaintenanceDate.add(timeInterval);
    }

    DateTime? nextDateByKm;
    if (kmInterval != null && lastOdometer != null) {
      final predictedOdometer = lastOdometer + kmInterval;
      final predictedDate = await _predictDateForOdometer(vehicleId, predictedOdometer);
      if (predictedDate != null) {
        nextDateByKm = predictedDate;
      }
    }

    // Return the earlier of the two dates
    if (nextDateByTime != null && nextDateByKm != null) {
      return nextDateByTime.isBefore(nextDateByKm) ? nextDateByTime : nextDateByKm;
    }

    return nextDateByTime ?? nextDateByKm;
  }

  // Predict date when vehicle will reach a certain odometer reading
  Future<DateTime?> _predictDateForOdometer(int vehicleId, int targetOdometer) async {
    // Get recent refuelings to analyze usage pattern
    final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
    
    if (refuelings.isEmpty) {
      return null;
    }

    // Sort refuelings by date
    refuelings.sort((a, b) => a.date.compareTo(b.date));

    // Calculate average km per day over the last 30 refuelings or all if less than 30
    final recentRefuelings = refuelings.length > 30 ? refuelings.skip(refuelings.length - 30).toList() : refuelings;
    
    if (recentRefuelings.length < 2) {
      return null;
    }

    final firstRefueling = recentRefuelings.first;
    final lastRefueling = recentRefuelings.last;
    
    // Get the latest odometer reading
    final latestOdometer = lastRefueling.odometer;
    final latestDate = lastRefueling.date;
    
    if (latestOdometer >= targetOdometer) {
      return null;
    }

    // Calculate average km per day
    final daysBetween = latestDate.difference(firstRefueling.date).inDays;
    if (daysBetween <= 0) {
      return null;
    }
    
    final kmDifference = latestOdometer - firstRefueling.odometer;
    final avgKmPerDay = kmDifference / daysBetween;

    if (avgKmPerDay <= 0) {
      return null;
    }

    // Calculate days needed to reach target odometer
    final kmNeeded = targetOdometer - latestOdometer;
    final daysNeeded = (kmNeeded / avgKmPerDay).round();

    // Predict the date
    return latestDate.add(Duration(days: daysNeeded));
  }

  // Get upcoming maintenances for a vehicle
  Future<List<Maintenance>> getUpcomingMaintenances(int vehicleId, {int days = 30}) async {
    final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return maintenances.where((maintenance) {
      return maintenance.nextDate != null &&
          maintenance.nextDate!.isAfter(now) &&
          maintenance.nextDate!.isBefore(futureDate);
    }).toList();
  }

  // Get overdue maintenances for a vehicle
  Future<List<Maintenance>> getOverdueMaintenances(int vehicleId) async {
    final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);
    final now = DateTime.now();

    return maintenances.where((maintenance) {
      return maintenance.nextDate != null &&
          maintenance.nextDate!.isBefore(now) &&
          (maintenance.status == null || 
           (maintenance.status != 'Completed' && maintenance.status != 'Cancelled'));
    }).toList();
  }

  // Suggest next maintenance based on vehicle history
  Future<Maintenance?> suggestNextMaintenance(int vehicleId) async {
    final vehicle = await _vehicleDao.getVehicleById(vehicleId);
    if (vehicle == null) {
      return null;
    }

    final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);
    if (maintenances.isEmpty) {
      // If no maintenance history, suggest an initial inspection
      return Maintenance(
        vehicleId: vehicleId,
        type: 'Inspection',
        description: 'Initial vehicle inspection',
        status: 'Scheduled',
      );
    }

    // Sort maintenances by date to find the most recent
    maintenances.sort((a, b) {
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    final latestMaintenance = maintenances.first;
    
    // If the latest maintenance doesn't have a nextDate, calculate one
    if (latestMaintenance.nextDate == null && latestMaintenance.type != null) {
      final nextDate = await calculateNextMaintenanceDate(
        vehicleId,
        latestMaintenance.type!,
        latestMaintenance.date ?? DateTime.now(),
        latestMaintenance.odometer,
      );
      
      if (nextDate != null) {
        return Maintenance(
          vehicleId: vehicleId,
          type: latestMaintenance.type,
          description: 'Scheduled maintenance based on previous service',
          nextDate: nextDate,
          status: 'Scheduled',
        );
      }
    }

    return null;
  }

  // Automatically schedule maintenance based on intervals
  Future<void> autoScheduleMaintenance(int vehicleId) async {
    final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);
    final intervals = getMaintenanceIntervals();
    
    // For each maintenance type with defined intervals
    for (final entry in intervals.entries) {
      final maintenanceType = entry.key;
      final kmInterval = entry.value['kmInterval'] as int;
      
      // Find the most recent maintenance of this type
      final typeMaintenances = maintenances
          .where((m) => m.type == maintenanceType)
          .toList();
      
      if (typeMaintenances.isEmpty) {
        // No maintenance of this type yet, suggest initial
        final suggestedMaintenance = await suggestNextMaintenance(vehicleId);
        if (suggestedMaintenance != null && suggestedMaintenance.type == maintenanceType) {
          // Add the suggested maintenance
          await _maintenanceDao.insertMaintenance(suggestedMaintenance);
        }
        continue;
      }
      
      // Sort by date to get the most recent
      typeMaintenances.sort((a, b) {
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });
      
      final latest = typeMaintenances.first;
      
      // Check if it's time for the next maintenance
      if (latest.odometer != null && latest.date != null) {
        final vehicle = await _vehicleDao.getVehicleById(vehicleId);
        if (vehicle != null) {
          // Get the latest odometer from refueling records
          final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
          double? currentOdometer;
          if (refuelings.isNotEmpty) {
            refuelings.sort((a, b) => b.date.compareTo(a.date));
            currentOdometer = refuelings.first.odometer;
          }
          
          // If current odometer is significantly higher than last maintenance, schedule next
          if (currentOdometer != null && currentOdometer >= latest.odometer! + kmInterval) {
            
            final nextDate = await calculateNextMaintenanceDate(
              vehicleId,
              maintenanceType,
              latest.date ?? DateTime.now(),
              latest.odometer,
            );
            
            // Check if there's already a scheduled maintenance of this type
            final hasScheduled = maintenances.any((m) => 
                m.type == maintenanceType && 
                m.status == 'Scheduled' && 
                m.nextDate != null);
            
            if (!hasScheduled) {
              final nextMaintenance = Maintenance(
                vehicleId: vehicleId,
                type: maintenanceType,
                description: 'Automatically scheduled based on odometer interval',
                nextDate: nextDate,
                status: 'Scheduled',
              );
              
              await _maintenanceDao.insertMaintenance(nextMaintenance);
            }
          }
        }
      }
    }
  }
}