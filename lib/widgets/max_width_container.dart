import 'package:material_ui/material_ui.dart';
import '../core/constants/app_constants.dart';

/// Wraps desktop content to enforce comfortable max-width constraints on ultra-wide screens.
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = AppConstants.maxContentWidth,
    this.padding = const EdgeInsets.all(AppConstants.spacingLg),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

