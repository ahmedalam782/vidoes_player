import 'package:flutter/material.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Videos Player Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Videos Player Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Quality Picker & HLS Stream:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AdaptiveVideoPlayer(
                config: VideoConfig(
                  videoUrl:
                      'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
                  subtitles: [
                    const SubtitleTrack(
                      id: 'en',
                      title: 'English',
                      content: '''
1
00:00:01,000 --> 00:00:04,000
This is a sample English subtitle.

2
00:00:04,500 --> 00:00:08,000
It shows how subtitles overlay on video.
                      ''',
                    ),
                    const SubtitleTrack(
                      id: 'ar',
                      title: 'عربي',
                      content: '''
1
00:00:01,000 --> 00:00:04,000
هذه ترجمة تجريبية باللغة العربية.

2
00:00:04,500 --> 00:00:08,000
تظهر كيف يتم دمج الترجمة بدقة عالية على الفيديو.
                      ''',
                    ),
                  ],
                  initialSubtitle: const SubtitleTrack(
                    id: 'en',
                    title: 'English',
                    content: '''
1
00:00:01,000 --> 00:00:04,000
This is a sample English subtitle.

2
00:00:04,500 --> 00:00:08,000
It shows how subtitles overlay on video.
                      ''',
                  ),
                  qualities: [
                    const VideoQuality(
                      title: 'Auto (HLS)',
                      url:
                          'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
                    ),
                    const VideoQuality(
                      title: 'HD',
                      url:
                          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
                    ),
                    const VideoQuality(
                      title: 'SD',
                      url:
                          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                    ),
                  ],
                  initialQuality: const VideoQuality(
                    title: 'Auto (HLS)',
                    url:
                        'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
                  ),
                  onAnalyticsEvent: (event, data) {
                    debugPrint('Analytics: $event - Data: $data');
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Video with "Live" Option in Settings:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AdaptiveVideoPlayer(
                config: const VideoConfig(
                  // Here is the non-live MP4 stream
                  videoUrl:
                      'https://www.mp3quran.net/uploads/videos/group1_pbuh/maher.mp4',
                  qualities: [
                    VideoQuality(
                      title: 'Recorded (MP4)',
                      url:
                          'https://www.mp3quran.net/uploads/videos/group1_pbuh/maher.mp4',
                      isLive: false,
                    ),
                    VideoQuality(
                      title: 'Live broadcast',
                      url: 'https://win.holol.com/live/quran/playlist.m3u8',
                      isLive:
                          true, // This makes the "LIVE" text appear inside the settings & bottom bar when selected!
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'YouTube Video:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AdaptiveVideoPlayer(
                config: VideoConfig(
                  videoUrl: 'https://www.youtube.com/watch?v=vM2dC8OCZoY',
                  playerConfig: YouTubePlayerConfig(
                    playback: PlayerPlaybackConfig(
                      forceDesktopMode: true,
                    ),
                    text: PlayerTextConfig(
                      invalidYoutubeUrlText: 'Invalid YouTube URL provided.',
                      videoLoadFailedText: 'We failed to load the video.',
                      videoUnavailableText: 'Sorry, video is unavailable.',
                      videoNotCompatibleText: 'Uncompatible video format.',
                      videoCannotBeLoadedSecurityPolicyText:
                          'Security policy error.',
                      playerSettingsText: 'Settings',
                      autoPlayText: 'Auto Play (enabled)',
                      loopVideoText: 'Loop',
                      forceHdQualityText: 'Force HD',
                      enableCaptionsText: 'Captions',
                      muteAudioText: 'Mute',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'YouTube Live Stream:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AdaptiveVideoPlayer(
                config: const VideoConfig(
                  // Example: YouTube live stream provided by user
                  videoUrl: 'https://www.youtube.com/watch?v=jSdDnhIt6pQ',
                  isLive:
                      true, // This enables the special YouTube Live controls/ui hiding
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'This player supports YouTube features and normal MP4/network videos adaptively.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
