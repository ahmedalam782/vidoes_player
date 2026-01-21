import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) async {
    final String name =
        locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    await initializeMessages(localeName);
    Intl.defaultLocale = localeName;

    return AppLocalizations();
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // App Title
  String get appTitle => Intl.message(
    'Video Player',
    name: 'appTitle',
    desc: 'The application title',
  );

  // Home Screen
  String get homeTitle => Intl.message(
    'Adaptive Video Player',
    name: 'homeTitle',
    desc: 'Home screen title',
  );

  String get youtubeVideoExample => Intl.message(
    'YouTube Video Example',
    name: 'youtubeVideoExample',
    desc: 'YouTube video card title',
  );

  String get youtubeVideoDescription => Intl.message(
    'Automatically detects and plays YouTube videos',
    name: 'youtubeVideoDescription',
    desc: 'YouTube video card description',
  );

  String get directVideoExample => Intl.message(
    'Direct Video Example',
    name: 'directVideoExample',
    desc: 'Direct video card title',
  );

  String get directVideoDescription => Intl.message(
    'Automatically plays direct video URLs',
    name: 'directVideoDescription',
    desc: 'Direct video card description',
  );

  String get features => Intl.message(
    'Features',
    name: 'features',
    desc: 'Features section title',
  );

  String get featureAutoDetect => Intl.message(
    '✅ Auto-detects YouTube and direct videos',
    name: 'featureAutoDetect',
    desc: 'Auto-detect feature',
  );

  String get featureCustomControls => Intl.message(
    '✅ Custom controls for both player types',
    name: 'featureCustomControls',
    desc: 'Custom controls feature',
  );

  String get featureFullscreen => Intl.message(
    '✅ Fullscreen support',
    name: 'featureFullscreen',
    desc: 'Fullscreen feature',
  );

  String get featurePlaybackSpeed => Intl.message(
    '✅ Playback speed control',
    name: 'featurePlaybackSpeed',
    desc: 'Playback speed feature',
  );

  String get featureQualitySettings => Intl.message(
    '✅ Quality settings',
    name: 'featureQualitySettings',
    desc: 'Quality settings feature',
  );

  String get featureAutoPlay => Intl.message(
    '✅ Auto-play and loop options',
    name: 'featureAutoPlay',
    desc: 'Auto-play feature',
  );

  // Video Player Screen
  String get youtubeVideo => Intl.message(
    'YouTube Video',
    name: 'youtubeVideo',
    desc: 'YouTube video screen title',
  );

  String get directVideo => Intl.message(
    'Direct Video (MP4)',
    name: 'directVideo',
    desc: 'Direct video screen title',
  );

  // Settings Bottom Sheet
  String get settings =>
      Intl.message('Settings', name: 'settings', desc: 'Settings title');

  String get language =>
      Intl.message('Language', name: 'language', desc: 'Language label');

  String get selectLanguage => Intl.message(
    'Select Language',
    name: 'selectLanguage',
    desc: 'Select language prompt',
  );

  String get english =>
      Intl.message('English', name: 'english', desc: 'English language name');

  String get arabic =>
      Intl.message('Arabic', name: 'arabic', desc: 'Arabic language name');

  String get changeLanguage => Intl.message(
    'Change Language',
    name: 'changeLanguage',
    desc: 'Change language button',
  );

  String get close =>
      Intl.message('Close', name: 'close', desc: 'Close button');

  String get apply =>
      Intl.message('Apply', name: 'apply', desc: 'Apply button');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
