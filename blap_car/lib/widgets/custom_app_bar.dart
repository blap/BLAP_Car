import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onVehicleTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onVehicleTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Consumer<VehicleProvider>(
            builder: (context, vehicleProvider, child) {
              if (vehicleProvider.activeVehicle != null) {
                return GestureDetector(
                  onTap: onVehicleTap,
                  child: Text(
                    vehicleProvider.activeVehicle!.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}