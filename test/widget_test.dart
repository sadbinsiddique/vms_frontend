import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/core/constants/app_constants.dart';
import 'package:vms_frontend/main.dart';

void main() {
  testWidgets('VMS initial load renders Login screen', (WidgetTester tester) async {
    // Build the VMS app and trigger a frame.
    await tester.pumpWidget(const VmsApp());
    await tester.pumpAndSettle();

    // Verify that the login screen header and inputs are rendered.
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Sign In to Dashboard'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
