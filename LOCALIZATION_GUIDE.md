# Localization Setup Guide

## Overview

The StandReminder app now supports standardized internationalization (i18n) using Apple's native localization system. The app supports three languages:
- English (en)
- Simplified Chinese (zh-Hans)
- Traditional Chinese (zh-Hant)

## What Changed

### Before
The app used inline ternary operators for language switching:
```swift
Text(reminderManager.selectedLanguage == .chinese ? "站立提醒" : "Stand Reminder")
```

### After
The app now uses Apple's standard NSLocalizedString:
```swift
Text(NSLocalizedString("app.title", comment: "App title"))
```

## Adding Localization Files to Xcode

The localization files have been created but need to be added to the Xcode project:

1. Open `StandReminder.xcodeproj` in Xcode
2. In the Project Navigator, right-click on the "StandReminder" folder
3. Select "Add Files to 'StandReminder'..."
4. Navigate to and select these folders:
   - `StandReminder/en.lproj`
   - `StandReminder/zh-Hans.lproj`
   - `StandReminder/zh-Hant.lproj`
5. Make sure "Create folder references" is selected (not "Create groups")
6. Click "Add"

## Localization Files

All translatable strings are now centralized in `Localizable.strings` files:

### File Structure
```
StandReminder/
├── en.lproj/
│   └── Localizable.strings      (English translations)
├── zh-Hans.lproj/
│   └── Localizable.strings      (Simplified Chinese translations)
└── zh-Hant.lproj/
    └── Localizable.strings      (Traditional Chinese translations)
```

### String Categories

The localization strings are organized into categories:
- **App Title**: Main app name and subtitle
- **Status**: Active/paused states
- **Timer**: Timer-related text
- **Actions**: Button labels and actions
- **Time Units**: Minutes, hours, etc.
- **Quick Actions**: Settings, History, etc.
- **Statistics**: Today's stats, reminders, responses
- **Settings**: All settings-related text
- **History**: History view text
- **Fullscreen Reminder**: Fullscreen reminder text
- **Language Names**: Language display names
- **Notifications**: Notification content

## Testing Localization

### Method 1: System Language
1. Go to System Preferences > Language & Region
2. Change the primary language to test different localizations
3. Restart the app

### Method 2: Xcode Scheme
1. In Xcode, go to Product > Scheme > Edit Scheme
2. Select "Run" from the left sidebar
3. Go to the "Options" tab
4. Under "App Language", select the language you want to test
5. Run the app

### Method 3: Command Line
```bash
# Run with English
open -a StandReminder.app --args -AppleLanguages "(en)"

# Run with Simplified Chinese
open -a StandReminder.app --args -AppleLanguages "(zh-Hans)"

# Run with Traditional Chinese
open -a StandReminder.app --args -AppleLanguages "(zh-Hant)"
```

## Adding New Strings

When adding new UI text that needs translation:

1. Use NSLocalizedString in your Swift code:
```swift
Text(NSLocalizedString("my.new.key", comment: "Description of the string"))
```

2. Add the key to all three `Localizable.strings` files:

**en.lproj/Localizable.strings:**
```
"my.new.key" = "My New Text";
```

**zh-Hans.lproj/Localizable.strings:**
```
"my.new.key" = "我的新文本";
```

**zh-Hant.lproj/Localizable.strings:**
```
"my.new.key" = "我的新文本";
```

## Key Conventions

Use dot notation for organization:
- `app.title` - App-level strings
- `status.active` - Status-related strings
- `action.start` - Action/button strings
- `settings.title` - Settings-related strings
- `stats.reminders` - Statistics strings

## Breaking Changes

### Removed
- `ReminderManager.Language` enum
- `ReminderManager.selectedLanguage` property
- All inline language-switching ternary operators

### Impact
The app now uses the system's language preference automatically. Users no longer need to manually select a language in the app - it will use their system language preference.

If the system language is:
- English → English UI
- Chinese (Simplified) → Simplified Chinese UI
- Chinese (Traditional) → Traditional Chinese UI
- Any other language → Falls back to English

## Benefits

1. **Standard Approach**: Uses Apple's recommended localization system
2. **Easier Maintenance**: All translations in separate files
3. **Better Organization**: Clear separation of UI code and text content
4. **System Integration**: Respects user's system language preference
5. **Scalability**: Easy to add new languages
6. **Best Practices**: Follows Apple's guidelines

## Migration Notes

The old `selectedLanguage` property has been removed. The app now automatically uses the system language. If you had custom language selection logic, it has been replaced with system-based localization.

## Troubleshooting

### Strings Not Translating
1. Verify the `.lproj` folders are added to the Xcode project as folder references
2. Check that `Localizable.strings` files are included in the target
3. Clean build folder (Product > Clean Build Folder)
4. Restart the app

### Wrong Language Showing
1. Check System Preferences > Language & Region
2. Verify your system language is set correctly
3. Check that all three `.lproj` folders are properly added to the project

### Missing Translations
1. Open the `Localizable.strings` file for the missing language
2. Add the missing key-value pair
3. Rebuild the project
