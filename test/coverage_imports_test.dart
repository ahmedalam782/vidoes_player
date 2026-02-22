// This file imports testable library source files to ensure they are included
// in the coverage report. Platform-dependent widget files that require
// native platform channels (InAppWebView, video_player, YoutubePlayer)
// are excluded as they require integration tests.

// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';

// Models
import 'package:adaptive_video_player/normal_video_player/model/video_config.dart';
import 'package:adaptive_video_player/youtube_player/models/player_config.dart';

// Cubit
import 'package:adaptive_video_player/youtube_player/cubit/youtube_player_cubit.dart';
import 'package:adaptive_video_player/youtube_player/cubit/youtube_player_state.dart';

// Utils
import 'package:adaptive_video_player/youtube_player/utils/duration_formatter.dart';
import 'package:adaptive_video_player/youtube_player/utils/player_utils.dart';
import 'package:adaptive_video_player/youtube_player/utils/youtube_web_stub.dart';

// Testable Widgets
import 'package:adaptive_video_player/youtube_player/widgets/current_position.dart';
import 'package:adaptive_video_player/youtube_player/widgets/remaining_duration.dart';
import 'package:adaptive_video_player/youtube_player/widgets/player_controls.dart';
import 'package:adaptive_video_player/youtube_player/widgets/player_bottom_actions.dart';
import 'package:adaptive_video_player/youtube_player/widgets/player_settings_helper.dart';
import 'package:adaptive_video_player/youtube_player/widgets/player_settings_sheet.dart';
import 'package:adaptive_video_player/youtube_player/widgets/setting_item.dart';

void main() {
  test('all testable library files are importable', () {
    expect(true, isTrue);
  });

  test('youtube_web_stub functions', () {
    registerYoutubeWebIframe('viewId', 'videoId', true);
    final widget = buildYoutubeWebIframe('viewId');
    expect(widget, isNotNull);
  });
}
