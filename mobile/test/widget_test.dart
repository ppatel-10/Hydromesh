import 'package:flutter_test/flutter_test.dart';

import 'package:hydromesh/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HydroMeshApp());
    // Just verify the app boots without crashing
    expect(find.byType(HydroMeshApp), findsOneWidget);
  });
}
