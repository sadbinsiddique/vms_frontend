import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/responsive.dart';
import '../../data/vehicle_repository.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/max_width_container.dart';
import '../../widgets/vehicle_stat_card.dart';
import '../../widgets/vehicle_status_badge.dart';

/// Desktop-first screen displaying the fleet list, KPI summaries, and search/filter tools.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  VehicleStatus? _selectedStatus;
  VehicleType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedType = null;
    });
  }

  Future<void> _handleDelete(BuildContext context, Vehicle vehicle) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Vehicle',
      message:
          'Are you sure you want to remove ${vehicle.displayName} (${vehicle.plateNumber}) from the fleet? This operation cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: AppColors.error,
      icon: Icons.delete_outline,
    );

    if (confirmed == true && context.mounted) {
      VehicleRepositoryScope.of(context).deleteVehicle(vehicle.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${vehicle.displayName} has been removed.'),
          backgroundColor: AppColors.textPrimary,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = VehicleRepositoryScope.of(context);
    final isDesktop = Responsive.isDesktop(context);

    // Get filtered list based on current UI state
    final filteredVehicles = repository.filter(
      query: _searchController.text,
      status: _selectedStatus,
      type: _selectedType,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: MaxWidthContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Page Header (Title, Subtitle & Primary CTA)
              _buildPageHeader(context, isDesktop),
              const SizedBox(height: AppConstants.spacingLg),

              // 2. Metric / KPI Stat Cards
              _buildMetricCards(repository, isDesktop),
              const SizedBox(height: AppConstants.spacingLg),

              // 3. Search and Filter Controls Card
              _buildSearchFilterToolbar(isDesktop),
              const SizedBox(height: AppConstants.spacingMd),

              // 4. Vehicles Data Table or Mobile Cards
              if (filteredVehicles.isEmpty)
                _buildEmptyState(context)
              else if (isDesktop)
                _buildDesktopTable(context, filteredVehicles)
              else
                _buildMobileCardList(context, filteredVehicles),

              const SizedBox(height: AppConstants.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isDesktop) {
    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Fleet Inventory',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monitor, filter, and manage corporate vehicle records',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Register Vehicle'),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.vehicleNew);
            },
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fleet Inventory',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Monitor, filter, and manage all corporate vehicle records and statuses',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Register Vehicle'),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.vehicleNew);
          },
        ),
      ],
    );
  }

  Widget _buildMetricCards(VehicleRepository repository, bool isDesktop) {
    final cards = [
      VehicleStatCard(
        title: 'Total Fleet',
        value: repository.totalCount.toString(),
        icon: Icons.directions_car_filled,
        accentColor: AppColors.primary,
        subtitle: 'All assets on record',
      ),
      VehicleStatCard(
        title: 'Active Vehicles',
        value: repository.activeCount.toString(),
        icon: Icons.check_circle_outline,
        accentColor: AppColors.success,
        subtitle: 'Ready for dispatch',
      ),
      VehicleStatCard(
        title: 'In Maintenance',
        value: repository.maintenanceCount.toString(),
        icon: Icons.build_circle_outlined,
        accentColor: AppColors.warning,
        subtitle: 'Servicing & inspections',
      ),
      VehicleStatCard(
        title: 'Out of Service',
        value: repository.outOfServiceCount.toString(),
        icon: Icons.error_outline,
        accentColor: AppColors.error,
        subtitle: 'Decommissioned / repairs',
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map(
              (card) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: card,
                ),
              ),
            )
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 500 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: cards,
        );
      },
    );
  }

  Widget _buildSearchFilterToolbar(bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: isDesktop
            ? Row(
                children: [
                  // Search Input
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by make, model, plate, VIN or driver...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),

                  // Status Filter Dropdown
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<VehicleStatus?>(
                      key: ValueKey('status_filter_desktop_$_selectedStatus'),
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.filter_alt_outlined, size: 20),
                      ),
                      items: [
                        const DropdownMenuItem<VehicleStatus?>(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        ...VehicleStatus.values.map(
                          (status) => DropdownMenuItem<VehicleStatus?>(
                            value: status,
                            child: Text(status.label),
                          ),
                        ),
                      ],
                      onChanged: (status) {
                        setState(() => _selectedStatus = status);
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),

                  // Type Filter Dropdown
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<VehicleType?>(
                      key: ValueKey('type_filter_desktop_$_selectedType'),
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        prefixIcon: Icon(Icons.category_outlined, size: 20),
                      ),
                      items: [
                        const DropdownMenuItem<VehicleType?>(
                          value: null,
                          child: Text('All Types'),
                        ),
                        ...VehicleType.values.map(
                          (type) => DropdownMenuItem<VehicleType?>(
                            value: type,
                            child: Row(
                              children: [
                                Icon(type.icon, size: 16),
                                const SizedBox(width: 8),
                                Text(type.label),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (type) {
                        setState(() => _selectedType = type);
                      },
                    ),
                  ),

                  // Reset Filters Button
                  if (_searchController.text.isNotEmpty ||
                      _selectedStatus != null ||
                      _selectedType != null) ...[
                    const SizedBox(width: AppConstants.spacingMd),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.filter_list_off, size: 18),
                      label: const Text('Reset'),
                      onPressed: _clearFilters,
                    ),
                  ],
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search plate, make, model...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<VehicleStatus?>(
                          key: ValueKey('status_filter_mobile_$_selectedStatus'),
                          initialValue: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: [
                            const DropdownMenuItem<VehicleStatus?>(
                              value: null,
                              child: Text('All'),
                            ),
                            ...VehicleStatus.values.map(
                              (status) => DropdownMenuItem<VehicleStatus?>(
                                value: status,
                                child: Text(status.label),
                              ),
                            ),
                          ],
                          onChanged: (status) {
                            setState(() => _selectedStatus = status);
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Expanded(
                        child: DropdownButtonFormField<VehicleType?>(
                          key: ValueKey('type_filter_mobile_$_selectedType'),
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                          ),
                          items: [
                            const DropdownMenuItem<VehicleType?>(
                              value: null,
                              child: Text('All'),
                            ),
                            ...VehicleType.values.map(
                              (type) => DropdownMenuItem<VehicleType?>(
                                value: type,
                                child: Text(type.label),
                              ),
                            ),
                          ],
                          onChanged: (type) {
                            setState(() => _selectedType = type);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Vehicle> vehicles) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('VEHICLE')),
            DataColumn(label: Text('PLATE & VIN')),
            DataColumn(label: Text('TYPE')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('MILEAGE')),
            DataColumn(label: Text('ASSIGNED DRIVER')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: vehicles.map((vehicle) {
            return DataRow(
              cells: [
                // Vehicle Name and Year
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${vehicle.year}  *  ${vehicle.fuelType}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Plate & VIN
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.plateNumber,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        vehicle.vin,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Vehicle Type with Icon
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        vehicle.type.icon,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(vehicle.type.label),
                    ],
                  ),
                ),

                // Status Badge
                DataCell(
                  VehicleStatusBadge(status: vehicle.status),
                ),

                // Mileage
                DataCell(
                  Text(vehicle.formattedMileage),
                ),

                // Assigned Driver
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        vehicle.assignedDriver ?? 'Unassigned',
                        style: TextStyle(
                          color: vehicle.assignedDriver != null
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontStyle: vehicle.assignedDriver == null
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Edit Vehicle',
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.vehicleEdit,
                            arguments: vehicle,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                        tooltip: 'Delete Vehicle',
                        onPressed: () => _handleDelete(context, vehicle),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileCardList(BuildContext context, List<Vehicle> vehicles) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vehicles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    VehicleStatusBadge(status: vehicle.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Plate: ${vehicle.plateNumber}  *  VIN: ${vehicle.vin}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mileage: ${vehicle.formattedMileage}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      vehicle.assignedDriver ?? 'Unassigned',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.vehicleEdit,
                          arguments: vehicle,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => _handleDelete(context, vehicle),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: 56,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 32,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            const Text(
              'No Vehicles Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            const Text(
              'Try clearing your search query or status filter to see all fleet assets.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear Filters'),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Register New Vehicle'),
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.vehicleNew);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
