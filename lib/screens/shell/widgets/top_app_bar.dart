import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/user_model.dart';
import '../../../widgets/confirmation_dialog.dart';

/// Top header bar for the admin desktop shell.
class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final VoidCallback? onMenuPressed;

  const TopAppBar({
    super.key,
    required this.currentRoute,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.topBarHeight);

  String get _breadcrumbTitle {
    switch (currentRoute) {
      case AppRoutes.vehicles:
        return 'Fleet Management / Vehicles';
      case AppRoutes.vehicleNew:
        return 'Fleet Management / Register New Vehicle';
      case AppRoutes.vehicleEdit:
        return 'Fleet Management / Edit Vehicle';
      default:
        return 'Fleet Management';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      height: AppConstants.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Mobile/Tablet Hamburger Menu button
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: onMenuPressed,
              tooltip: 'Open navigation',
            ),
            const SizedBox(width: AppConstants.spacingSm),
          ],

          // Breadcrumb Title
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.folder_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Flexible(
                  child: Text(
                    _breadcrumbTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Environment Mode Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt,
                  size: 14,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4),
                Text(
                  'Mock Data Mode',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppConstants.spacingMd),

          // Notifications Icon with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                tooltip: 'Notifications',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All fleet alerts are up to date.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: AppConstants.spacingSm),

          // User Profile Quick Actions
          PopupMenuButton<String>(
            tooltip: 'Profile actions',
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryLight,
                  child: const Text(
                    'SC',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    UserModel.mockAdmin.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ],
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                final confirmed = await ConfirmationDialog.show(
                  context,
                  title: 'Sign Out',
                  message: 'Are you sure you want to log out?',
                  confirmLabel: 'Sign Out',
                  confirmColor: AppColors.error,
                  icon: Icons.logout,
                );
                if (confirmed == true && context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UserModel.mockAdmin.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      UserModel.mockAdmin.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
