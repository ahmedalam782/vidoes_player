import 'package:flutter_test/flutter_test.dart';
import 'package:vidoes_player/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app starts
    expect(find.text('Adaptive Video Player'), findsOneWidget);
  });
}
