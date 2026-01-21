# Video Player - Localization Guide

## Overview
This Flutter video player app supports **Arabic (ar)** and **English (en)** localization, with **English as the default language**.

## Features
- ✅ **Bilingual Support**: Arabic and English
- ✅ **Default Language**: English (en)
- ✅ **Runtime Language Switching**: Users can change the language via the settings bottom sheet
- ✅ **RTL Support**: Automatic right-to-left layout for Arabic
- ✅ **Persistent State**: Language preference persists during the app session

## File Structure

```
lib/
├── core/
│   ├── localization/
│   │   └── app_localizations.dart    # Main localization class
│   └── widgets/
│       ├── language_cubit.dart        # Language state management
│       └── settings_bottom_sheet.dart # Settings UI with language selector
├── l10n/
│   ├── intl_en.arb                    # English translations
│   ├── intl_ar.arb                    # Arabic translations
│   ├── messages_en.dart               # Generated English messages
│   ├── messages_ar.dart               # Generated Arabic messages
│   └── messages_all.dart              # Message loader
└── main.dart                          # App entry point with localization setup
```

## How to Use

### 1. **Accessing Translations in Code**

```dart
// Get the localizations instance
final localizations = AppLocalizations.of(context)!;

// Use translated strings
Text(localizations.homeTitle)
Text(localizations.youtubeVideoExample)
```

### 2. **Changing Language at Runtime**

Users can tap the **Settings icon** (⚙️) in the app bar to open the settings bottom sheet and select their preferred language:
- 🇬🇧 English
- 🇸🇦 Arabic

The app will automatically update all text and adjust the layout direction (LTR for English, RTL for Arabic).

### 3. **Adding New Translations**

To add a new translation key:

1. **Update ARB files** (`lib/l10n/intl_en.arb` and `lib/l10n/intl_ar.arb`):
   ```json
   {
     "newKey": "New Value"
   }
   ```

2. **Update the generated files** (`messages_en.dart`, `messages_ar.dart`):
   ```dart
   "newKey": MessageLookupByLibrary.simpleMessage("New Value")
   ```

3. **Add getter in `app_localizations.dart`**:
   ```dart
   String get newKey => Intl.message(
     'Default Value',
     name: 'newKey',
     desc: 'Description of the key',
   );
   ```

4. **Use in your widgets**:
   ```dart
   Text(AppLocalizations.of(context)!.newKey)
   ```

## Supported Languages

| Language | Code | Default |
|----------|------|---------|
| English  | en   | ✅ Yes  |
| Arabic   | ar   | ❌ No   |

## Current Translations

The app includes translations for:
- App title and navigation
- Video player examples
- Feature descriptions
- Settings and language selection
- Action buttons (Close, Apply)

## Dependencies

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any
  flutter_bloc: ^9.1.1
```

## Notes

- The app uses **Cairo font family** which supports both English and Arabic characters beautifully
- Language changes are immediate and don't require app restart
- The layout automatically adjusts for RTL (Arabic) and LTR (English) directions
- All UI strings are localized for a seamless bilingual experience

## Future Enhancements

Consider adding:
- Persistent language preference using SharedPreferences or similar
- More languages (French, Spanish, etc.)
- Automated localization generation using `intl_translation` package
- Date and number formatting based on locale
