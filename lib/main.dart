import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/dependency_injection/injectable_config.dart';
import 'core/localization/app_localizations.dart';
import 'core/widgets/language_cubit.dart';
import 'core/widgets/settings_bottom_sheet.dart';
import 'normal_video_player/adaptive_video_player.dart';
import 'normal_video_player/model/video_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'Video Player Demo',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ar', ''), // Arabic
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              fontFamily: 'Cairo',
            ),
            home: const VideoPlayerHomePage(),
          );
        },
      ),
    );
  }
}

class VideoPlayerHomePage extends StatelessWidget {
  const VideoPlayerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homeTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const SettingsBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlayerCard(
            context,
            title: localizations.youtubeVideoExample,
            description: localizations.youtubeVideoDescription,
            icon: Icons.play_circle_filled,
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(
                  title: localizations.youtubeVideo,
                  videoUrl: 'https://www.youtube.com/watch?v=vM2dC8OCZoY',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPlayerCard(
            context,
            title: localizations.directVideoExample,
            description: localizations.directVideoDescription,
            icon: Icons.video_library,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(
                  title: localizations.directVideo,
                  videoUrl:
                      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        localizations.features,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(localizations.featureAutoDetect),
                  _buildFeatureItem(localizations.featureCustomControls),
                  _buildFeatureItem(localizations.featureFullscreen),
                  _buildFeatureItem(localizations.featurePlaybackSpeed),
                  _buildFeatureItem(localizations.featureQualitySettings),
                  _buildFeatureItem(localizations.featureAutoPlay),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }

  Widget _buildPlayerCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// Video Player Screen
class VideoPlayerScreen extends StatelessWidget {
  final String title;
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: AdaptiveVideoPlayer(config: VideoConfig(videoUrl: videoUrl)),
      ),
    );
  }
}
