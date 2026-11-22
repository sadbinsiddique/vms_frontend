import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import '../core/network/api_client.dart';
import '../models/vehicle_model.dart';

/// Repository managing vehicle state and interacting with the Spring Boot REST backend.
///
/// Implemented as a [ChangeNotifier] so UI components reactively re-render
/// when fleet vehicles are loaded, registered, modified, or removed.
class VehicleRepository extends ChangeNotifier {
  final Dio _dio;
  final List<Vehicle> _vehicles = [];
  VehicleStats _stats = const VehicleStats();
  bool _isLoading = false;
  String? _errorMessage;

  VehicleRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio {
    loadData();
  }

  /// All vehicles currently loaded (unmodifiable).
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  /// Key Performance Indicator (KPI) metrics from backend.
  VehicleStats get stats => _stats;

  /// Whether an API request is actively processing.
  bool get isLoading => _isLoading;

  /// Last error message, if any.
  String? get errorMessage => _errorMessage;

  /// Key Performance Indicator metrics.
  int get totalCount => _stats.totalCount > 0 ? _stats.totalCount : _vehicles.length;
  int get activeCount => _stats.activeCount > 0
      ? _stats.activeCount
      : _vehicles.where((v) => v.status == VehicleStatus.active).length;
  int get maintenanceCount => _stats.maintenanceCount > 0
      ? _stats.maintenanceCount
      : _vehicles.where((v) => v.status == VehicleStatus.inMaintenance).length;
  int get outOfServiceCount => _stats.outOfServiceCount > 0
      ? _stats.outOfServiceCount
      : _vehicles.where((v) => v.status == VehicleStatus.outOfService).length;

  /// Retrieve a vehicle by its unique identifier.
  Vehicle? getById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Loads both vehicles and KPIs from backend APIs in parallel.
  Future<void> loadData({
    String query = '',
    VehicleStatus? status,
    VehicleType? type,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        fetchVehicles(query: query, status: status, type: type, notify: false),
        fetchStats(notify: false),
      ]);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches vehicles from `GET /api/v1/vehicles`.
  Future<void> fetchVehicles({
    String query = '',
    VehicleStatus? status,
    VehicleType? type,
    bool notify = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': 0,
        'size': 100,
        'sort': 'createdAt,desc',
      };

      if (query.trim().isNotEmpty) {
        queryParams['search'] = query.trim();
      }
      if (status != null) {
        queryParams['status'] = status.toJson();
      }
      if (type != null) {
        queryParams['type'] = type.toJson();
      }

      final response = await _dio.get(
        '/vehicles',
        queryParameters: queryParams,
      );

      final data = response.data;
      List<dynamic> items = [];

      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          final pageData = data['data'] as Map<String, dynamic>;
          items = (pageData['content'] as List<dynamic>?) ?? [];
        } else if (data['data'] is List<dynamic>) {
          items = data['data'] as List<dynamic>;
        }
      }

      _vehicles.clear();
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          _vehicles.add(Vehicle.fromJson(item));
        }
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      rethrow;
    } finally {
      if (notify) notifyListeners();
    }
  }

  /// Fetches aggregated KPI stats from `GET /api/v1/vehicles/stats`.
  Future<void> fetchStats({bool notify = true}) async {
    try {
      final response = await _dio.get('/vehicles/stats');
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        _stats = VehicleStats.fromJson(data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      // In case stats endpoint fails, calculate locally from loaded vehicles
      _stats = VehicleStats(
        totalCount: _vehicles.length,
        activeCount: _vehicles.where((v) => v.status == VehicleStatus.active).length,
        maintenanceCount:
            _vehicles.where((v) => v.status == VehicleStatus.inMaintenance).length,
        outOfServiceCount:
            _vehicles.where((v) => v.status == VehicleStatus.outOfService).length,
      );
    } finally {
      if (notify) notifyListeners();
    }
  }

  /// Create a new vehicle on backend via `POST /api/v1/vehicles`.
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        '/vehicles',
        data: vehicle.toJson(),
      );

      final data = response.data;
      Map<String, dynamic> item = {};
      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        item = data['data'] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        item = data;
      }

      final created = Vehicle.fromJson(item);
      _vehicles.insert(0, created);

      // Refresh stats
      await fetchStats(notify: false);

      _errorMessage = null;
      return created;
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      throw _errorMessage!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing vehicle on backend via `PUT /api/v1/vehicles/{id}`.
  Future<Vehicle> updateVehicle(Vehicle updated) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.put(
        '/vehicles/${updated.id}',
        data: updated.toJson(),
      );

      final data = response.data;
      Map<String, dynamic> item = {};
      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        item = data['data'] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        item = data;
      }

      final saved = Vehicle.fromJson(item);
      final index = _vehicles.indexWhere((v) => v.id == saved.id);
      if (index != -1) {
        _vehicles[index] = saved;
      } else {
        _vehicles.insert(0, saved);
      }

      // Refresh stats
      await fetchStats(notify: false);

      _errorMessage = null;
      return saved;
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      throw _errorMessage!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove a vehicle on backend via `DELETE /api/v1/vehicles/{id}`.
  Future<void> deleteVehicle(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dio.delete('/vehicles/$id');
      _vehicles.removeWhere((v) => v.id == id);

      // Refresh stats
      await fetchStats(notify: false);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      throw _errorMessage!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter vehicles locally by search query, status, and type.
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

  /// Reload data from backend.
  void resetToDefault() {
    loadData();
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
