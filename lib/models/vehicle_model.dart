import 'package:flutter/material.dart';
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

