import 'package:material_ui/material_ui.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'data/vehicle_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const VmsApp());
}

/// Root widget for the Vehicle Management System frontend application.
class VmsApp extends StatefulWidget {
  const VmsApp({super.key});

  @override
  State<VmsApp> createState() => _VmsAppState();
}

class _VmsAppState extends State<VmsApp> {
  // Vehicle repository bound to backend REST APIs.
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
