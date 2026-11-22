import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/hive_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../models/user_model.dart';
import '../../../widgets/confirmation_dialog.dart';

/// Navigation item descriptor.
class NavItem {
  final String title;
  final IconData icon;
  final String route;
  final bool isEnabled;
  final String? badge;

  const NavItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isEnabled = true,
    this.badge,
  });
}

/// Desktop-first sidebar navigation drawer.
class SideNavigation extends StatelessWidget {
  final String currentRoute;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const SideNavigation({
    super.key,
    required this.currentRoute,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  static const List<NavItem> navItems = [
    NavItem(
      title: 'Fleet Vehicles',
      icon: Icons.directions_car_filled,
      route: AppRoutes.vehicles,
    ),
    NavItem(
      title: 'Register Vehicle',
      icon: Icons.add_circle_outline,
      route: AppRoutes.vehicleNew,
    ),
    NavItem(
      title: 'Drivers',
      icon: Icons.badge_outlined,
      route: '/drivers',
      isEnabled: false,
      badge: 'Soon',
    ),
    NavItem(
      title: 'Maintenance',
      icon: Icons.build_circle_outlined,
      route: '/maintenance',
      isEnabled: false,
      badge: 'Soon',
    ),
    NavItem(
      title: 'Analytics',
      icon: Icons.insights_outlined,
      route: '/analytics',
      isEnabled: false,
      badge: 'Soon',
    ),
  ];

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to log out of the VMS Admin Portal?',
      confirmLabel: 'Sign Out',
      confirmColor: AppColors.error,
      icon: Icons.logout,
    );

    if (confirmed == true && context.mounted) {
      await AuthService().logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = isCollapsed
        ? AppConstants.sidebarWidthCollapsed
        : AppConstants.sidebarWidthExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sidebar Brand Header
          Container(
            height: AppConstants.topBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: AppConstants.spacingSm),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VMS FLEET',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Admin Portal',
                          style: TextStyle(
                            color: AppColors.sidebarText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingMd),

          // 2. Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingSm,
              ),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isActive = currentRoute == item.route ||
                    (item.route == AppRoutes.vehicles &&
                        currentRoute == AppRoutes.vehicleEdit);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      onTap: () {
                        if (!item.isEnabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${item.title} module is part of the next development phase.',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        if (currentRoute != item.route) {
                          Navigator.of(context).pushReplacementNamed(item.route);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCollapsed ? 12 : 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.sidebarActiveItem
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                          border: isActive
                              ? const Border(
                                  left: BorderSide(
                                    color: AppColors.primary,
                                    width: 3,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isActive
                                  ? Colors.white
                                  : item.isEnabled
                                      ? AppColors.sidebarText
                                      : AppColors.sidebarText.withValues(alpha: 0.4),
                            ),
                            if (!isCollapsed) ...[
                              const SizedBox(width: AppConstants.spacingMd),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : item.isEnabled
                                            ? AppColors.sidebarText
                                            : AppColors.sidebarText.withValues(alpha: 0.4),
                                    fontSize: 13,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.badge != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.badge!,
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. User Profile Footer
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: Builder(
              builder: (context) {
                final currentUser = HiveService.instance.getUser() ?? UserModel.mockAdmin;
                final initials = currentUser.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join();

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initials.isNotEmpty ? initials : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: AppConstants.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentUser.role,
                              style: const TextStyle(
                                color: AppColors.sidebarText,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.sidebarText,
                          size: 18,
                        ),
                        tooltip: 'Sign Out',
                        onPressed: () => _handleLogout(context),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

