import 'package:flutter_bloc/flutter_bloc.dart';

import 'youtube_player_state.dart';

export 'youtube_player_state.dart';

/// Cubit for managing YouTube player state
/// This provides a single source of truth for player state between
/// normal and fullscreen modes
class YoutubePlayerCubit extends Cubit<PlayerCubitState> {
  YoutubePlayerCubit() : super(PlayerCubitState());

  /// Update the current playback position
  void updatePosition(Duration position) {
    emit(state.copyWith(position: position));
  }

  /// Update playing state
  void setPlaying(bool isPlaying) {
    emit(state.copyWith(isPlaying: isPlaying));
  }

  /// Toggle mute state
  void toggleMute() {
    emit(state.copyWith(isMuted: !state.isMuted));
  }

  /// Set mute state
  void setMuted(bool isMuted) {
    emit(state.copyWith(isMuted: isMuted));
  }

  /// Enter fullscreen mode, saving current position
  void enterFullscreen(Duration currentPosition, bool wasPlaying) {
    emit(
      state.copyWith(
        isFullscreen: true,
        position: currentPosition,
        isPlaying: wasPlaying,
      ),
    );
  }

  /// Exit fullscreen mode with new position
  void exitFullscreen(Duration position, bool wasPlaying) {
    emit(
      state.copyWith(
        isFullscreen: false,
        position: position,
        isPlaying: wasPlaying,
      ),
    );
  }

  /// Update all settings at once (e.g., when returning from fullscreen)
  void updateSettings({
    bool? autoPlay,
    bool? loop,
    bool? forceHD,
    bool? enableCaption,
  }) {
    emit(
      state.copyWith(
        autoPlay: autoPlay,
        loop: loop,
        forceHD: forceHD,
        enableCaption: enableCaption,
      ),
    );
  }

  /// Set autoPlay setting
  void setAutoPlay(bool autoPlay) {
    emit(state.copyWith(autoPlay: autoPlay));
  }

  /// Set loop setting
  void setLoop(bool loop) {
    emit(state.copyWith(loop: loop));
  }

  /// Set forceHD setting
  void setForceHD(bool forceHD) {
    emit(state.copyWith(forceHD: forceHD));
  }

  /// Set enableCaption setting
  void setEnableCaption(bool enableCaption) {
    emit(state.copyWith(enableCaption: enableCaption));
  }

  /// Update duration when metadata is loaded
  void updateDuration(Duration duration) {
    emit(state.copyWith(duration: duration));
  }

  /// Set player ready state
  void setReady(bool isReady) {
    emit(state.copyWith(isReady: isReady));
  }

  /// Set error message
  void setError(String? errorMessage) {
    emit(
      state.copyWith(
        errorMessage: errorMessage,
        clearError: errorMessage == null,
      ),
    );
  }

  /// Store state before entering fullscreen
  /// Returns the current state for passing to fullscreen page
  PlayerCubitState captureStateForFullscreen(
    Duration position,
    bool isPlaying,
  ) {
    final newState = state.copyWith(
      position: position,
      isPlaying: isPlaying,
      isFullscreen: true,
    );
    emit(newState);
    return newState;
  }

  /// Restore state after exiting fullscreen
  void restoreStateFromFullscreen({
    required Duration position,
    required bool wasPlaying,
    required bool isMuted,
    bool? autoPlay,
    bool? loop,
    bool? forceHD,
    bool? enableCaption,
  }) {
    emit(
      state.copyWith(
        position: position,
        isPlaying: wasPlaying,
        isMuted: isMuted,
        isFullscreen: false,
        autoPlay: autoPlay,
        loop: loop,
        forceHD: forceHD,
        enableCaption: enableCaption,
      ),
    );
  }
}
