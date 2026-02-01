# Fonts Folder

This folder contains custom fonts for the EliteAuto mobile application.

## Structure

Place your font files in this folder. Common font formats:
- `.ttf` - TrueType Font
- `.otf` - OpenType Font

## Usage

Fonts are referenced in `pubspec.yaml` and used via text styles:

```dart
Text('Hello', style: TextStyle(fontFamily: 'Inter'))
```

## Recommended Font

Consider adding **Inter** font family for a modern, professional look:

```yaml
fonts:
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf
      - asset: assets/fonts/Inter-Medium.ttf
        weight: 500
      - asset: assets/fonts/Inter-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Inter-Bold.ttf
        weight: 700
```

## Font Licensing

- Always ensure you have proper licensing for any fonts you use
- Google Fonts are free and open source
- Check license terms for commercial fonts

## Downloading Fonts

You can download fonts from:
- [Google Fonts](https://fonts.google.com/)
- [Font Awesome](https://fontawesome.com/)
- [Inter Font](https://rsms.me/inter/)

---

**Created:** January 2025  
**Purpose:** Custom fonts storage  
**Location:** `assets/fonts/`

