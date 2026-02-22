import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:adaptive_video_player/youtube_player/utils/player_utils.dart';

class MockYoutubePlayerController extends Mock
    implements YoutubePlayerController {}

class MockYoutubePlayerValue extends Mock implements YoutubePlayerValue {}

class MockYoutubeMetaData extends Mock implements YoutubeMetaData {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(Duration.zero);
  });

  group('PlayerUtils Methods', () {
    late MockYoutubePlayerController controller;
    late MockYoutubePlayerValue mockValue;
    late MockYoutubeMetaData mockMetadata;

    setUp(() {
      controller = MockYoutubePlayerController();
      mockValue = MockYoutubePlayerValue();
      mockMetadata = MockYoutubeMetaData();

      when(() => controller.value).thenReturn(mockValue);
      when(() => controller.metadata).thenReturn(mockMetadata);
    });

    // ──────────── seekForward ────────────
    test('seekForward advances position', () {
      when(() => mockValue.position).thenReturn(const Duration(seconds: 10));
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 60));
      when(() => controller.seekTo(any())).thenReturn(null);

      PlayerUtils.seekForward(controller);

      verify(() => controller.seekTo(const Duration(seconds: 20))).called(1);
    });

    test('seekForward clamps to duration', () {
      when(() => mockValue.position).thenReturn(const Duration(seconds: 55));
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 60));
      when(() => controller.seekTo(any())).thenReturn(null);

      PlayerUtils.seekForward(controller);

      verify(() => controller.seekTo(const Duration(seconds: 60))).called(1);
    });

    test('seekForward error triggers onError', () {
      dynamic caughtError;
      when(() => controller.value).thenThrow(Exception('err'));

      PlayerUtils.seekForward(controller, onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── seekBackward ────────────
    test('seekBackward recoils position', () {
      when(() => mockValue.position).thenReturn(const Duration(seconds: 20));
      when(() => controller.seekTo(any())).thenReturn(null);

      PlayerUtils.seekBackward(controller);

      verify(() => controller.seekTo(const Duration(seconds: 10))).called(1);
    });

    test('seekBackward clamps to zero', () {
      when(() => mockValue.position).thenReturn(const Duration(seconds: 5));
      when(() => controller.seekTo(any())).thenReturn(null);

      PlayerUtils.seekBackward(controller);

      verify(() => controller.seekTo(Duration.zero)).called(1);
    });

    test('seekBackward error triggers onError', () {
      dynamic caughtError;
      when(() => controller.value).thenThrow(Exception('err'));

      PlayerUtils.seekBackward(controller, onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── toggleMute ────────────
    test('toggleMute mutes', () {
      when(() => controller.mute()).thenReturn(null);
      expect(PlayerUtils.toggleMute(controller, false), true);
      verify(() => controller.mute()).called(1);
    });

    test('toggleMute unmutes', () {
      when(() => controller.unMute()).thenReturn(null);
      expect(PlayerUtils.toggleMute(controller, true), false);
      verify(() => controller.unMute()).called(1);
    });

    test('toggleMute error triggers onError', () {
      dynamic caughtError;
      when(() => controller.mute()).thenThrow(Exception('err'));

      final result = PlayerUtils.toggleMute(controller, false,
          onError: (e) => caughtError = e);

      expect(result, false); // returns original
      expect(caughtError, isA<Exception>());
    });

    // ──────────── setMute ────────────
    test('setMute mutes and unmutes', () {
      when(() => controller.mute()).thenReturn(null);
      when(() => controller.unMute()).thenReturn(null);

      PlayerUtils.setMute(controller, true);
      verify(() => controller.mute()).called(1);

      PlayerUtils.setMute(controller, false);
      verify(() => controller.unMute()).called(1);
    });

    test('setMute error triggers onError', () {
      dynamic caughtError;
      when(() => controller.mute()).thenThrow(Exception('err'));

      PlayerUtils.setMute(controller, true, onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── getCurrentPosition ────────────
    test('getCurrentPosition returns position', () {
      when(() => mockValue.position).thenReturn(const Duration(seconds: 5));
      expect(PlayerUtils.getCurrentPosition(controller),
          const Duration(seconds: 5));
    });

    test('getCurrentPosition null returns zero', () {
      expect(PlayerUtils.getCurrentPosition(null), Duration.zero);
    });

    // ──────────── isPlaying ────────────
    test('isPlaying returns true', () {
      when(() => mockValue.isPlaying).thenReturn(true);
      expect(PlayerUtils.isPlaying(controller), true);
    });

    test('isPlaying null returns false', () {
      expect(PlayerUtils.isPlaying(null), false);
    });

    // ──────────── isReady ────────────
    test('isReady returns true', () {
      when(() => mockValue.isReady).thenReturn(true);
      expect(PlayerUtils.isReady(controller), true);
    });

    test('isReady null returns false', () {
      expect(PlayerUtils.isReady(null), false);
    });

    // ──────────── getDuration ────────────
    test('getDuration returns duration', () {
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 10));
      expect(PlayerUtils.getDuration(controller), const Duration(seconds: 10));
    });

    test('getDuration null returns zero', () {
      expect(PlayerUtils.getDuration(null), Duration.zero);
    });

    // ──────────── seekTo ────────────
    test('seekTo clamps to duration', () {
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 20));
      when(() => controller.seekTo(any())).thenReturn(null);

      PlayerUtils.seekTo(controller, const Duration(seconds: 30));
      verify(() => controller.seekTo(const Duration(seconds: 20))).called(1);
    });

    test('seekTo within bounds', () {
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 30));
      when(() => controller.seekTo(any())).thenReturn(null);

      PlayerUtils.seekTo(controller, const Duration(seconds: 20));
      verify(() => controller.seekTo(const Duration(seconds: 20))).called(1);
    });

    test('seekTo negative clamps to zero', () {
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 30));
      when(() => controller.seekTo(any())).thenReturn(null);

      PlayerUtils.seekTo(controller, const Duration(seconds: -5));
      verify(() => controller.seekTo(Duration.zero)).called(1);
    });

    test('seekTo error triggers onError', () {
      dynamic caughtError;
      when(() => controller.metadata).thenThrow(Exception('err'));

      PlayerUtils.seekTo(controller, const Duration(seconds: 1),
          onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── play ────────────
    test('play calls controller', () {
      when(() => controller.play()).thenReturn(null);
      PlayerUtils.play(controller);
      verify(() => controller.play()).called(1);
    });

    test('play null does nothing', () {
      expect(() => PlayerUtils.play(null), returnsNormally);
    });

    test('play error triggers onError', () {
      dynamic caughtError;
      when(() => controller.play()).thenThrow(Exception('err'));

      PlayerUtils.play(controller, onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── pause ────────────
    test('pause calls controller', () {
      when(() => controller.pause()).thenReturn(null);
      PlayerUtils.pause(controller);
      verify(() => controller.pause()).called(1);
    });

    test('pause error triggers onError', () {
      dynamic caughtError;
      when(() => controller.pause()).thenThrow(Exception('err'));

      PlayerUtils.pause(controller, onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── reset ────────────
    test('reset calls controller', () {
      when(() => controller.reset()).thenReturn(null);
      PlayerUtils.reset(controller);
      verify(() => controller.reset()).called(1);
    });

    test('reset error triggers onError', () {
      dynamic caughtError;
      when(() => controller.reset()).thenThrow(Exception('err'));

      PlayerUtils.reset(controller, onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── loadVideo ────────────
    test('loadVideo calls controller', () {
      when(() => controller.load('123')).thenReturn(null);
      PlayerUtils.loadVideo(controller, '123');
      verify(() => controller.load('123')).called(1);
    });

    test('loadVideo error triggers onError', () {
      dynamic caughtError;
      when(() => controller.load('123')).thenThrow(Exception('err'));

      PlayerUtils.loadVideo(controller, '123', onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── setPlaybackRate ────────────
    test('setPlaybackRate calls controller', () {
      when(() => controller.setPlaybackRate(1.5)).thenReturn(null);
      PlayerUtils.setPlaybackRate(controller, 1.5);
      verify(() => controller.setPlaybackRate(1.5)).called(1);
    });

    test('setPlaybackRate error triggers onError', () {
      dynamic caughtError;
      when(() => controller.setPlaybackRate(1.0)).thenThrow(Exception('err'));

      PlayerUtils.setPlaybackRate(controller, 1.0,
          onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── disposeController ────────────
    test('disposeController calls pause then dispose', () {
      when(() => controller.pause()).thenReturn(null);
      PlayerUtils.disposeController(controller);
      verify(() => controller.pause()).called(1);
      verify(() => controller.dispose()).called(1);
    });

    test('disposeController error triggers onError', () {
      dynamic caughtError;
      when(() => controller.pause()).thenThrow(Exception('err'));

      PlayerUtils.disposeController(controller,
          onError: (e) => caughtError = e);

      expect(caughtError, isA<Exception>());
    });

    // ──────────── restartVideo ────────────
    test('restartVideo seeks to zero and plays', () {
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 20));
      when(() => controller.seekTo(any())).thenReturn(null);
      when(() => controller.play()).thenReturn(null);

      PlayerUtils.restartVideo(controller);

      verify(() => controller.seekTo(Duration.zero)).called(1);
      verify(() => controller.play()).called(1);
    });

    test('restartVideo null does nothing', () {
      expect(() => PlayerUtils.restartVideo(null), returnsNormally);
    });

    test('restartVideo error does not throw', () {
      when(() => controller.metadata).thenThrow(Exception('err'));
      // seekTo will catch internally; restartVideo itself should not throw
      expect(() => PlayerUtils.restartVideo(controller), returnsNormally);
    });

    // ──────────── createController ────────────
    test('createController creates controller', () {
      final ctrl = PlayerUtils.createController(videoId: 'abc');
      expect(ctrl, isNotNull);
      expect(ctrl.initialVideoId, 'abc');
    });

    // ──────────── createPlayerFlags ────────────
    test('createPlayerFlags returns valid flags', () {
      final flags = PlayerUtils.createPlayerFlags(
        autoPlay: true,
        mute: true,
        loop: true,
        forceHD: true,
        enableCaption: true,
        showControls: false,
        startAt: 10,
      );
      expect(flags.autoPlay, true);
      expect(flags.mute, true);
      expect(flags.loop, true);
      expect(flags.enableCaption, true);
      expect(flags.startAt, 10);
    });

    test('createPlayerFlags on Android (mobile) forces HD correctly', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final flags = PlayerUtils.createPlayerFlags(
          forceHD: true,
          showControls: true,
        );
        // On mobile, forceHD should be passed through (not overridden to false)
        expect(flags.forceHD, true);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('createPlayerFlags on iOS (mobile)', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final flags = PlayerUtils.createPlayerFlags(forceHD: true);
        expect(flags.forceHD, true);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    // ──────────── isControllerSafe ────────────
    test('isControllerSafe all safe', () {
      expect(PlayerUtils.isControllerSafe(controller, false, true), true);
    });

    test('isControllerSafe null controller', () {
      expect(PlayerUtils.isControllerSafe(null, false, true), false);
    });

    test('isControllerSafe disposed', () {
      expect(PlayerUtils.isControllerSafe(controller, true, true), false);
    });

    test('isControllerSafe unmounted', () {
      expect(PlayerUtils.isControllerSafe(controller, false, false), false);
    });

    // ──────────── verifyAndCorrectPosition ────────────
    test('verifyAndCorrectPosition fixes position', () async {
      when(() => mockValue.position).thenReturn(const Duration(seconds: 1));
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 20));
      when(() => controller.seekTo(any())).thenReturn(null);

      final corrected = await PlayerUtils.verifyAndCorrectPosition(
          controller, const Duration(seconds: 10));
      expect(corrected, true);
      verify(() => controller.seekTo(const Duration(seconds: 10))).called(1);
    });

    test('verifyAndCorrectPosition within tolerance returns false', () async {
      when(() => mockValue.position).thenReturn(const Duration(seconds: 9));
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 20));
      when(() => controller.seekTo(any())).thenReturn(null);

      final corrected = await PlayerUtils.verifyAndCorrectPosition(
          controller, const Duration(seconds: 10));
      expect(corrected, false);
    });

    test('verifyAndCorrectPosition null returns false', () async {
      expect(
          await PlayerUtils.verifyAndCorrectPosition(
              null, const Duration(seconds: 5)),
          false);
    });

    test('verifyAndCorrectPosition zero target returns false', () async {
      expect(
          await PlayerUtils.verifyAndCorrectPosition(controller, Duration.zero),
          false);
    });

    // ──────────── handleVideoEnded ────────────
    test('handleVideoEnded loops video', () async {
      when(() => mockMetadata.duration).thenReturn(const Duration(seconds: 20));
      when(() => controller.seekTo(any())).thenReturn(null);
      when(() => controller.play()).thenReturn(null);

      final looped = await PlayerUtils.handleVideoEnded(
        controller: controller,
        shouldLoop: true,
        isDisposed: false,
        mounted: true,
      );

      expect(looped, true);
    });

    test('handleVideoEnded no loop returns false', () async {
      final looped = await PlayerUtils.handleVideoEnded(
        controller: controller,
        shouldLoop: false,
        isDisposed: false,
        mounted: true,
      );

      expect(looped, false);
    });

    test('handleVideoEnded calls onEnded', () async {
      bool endedCalled = false;

      await PlayerUtils.handleVideoEnded(
        controller: controller,
        shouldLoop: false,
        isDisposed: false,
        mounted: true,
        onEnded: () => endedCalled = true,
      );

      expect(endedCalled, true);
    });

    test('handleVideoEnded disposed returns false', () async {
      final looped = await PlayerUtils.handleVideoEnded(
        controller: controller,
        shouldLoop: true,
        isDisposed: true,
        mounted: true,
      );

      expect(looped, false);
    });

    // ──────────── showSettings ────────────
    testWidgets('showSettings opens bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PlayerUtils.showSettings(
                    context: context,
                    config: const PlayerSettingsConfig(
                      autoPlay: false,
                      loop: false,
                      forceHD: false,
                      enableCaption: false,
                      isMuted: false,
                    ),
                    onAutoPlayChanged: (_) async {},
                    onLoopChanged: (_) async {},
                    onForceHDChanged: (_) async {},
                    onEnableCaptionChanged: (_) async {},
                    onMutedChanged: (_) {},
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Player Settings'), findsOneWidget);
    });

    // ──────────── SystemChrome methods ────────────
    group('SystemChrome methods', () {
      test('hideSystemUI', () {
        PlayerUtils.hideSystemUI();
      });
      test('showSystemUI', () {
        PlayerUtils.showSystemUI();
      });
      test('setLandscapeOrientation', () {
        PlayerUtils.setLandscapeOrientation();
      });
      test('setPortraitOrientation', () {
        PlayerUtils.setPortraitOrientation();
      });
      test('setAllOrientations', () {
        PlayerUtils.setAllOrientations();
      });
    });

    // ──────────── Error catch paths for methods with onError ────────────
    group('Exception error catch paths', () {
      test('seekForward no onError', () {
        when(() => controller.value).thenThrow(Exception('err'));
        expect(() => PlayerUtils.seekForward(controller), returnsNormally);
      });

      test('seekBackward no onError', () {
        when(() => controller.value).thenThrow(Exception('err'));
        expect(() => PlayerUtils.seekBackward(controller), returnsNormally);
      });

      test('toggleMute no onError', () {
        when(() => controller.mute()).thenThrow(Exception('err'));
        expect(PlayerUtils.toggleMute(controller, false), false);
      });

      test('setMute no onError', () {
        when(() => controller.mute()).thenThrow(Exception('err'));
        expect(() => PlayerUtils.setMute(controller, true), returnsNormally);
      });

      test('getCurrentPosition error catch', () {
        when(() => controller.value).thenThrow(Exception('err'));
        expect(PlayerUtils.getCurrentPosition(controller), Duration.zero);
      });

      test('isPlaying error catch', () {
        when(() => controller.value).thenThrow(Exception('err'));
        expect(PlayerUtils.isPlaying(controller), false);
      });

      test('isReady error catch', () {
        when(() => controller.value).thenThrow(Exception('err'));
        expect(PlayerUtils.isReady(controller), false);
      });

      test('getDuration error catch', () {
        when(() => controller.metadata).thenThrow(Exception('err'));
        expect(PlayerUtils.getDuration(controller), Duration.zero);
      });
    });
  });
}
