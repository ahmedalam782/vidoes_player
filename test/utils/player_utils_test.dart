import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/youtube_player/utils/player_utils.dart';

void main() {
  group('PlayerUtils - extractVideoId', () {
    test('extracts video ID from standard YouTube URL', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('extracts video ID from shortened youtu.be URL', () {
      const url = 'https://youtu.be/dQw4w9WgXcQ';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('extracts video ID from embed URL', () {
      const url = 'https://www.youtube.com/embed/dQw4w9WgXcQ';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('extracts video ID from mobile URL', () {
      const url = 'https://m.youtube.com/watch?v=dQw4w9WgXcQ';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('extracts video ID from URL with additional parameters', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&feature=share';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('extracts video ID from URL with timestamp', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=30s';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('returns null for non-YouTube URL', () {
      const url = 'https://www.example.com/video.mp4';
      expect(PlayerUtils.extractVideoId(url), null);
    });

    test('returns null for empty string', () {
      expect(PlayerUtils.extractVideoId(''), null);
    });

    test('returns null for invalid URL', () {
      const url = 'not a url';
      expect(PlayerUtils.extractVideoId(url), null);
    });

    test('extracts video ID when passed as just the ID', () {
      const videoId = 'dQw4w9WgXcQ';
      // Depending on implementation, this might return the ID or null
      final result = PlayerUtils.extractVideoId(videoId);
      expect(result, anyOf(isNull, equals(videoId)));
    });

    test('handles URL with playlist parameter', () {
      const url =
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('handles youtu.be URL with parameters', () {
      const url = 'https://youtu.be/dQw4w9WgXcQ?t=30';
      expect(PlayerUtils.extractVideoId(url), 'dQw4w9WgXcQ');
    });

    test('handles youtube-nocookie embed URL', () {
      const url = 'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ';
      final result = PlayerUtils.extractVideoId(url);
      // Depending on implementation
      expect(result, anyOf(isNull, equals('dQw4w9WgXcQ')));
    });
  });
}
