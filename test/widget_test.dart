import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trip_buddy/app.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TripBuddyApp(),
      ),
    );

    // Verify that the app renders with TripBuddy branding
    expect(find.text('TripBuddy'), findsOneWidget);
  });
}
