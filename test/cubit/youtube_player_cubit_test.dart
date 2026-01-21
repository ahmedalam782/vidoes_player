import 'package:flutter_test/flutter_test.dart';
import 'package:videos_player/youtube_player/cubit/youtube_player_cubit.dart';

void main() {
  group('YoutubePlayerCubit', () {
    late YoutubePlayerCubit cubit;

    setUp(() {
      cubit = YoutubePlayerCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has default values', () {
      expect(cubit.state.position, Duration.zero);
      expect(cubit.state.duration, Duration.zero);
      expect(cubit.state.isPlaying, false);
      expect(cubit.state.isMuted, false);
      expect(cubit.state.isFullscreen, false);
      expect(cubit.state.isReady, false);
      expect(cubit.state.autoPlay, false);
      expect(cubit.state.loop, false);
      expect(cubit.state.forceHD, true); // Default is true
      expect(cubit.state.enableCaption, true); // Default is true
      expect(cubit.state.errorMessage, null);
    });

    test('updatePosition updates position', () {
      cubit.updatePosition(const Duration(seconds: 30));
      expect(cubit.state.position, const Duration(seconds: 30));
    });

    test('setPlaying updates playing state', () {
      cubit.setPlaying(true);
      expect(cubit.state.isPlaying, true);
    });

    test('toggleMute toggles mute state', () {
      cubit.toggleMute();
      expect(cubit.state.isMuted, true);

      cubit.toggleMute();
      expect(cubit.state.isMuted, false);
    });

    test('setMuted sets mute state directly', () {
      cubit.setMuted(true);
      expect(cubit.state.isMuted, true);
    });

    test('enterFullscreen updates state correctly', () {
      cubit.enterFullscreen(const Duration(seconds: 45), true);

      expect(cubit.state.isFullscreen, true);
      expect(cubit.state.position, const Duration(seconds: 45));
      expect(cubit.state.isPlaying, true);
    });

    test('exitFullscreen updates state correctly', () {
      cubit.enterFullscreen(const Duration(seconds: 45), true);
      cubit.exitFullscreen(const Duration(seconds: 60), false);

      expect(cubit.state.isFullscreen, false);
      expect(cubit.state.position, const Duration(seconds: 60));
      expect(cubit.state.isPlaying, false);
    });

    test('updateSettings updates all settings', () {
      cubit.updateSettings(
        autoPlay: true,
        loop: true,
        forceHD: true,
        enableCaption: false,
      );

      expect(cubit.state.autoPlay, true);
      expect(cubit.state.loop, true);
      expect(cubit.state.forceHD, true);
      expect(cubit.state.enableCaption, false);
    });

    test('setAutoPlay updates autoPlay setting', () {
      cubit.setAutoPlay(true);
      expect(cubit.state.autoPlay, true);
    });

    test('setLoop updates loop setting', () {
      cubit.setLoop(true);
      expect(cubit.state.loop, true);
    });

    test('setForceHD updates forceHD setting', () {
      cubit.setForceHD(true);
      expect(cubit.state.forceHD, true);
    });

    test('setEnableCaption updates enableCaption setting', () {
      cubit.setEnableCaption(false);
      expect(cubit.state.enableCaption, false);
    });

    test('updateDuration updates duration', () {
      cubit.updateDuration(const Duration(minutes: 5));
      expect(cubit.state.duration, const Duration(minutes: 5));
    });

    test('setReady updates ready state', () {
      cubit.setReady(true);
      expect(cubit.state.isReady, true);
    });

    test('setError sets error message', () {
      cubit.setError('Test error');
      expect(cubit.state.errorMessage, 'Test error');
    });

    test('setError with null clears error message', () {
      cubit.setError('Test error');
      expect(cubit.state.errorMessage, 'Test error');

      cubit.setError(null);
      expect(cubit.state.errorMessage, null);
    });

    group('Complex state changes', () {
      test('multiple state updates work correctly', () {
        cubit.setPlaying(true);
        cubit.updatePosition(const Duration(seconds: 10));
        cubit.setMuted(true);
        cubit.setAutoPlay(true);

        expect(cubit.state.isPlaying, true);
        expect(cubit.state.position, const Duration(seconds: 10));
        expect(cubit.state.isMuted, true);
        expect(cubit.state.autoPlay, true);
      });

      test('fullscreen flow maintains state', () {
        cubit.setPlaying(true);
        cubit.updatePosition(const Duration(seconds: 30));
        cubit.enterFullscreen(const Duration(seconds: 30), true);
        cubit.updatePosition(const Duration(seconds: 60));
        cubit.exitFullscreen(const Duration(seconds: 60), true);

        expect(cubit.state.isPlaying, true);
        expect(cubit.state.position, const Duration(seconds: 60));
        expect(cubit.state.isFullscreen, false);
      });
    });
  });
}
