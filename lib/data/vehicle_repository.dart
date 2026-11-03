import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import 'mock_data.dart';

/// In-memory repository managing vehicle state for the VMS frontend foundation.
///
/// Designed as a [ChangeNotifier] so UI components can reactively re-render
/// when vehicles are added, updated, or removed. When connecting to the
/// Spring Boot backend in future phases, this class will be updated to make
/// HTTP/REST API calls.
class VehicleRepository extends ChangeNotifier {
  final List<Vehicle> _vehicles = [];

  VehicleRepository() {
    _initMockData();
  }

  void _initMockData() {
    _vehicles.clear();
    _vehicles.addAll(MockData.initialVehicles);
  }

  /// All vehicles (unmodifiable list).
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  /// Key Performance Indicator (KPI) metrics.
  int get totalCount => _vehicles.length;
  int get activeCount =>
      _vehicles.where((v) => v.status == VehicleStatus.active).length;
  int get maintenanceCount =>
      _vehicles.where((v) => v.status == VehicleStatus.inMaintenance).length;
  int get outOfServiceCount =>
      _vehicles.where((v) => v.status == VehicleStatus.outOfService).length;

  /// Retrieve a vehicle by its unique identifier.
  Vehicle? getById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new vehicle entry.
  void addVehicle(Vehicle vehicle) {
    _vehicles.insert(0, vehicle);
    notifyListeners();
  }

  /// Update an existing vehicle.
  void updateVehicle(Vehicle updated) {
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _vehicles[index] = updated;
      notifyListeners();
    }
  }

  /// Remove a vehicle by its ID.
  void deleteVehicle(String id) {
    _vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  /// Filter vehicles by search query, status, and type.
  List<Vehicle> filter({
    String query = '',
    VehicleStatus? status,
    VehicleType? type,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    return _vehicles.where((vehicle) {
      // 1. Text Search matching plate, make, model, VIN, driver
      if (cleanQuery.isNotEmpty) {
        final matchesPlate = vehicle.plateNumber.toLowerCase().contains(cleanQuery);
        final matchesMake = vehicle.make.toLowerCase().contains(cleanQuery);
        final matchesModel = vehicle.model.toLowerCase().contains(cleanQuery);
        final matchesVin = vehicle.vin.toLowerCase().contains(cleanQuery);
        final matchesDriver =
            (vehicle.assignedDriver ?? '').toLowerCase().contains(cleanQuery);

        if (!matchesPlate &&
            !matchesMake &&
            !matchesModel &&
            !matchesVin &&
            !matchesDriver) {
          return false;
        }
      }

      // 2. Status filter
      if (status != null && vehicle.status != status) {
        return false;
      }

      // 3. Type filter
      if (type != null && vehicle.type != type) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Reset to initial mock data.
  void resetToDefault() {
    _initMockData();
    notifyListeners();
  }
}

/// An [InheritedNotifier] providing [VehicleRepository] down the widget tree.
class VehicleRepositoryScope extends InheritedNotifier<VehicleRepository> {
  const VehicleRepositoryScope({
    super.key,
    required VehicleRepository repository,
    required super.child,
  }) : super(notifier: repository);

  /// Access the repository and subscribe to updates.
  static VehicleRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<VehicleRepositoryScope>();
    assert(
      scope != null,
      'No VehicleRepositoryScope found in context. Ensure MyApp wraps the tree with VehicleRepositoryScope.',
    );
    return scope!.notifier!;
  }
}

