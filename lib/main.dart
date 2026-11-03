import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/vehicle_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VmsApp());
}

/// Root widget for the Vehicle Management System frontend application.
class VmsApp extends StatefulWidget {
  const VmsApp({super.key}); 

  @override
  State<VmsApp> createState() => _VmsAppState();
}

class _VmsAppState extends State<VmsApp> {
  // In-memory vehicle repository holding mock state for the frontend foundation.
  late final VehicleRepository _vehicleRepository;

  @override
  void initState() {
    super.initState();
    _vehicleRepository = VehicleRepository();
  }

  @override
  void dispose() {
    _vehicleRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VehicleRepositoryScope(
      repository: _vehicleRepository,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.initialRoute,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
