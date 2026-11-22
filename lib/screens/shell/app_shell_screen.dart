import 'package:material_ui/material_ui.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'widgets/side_navigation.dart';
import 'widgets/top_app_bar.dart';

/// Application shell providing the persistent desktop sidebar, top header,
/// and responsive content canvas for authenticated screens.
class AppShellScreen extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppShellScreen({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    // Desktop Layout (Persistent Sidebar + Content Area)
    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            SideNavigation(
              currentRoute: widget.currentRoute,
              isCollapsed: _isSidebarCollapsed,
              onToggleCollapse: _toggleSidebar,
            ),
            Expanded(
              child: Column(
                children: [
                  TopAppBar(
                    currentRoute: widget.currentRoute,
                  ),
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Tablet & Mobile Layout (Drawer Navigation)
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: TopAppBar(
        currentRoute: widget.currentRoute,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: Drawer(
        elevation: 0,
        child: SideNavigation(
          currentRoute: widget.currentRoute,
          isCollapsed: false,
        ),
      ),
      body: widget.child,
    );
  }
}

