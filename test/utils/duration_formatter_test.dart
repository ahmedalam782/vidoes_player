import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/youtube_player/utils/duration_formatter.dart';

void main() {
  group('durationFormatter', () {
    test('formats duration less than 1 minute correctly', () {
      // 30 seconds
      expect(durationFormatter(30000), '00:30');
    });

    test('formats duration less than 1 hour correctly', () {
      // 5 minutes 45 seconds
      expect(durationFormatter(345000), '05:45');
    });

    test('formats duration with hours correctly', () {
      // 2 hours 15 minutes 30 seconds
      expect(durationFormatter(8130000), '02:15:30');
    });

    test('formats zero duration correctly', () {
      expect(durationFormatter(0), '00:00');
    });

    test('formats 1 second correctly', () {
      expect(durationFormatter(1000), '00:01');
    });

    test('formats exactly 1 minute correctly', () {
      expect(durationFormatter(60000), '01:00');
    });

    test('formats exactly 1 hour correctly', () {
      expect(durationFormatter(3600000), '01:00:00');
    });

    test('formats large duration correctly', () {
      // 10 hours 59 minutes 59 seconds
      expect(durationFormatter(39599000), '10:59:59');
    });

    test('pads single digits with zero', () {
      // 1 minute 5 seconds
      expect(durationFormatter(65000), '01:05');

      // 5 hours 3 minutes 7 seconds
      expect(durationFormatter(18187000), '05:03:07');
    });

    test('handles milliseconds correctly', () {
      // 1 minute 30 seconds 500 milliseconds
      expect(durationFormatter(90500), '01:30');
    });
  });
}
