import 'package:material_ui/material_ui.dart';
import '../../models/vehicle_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/shell/app_shell_screen.dart';
import '../../screens/vehicles/vehicle_form_screen.dart';
import '../../screens/vehicles/vehicle_list_screen.dart';

/// Centralized application route definitions and route generator.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String vehicles = '/vehicles';
  static const String vehicleNew = '/vehicles/new';
  static const String vehicleEdit = '/vehicles/edit';

  /// Initial entry route of the web application.
  static const String initialRoute = login;

  /// Top-level route generator.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case vehicles:
        return MaterialPageRoute(
          builder: (_) => const AppShellScreen(
            currentRoute: vehicles,
            child: VehicleListScreen(),
          ),
          settings: settings,
        );

      case vehicleNew:
        return MaterialPageRoute(
          builder: (_) => const AppShellScreen(
            currentRoute: vehicleNew,
            child: VehicleFormScreen(),
          ),
          settings: settings,
        );

      case vehicleEdit:
        final vehicle = settings.arguments as Vehicle?;
        return MaterialPageRoute(
          builder: (_) => AppShellScreen(
            currentRoute: vehicleEdit,
            child: VehicleFormScreen(vehicle: vehicle),
          ),
          settings: settings,
        );

      default:
        // Default fallback redirects to the main vehicle inventory screen
        return MaterialPageRoute(
          builder: (_) => const AppShellScreen(
            currentRoute: vehicles,
            child: VehicleListScreen(),
          ),
          settings: settings,
        );
    }
  }
}

