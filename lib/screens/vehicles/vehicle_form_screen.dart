import 'package:material_ui/material_ui.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/responsive.dart';
import '../../data/vehicle_repository.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/max_width_container.dart';

/// Screen supporting both Registering a new vehicle and Editing an existing vehicle.
class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormScreen({super.key, this.vehicle});

  bool get isEditMode => vehicle != null;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _plateController;
  late final TextEditingController _vinController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _mileageController;
  late final TextEditingController _driverController;
  late final TextEditingController _notesController;

  late VehicleType _selectedType;
  late VehicleStatus _selectedStatus;
  late String _selectedFuelType;

  final List<String> _fuelOptions = const [
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid',
    'Plug-in Hybrid',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;

    _plateController = TextEditingController(text: v?.plateNumber ?? '');
    _vinController = TextEditingController(text: v?.vin ?? '');
    _makeController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController =
        TextEditingController(text: v != null ? v.year.toString() : '2024');
    _mileageController =
        TextEditingController(text: v != null ? v.mileage.toString() : '0');
    _driverController =
        TextEditingController(text: v?.assignedDriver ?? '');
    _notesController = TextEditingController(text: v?.notes ?? '');

    _selectedType = v?.type ?? VehicleType.sedan;
    _selectedStatus = v?.status ?? VehicleStatus.active;
    _selectedFuelType = v?.fuelType ?? 'Gasoline';
  }

  @override
  void dispose() {
    _plateController.dispose();
    _vinController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _driverController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = VehicleRepositoryScope.of(context);
    final isEdit = widget.isEditMode;

    setState(() => _isSaving = true);

    final vehicle = Vehicle(
      id: isEdit
          ? widget.vehicle!.id
          : '',
      plateNumber: _plateController.text.trim().toUpperCase(),
      vin: _vinController.text.trim().toUpperCase(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      type: _selectedType,
      status: _selectedStatus,
      mileage: int.parse(_mileageController.text.trim()),
      fuelType: _selectedFuelType,
      assignedDriver: _driverController.text.trim().isEmpty
          ? null
          : _driverController.text.trim(),
      lastServiceDate: isEdit ? widget.vehicle!.lastServiceDate : DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      if (isEdit) {
        await repo.updateVehicle(vehicle);
      } else {
        await repo.addVehicle(vehicle);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Vehicle "${vehicle.displayName}" updated successfully.'
                : 'Vehicle "${vehicle.displayName}" registered successfully.',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pushReplacementNamed(AppRoutes.vehicles);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final titleText = widget.isEditMode
        ? 'Edit Vehicle: ${widget.vehicle!.displayName}'
        : 'Register New Vehicle';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: MaxWidthContainer(
          maxWidth: 1000,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation and Header Row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back to Fleet List',
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.vehicles);
                      },
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            widget.isEditMode
                                ? 'Update vehicle records, operational assignment, and status'
                                : 'Add a new asset to corporate fleet inventory',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // Card Section 1: Basic Specifications
                _buildCardSection(
                  title: '1. Vehicle Specification',
                  description: 'Core make, model, year, and powertrain classification',
                  icon: Icons.directions_car_outlined,
                  child: Column(
                    children: [
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Make / Manufacturer *',
                                hint: 'e.g. Toyota, Ford, Tesla',
                                controller: _makeController,
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'Make is required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: _buildTextField(
                                label: 'Model *',
                                hint: 'e.g. Camry, F-150, Model 3',
                                controller: _modelController,
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'Model is required'
                                    : null,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildTextField(
                          label: 'Make / Manufacturer *',
                          hint: 'e.g. Toyota, Ford, Tesla',
                          controller: _makeController,
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Make is required'
                              : null,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        _buildTextField(
                          label: 'Model *',
                          hint: 'e.g. Camry, F-150, Model 3',
                          controller: _modelController,
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Model is required'
                              : null,
                        ),
                      ],
                      const SizedBox(height: AppConstants.spacingMd),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Year *',
                                hint: 'e.g. 2024',
                                controller: _yearController,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Year is required';
                                  }
                                  final year = int.tryParse(val.trim());
                                  if (year == null ||
                                      year < 1980 ||
                                      year > DateTime.now().year + 2) {
                                    return 'Enter valid year (1980-${DateTime.now().year + 2})';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: DropdownButtonFormField<VehicleType>(
                                initialValue: _selectedType,
                                decoration: const InputDecoration(
                                  labelText: 'Body / Vehicle Type *',
                                ),
                                items: VehicleType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Row(
                                      children: [
                                        Icon(type.icon, size: 16),
                                        const SizedBox(width: 8),
                                        Text(type.label),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedType = val);
                                },
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedFuelType,
                                decoration: const InputDecoration(
                                  labelText: 'Powertrain / Fuel *',
                                ),
                                items: _fuelOptions.map((fuel) {
                                  return DropdownMenuItem(
                                    value: fuel,
                                    child: Text(fuel),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedFuelType = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildTextField(
                          label: 'Year *',
                          hint: 'e.g. 2024',
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Year is required';
                            }
                            final year = int.tryParse(val.trim());
                            if (year == null ||
                                year < 1980 ||
                                year > DateTime.now().year + 2) {
                              return 'Enter valid year (1980-${DateTime.now().year + 2})';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        DropdownButtonFormField<VehicleType>(
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Body / Vehicle Type *',
                          ),
                          items: VehicleType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(type.icon, size: 16),
                                  const SizedBox(width: 8),
                                  Text(type.label),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedFuelType,
                          decoration: const InputDecoration(
                            labelText: 'Powertrain / Fuel *',
                          ),
                          items: _fuelOptions.map((fuel) {
                            return DropdownMenuItem(
                              value: fuel,
                              child: Text(fuel),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedFuelType = val);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // Card Section 2: Identification & Legal
                _buildCardSection(
                  title: '2. Identification & Registration',
                  description: 'Government license plate and 17-character VIN identifier',
                  icon: Icons.pin_outlined,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'License Plate Number *',
                                hint: 'e.g. ABC-1029',
                                controller: _plateController,
                                textCapitalization: TextCapitalization.characters,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'License plate is required';
                                  }
                                  final clean = val.trim().toUpperCase();
                                  final repo = VehicleRepositoryScope.of(context);
                                  final duplicate = repo.vehicles.any(
                                    (v) => v.plateNumber.toUpperCase() == clean &&
                                        (!widget.isEditMode || v.id != widget.vehicle?.id),
                                  );
                                  if (duplicate) {
                                    return 'Vehicle with this plate number already exists';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: _buildTextField(
                                label: 'VIN (Vehicle Identification Number) *',
                                hint: '17 characters (e.g. 4T1B11HK5PU102941)',
                                controller: _vinController,
                                textCapitalization: TextCapitalization.characters,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'VIN is required';
                                  }
                                  if (val.trim().length < 8) {
                                    return 'VIN must be at least 8 characters';
                                  }
                                  final clean = val.trim().toUpperCase();
                                  final repo = VehicleRepositoryScope.of(context);
                                  final duplicate = repo.vehicles.any(
                                    (v) => v.vin.toUpperCase() == clean &&
                                        (!widget.isEditMode || v.id != widget.vehicle?.id),
                                  );
                                  if (duplicate) {
                                    return 'Vehicle with this VIN already exists';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildTextField(
                              label: 'License Plate Number *',
                              hint: 'e.g. ABC-1029',
                              controller: _plateController,
                              textCapitalization: TextCapitalization.characters,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'License plate is required';
                                }
                                final clean = val.trim().toUpperCase();
                                final repo = VehicleRepositoryScope.of(context);
                                final duplicate = repo.vehicles.any(
                                  (v) => v.plateNumber.toUpperCase() == clean &&
                                      (!widget.isEditMode || v.id != widget.vehicle?.id),
                                );
                                if (duplicate) {
                                  return 'Vehicle with this plate number already exists';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingMd),
                            _buildTextField(
                              label: 'VIN (Vehicle Identification Number) *',
                              hint: '17 characters (e.g. 4T1B11HK5PU102941)',
                              controller: _vinController,
                              textCapitalization: TextCapitalization.characters,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'VIN is required';
                                }
                                if (val.trim().length < 8) {
                                  return 'VIN must be at least 8 characters';
                                }
                                final clean = val.trim().toUpperCase();
                                final repo = VehicleRepositoryScope.of(context);
                                final duplicate = repo.vehicles.any(
                                  (v) => v.vin.toUpperCase() == clean &&
                                      (!widget.isEditMode || v.id != widget.vehicle?.id),
                                );
                                if (duplicate) {
                                  return 'Vehicle with this VIN already exists';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // Card Section 3: Operations & Assignment
                _buildCardSection(
                  title: '3. Status & Driver Assignment',
                  description: 'Current operational availability and custodian driver',
                  icon: Icons.shield_outlined,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<VehicleStatus>(
                                initialValue: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Operational Status *',
                                ),
                                items: VehicleStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Row(
                                      children: [
                                        Icon(status.icon,
                                            size: 16, color: status.color),
                                        const SizedBox(width: 8),
                                        Text(status.label),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedStatus = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: _buildTextField(
                                label: 'Odometer Mileage (km) *',
                                hint: 'e.g. 24500',
                                controller: _mileageController,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Mileage is required';
                                  }
                                  final mileage = int.tryParse(val.trim());
                                  if (mileage == null || mileage < 0) {
                                    return 'Enter a valid positive number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: _buildTextField(
                                label: 'Assigned Driver',
                                hint: 'e.g. Marcus Vance (or leave blank)',
                                controller: _driverController,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            DropdownButtonFormField<VehicleStatus>(
                              initialValue: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Operational Status *',
                              ),
                              items: VehicleStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Icon(status.icon,
                                          size: 16, color: status.color),
                                      const SizedBox(width: 8),
                                      Text(status.label),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedStatus = val);
                                }
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingMd),
                            _buildTextField(
                              label: 'Odometer Mileage (km) *',
                              hint: 'e.g. 24500',
                              controller: _mileageController,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Mileage is required';
                                }
                                final mileage = int.tryParse(val.trim());
                                if (mileage == null || mileage < 0) {
                                  return 'Enter a valid positive number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingMd),
                            _buildTextField(
                              label: 'Assigned Driver',
                              hint: 'e.g. Marcus Vance (or leave blank)',
                              controller: _driverController,
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // Card Section 4: Notes
                _buildCardSection(
                  title: '4. Service Notes & Log',
                  description: 'Special equipment, upcoming maintenance, or past issues',
                  icon: Icons.notes_outlined,
                  child: _buildTextField(
                    label: 'Additional Notes (Optional)',
                    hint: 'Write any specific maintenance history or vehicle configuration notes...',
                    controller: _notesController,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXl),

                // Form Action Buttons (Bottom toolbar)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.vehicles);
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        ElevatedButton.icon(
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check, size: 18),
                          label: Text(
                            _isSaving
                                ? 'Saving...'
                                : (widget.isEditMode
                                    ? 'Save Changes'
                                    : 'Register Vehicle'),
                          ),
                          onPressed: _isSaving ? null : _saveVehicle,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required String description,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }
}
