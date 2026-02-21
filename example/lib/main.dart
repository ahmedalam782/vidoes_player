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
                'Normal Video (MP4):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const AdaptiveVideoPlayer(
                config: VideoConfig(
                  videoUrl:
                      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
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
                      // forceDesktopMode: true,
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
                'This player supports YouTube features and normal MP4/network videos adaptively.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
