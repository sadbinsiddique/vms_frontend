import 'package:material_ui/material_ui.dart';
import '../core/constants/app_colors.dart';

/// Operational status of a vehicle.
enum VehicleStatus {
  active('Active'),
  inMaintenance('In Maintenance'),
  outOfService('Out of Service');

  final String label;
  const VehicleStatus(this.label);

  Color get color {
    switch (this) {
      case VehicleStatus.active:
        return AppColors.success;
      case VehicleStatus.inMaintenance:
        return AppColors.warning;
      case VehicleStatus.outOfService:
        return AppColors.error;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case VehicleStatus.active:
        return AppColors.successLight;
      case VehicleStatus.inMaintenance:
        return AppColors.warningLight;
      case VehicleStatus.outOfService:
        return AppColors.errorLight;
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleStatus.active:
        return Icons.check_circle_outline;
      case VehicleStatus.inMaintenance:
        return Icons.build_circle_outlined;
      case VehicleStatus.outOfService:
        return Icons.error_outline;
    }
  }

  static VehicleStatus fromJson(String value) {
    switch (value.toLowerCase().replaceAll('-', '_')) {
      case 'in_maintenance':
      case 'inmaintenance':
        return VehicleStatus.inMaintenance;
      case 'out_of_service':
      case 'outofservice':
        return VehicleStatus.outOfService;
      case 'active':
      default:
        return VehicleStatus.active;
    }
  }

  String toJson() {
    switch (this) {
      case VehicleStatus.active:
        return 'active';
      case VehicleStatus.inMaintenance:
        return 'in_maintenance';
      case VehicleStatus.outOfService:
        return 'out_of_service';
    }
  }
}

/// Category / Body style of a vehicle.
enum VehicleType {
  sedan('Sedan', Icons.directions_car),
  suv('SUV', Icons.directions_car_filled),
  truck('Truck', Icons.local_shipping),
  van('Van', Icons.airport_shuttle),
  bus('Bus', Icons.directions_bus),
  electric('Electric (EV)', Icons.electric_car);

  final String label;
  final IconData icon;
  const VehicleType(this.label, this.icon);

  static VehicleType fromJson(String value) {
    switch (value.toLowerCase().replaceAll('-', '_')) {
      case 'suv':
        return VehicleType.suv;
      case 'truck':
        return VehicleType.truck;
      case 'van':
        return VehicleType.van;
      case 'bus':
        return VehicleType.bus;
      case 'electric':
      case 'ev':
        return VehicleType.electric;
      case 'sedan':
      default:
        return VehicleType.sedan;
    }
  }

  String toJson() {
    switch (this) {
      case VehicleType.electric:
        return 'electric';
      default:
        return name;
    }
  }
}

/// Key Performance Indicator (KPI) metrics from backend /vehicles/stats.
class VehicleStats {
  final int totalCount;
  final int activeCount;
  final int maintenanceCount;
  final int outOfServiceCount;

  const VehicleStats({
    this.totalCount = 0,
    this.activeCount = 0,
    this.maintenanceCount = 0,
    this.outOfServiceCount = 0,
  });

  factory VehicleStats.fromJson(Map<String, dynamic> json) {
    return VehicleStats(
      totalCount: (json['totalCount'] ?? json['total_count'] ?? 0) as int,
      activeCount: (json['activeCount'] ?? json['active_count'] ?? 0) as int,
      maintenanceCount: (json['maintenanceCount'] ?? json['maintenance_count'] ?? 0) as int,
      outOfServiceCount: (json['outOfServiceCount'] ?? json['out_of_service_count'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'activeCount': activeCount,
      'maintenanceCount': maintenanceCount,
      'outOfServiceCount': outOfServiceCount,
    };
  }
}

/// Core domain model representing a fleet vehicle.
class Vehicle {
  final String id;
  final String plateNumber;
  final String vin;
  final String make;
  final String model;
  final int year;
  final VehicleType type;
  final VehicleStatus status;
  final int mileage;
  final String fuelType;
  final String? assignedDriver;
  final DateTime? lastServiceDate;
  final String? notes;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    required this.status,
    required this.mileage,
    required this.fuelType,
    this.assignedDriver,
    this.lastServiceDate,
    this.notes,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      plateNumber: json['plateNumber']?.toString() ?? json['plate_number']?.toString() ?? '',
      vin: json['vin']?.toString() ?? '',
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      type: VehicleType.fromJson(json['type']?.toString() ?? 'sedan'),
      status: VehicleStatus.fromJson(json['status']?.toString() ?? 'active'),
      mileage: (json['mileage'] as num?)?.toInt() ?? 0,
      fuelType: json['fuelType']?.toString() ?? json['fuel_type']?.toString() ?? 'Gasoline',
      assignedDriver: json['assignedDriver']?.toString() ?? json['assigned_driver']?.toString(),
      lastServiceDate: json['lastServiceDate'] != null
          ? DateTime.tryParse(json['lastServiceDate'].toString())
          : (json['last_service_date'] != null
              ? DateTime.tryParse(json['last_service_date'].toString())
              : null),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'vin': vin,
      'make': make,
      'model': model,
      'year': year,
      'type': type.toJson(),
      'status': status.toJson(),
      'mileage': mileage,
      'fuelType': fuelType,
      if (assignedDriver != null) 'assignedDriver': assignedDriver,
      if (lastServiceDate != null)
        'lastServiceDate':
            '${lastServiceDate!.year.toString().padLeft(4, '0')}-${lastServiceDate!.month.toString().padLeft(2, '0')}-${lastServiceDate!.day.toString().padLeft(2, '0')}',
      if (notes != null) 'notes': notes,
    };
  }

  /// Formatted title (e.g., "2023 Toyota Camry")
  String get displayName => '$year $make $model';

  /// Human-readable formatted mileage (e.g. "24,500 km")
  String get formattedMileage {
    final str = mileage.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()} km';
  }

  /// Formatted last service date (YYYY-MM-DD)
  String get formattedServiceDate {
    if (lastServiceDate == null) return 'N/A';
    final date = lastServiceDate!;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    String? vin,
    String? make,
    String? model,
    int? year,
    VehicleType? type,
    VehicleStatus? status,
    int? mileage,
    String? fuelType,
    String? assignedDriver,
    DateTime? lastServiceDate,
    String? notes,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      vin: vin ?? this.vin,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      type: type ?? this.type,
      status: status ?? this.status,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      notes: notes ?? this.notes,
    );
  }
}
