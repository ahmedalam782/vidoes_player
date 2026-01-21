import 'package:flutter_test/flutter_test.dart';
import 'package:videos_player/main.dart';
import 'package:videos_player/core/dependency_injection/injectable_config.dart';

void main() {
  setUpAll(() async {
    await configureDependencies();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that our app starts
    expect(find.text('Adaptive Video Player'), findsOneWidget);
  });
}
