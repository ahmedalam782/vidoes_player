import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide CurrentPosition;
import 'package:adaptive_video_player/youtube_player/widgets/current_position.dart';

void main() {
  group('CurrentPosition', () {
    late YoutubePlayerController controller;

    setUp(() {
      controller = YoutubePlayerController(
        initialVideoId: 'test12345ab',
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with explicit controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentPosition(controller: controller),
          ),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('disposes listener on widget dispose', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentPosition(controller: controller),
          ),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SizedBox()),
        ),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('listener triggers setState', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentPosition(controller: controller),
          ),
        ),
      );

      // ignore: invalid_use_of_protected_member
      controller.notifyListeners();
      await tester.pump();

      expect(find.text('00:00'), findsOneWidget);
    });
  });
}
