import '../models/vehicle_model.dart';

/// Mock data container - Cleared for live backend integration.
class MockData {
  MockData._();

  /// Mock data has been cleared. The frontend now fetches all vehicle data directly from the backend API.
  static List<Vehicle> get initialVehicles => const [];
}
