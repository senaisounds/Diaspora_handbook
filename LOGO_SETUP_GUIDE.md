# Diaspora Handbook Logo Setup Guide

## 📋 Overview
This guide will help you integrate the Diaspora Handbook logo into your app and generate platform-specific app icons.

## 🎨 Step 1: Save Your Logo Images

You need to save two versions of your logo:

### 1. Full Logo (`assets/logo.png`)
- **Purpose**: Used within the app UI (home screen header, about pages, etc.)
- **Recommended Size**: 1024x512 pixels (2:1 aspect ratio)
- **Format**: PNG with transparent or white background
- **Location**: `/Users/senaimotley/Diaspora_handbook/assets/logo.png`

### 2. App Icon (`assets/icon.png`)
- **Purpose**: Used to generate platform-specific app icons (iOS, Android, Web)
- **Recommended Size**: 1024x1024 pixels (square, 1:1 aspect ratio)
- **Format**: PNG
- **Location**: `/Users/senaimotley/Diaspora_handbook/assets/icon.png`
- **Important**: Should be a **square** version of your logo with centered content

## 📥 How to Save the Images

1. **From the logo image you provided:**
   - Right-click on the Diaspora Handbook logo
   - Select "Save Image As..."
   - Save it to the locations mentioned above

2. **Create a square version for app icon:**
   - Use any image editor (Preview on Mac, Paint on Windows, or online tools)
   - Crop the logo to a square format (1:1 aspect ratio)
   - Center the logo content
   - Save as `assets/icon.png`

## 🚀 Step 2: Generate Platform-Specific App Icons

Once you've saved both images, run this command in your terminal:

```bash
cd /Users/senaimotley/Diaspora_handbook
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate:
- ✅ iOS app icons (all required sizes)
- ✅ Android app icons (all required sizes)
- ✅ Web app icons
- ✅ macOS app icons

## ✨ What's Already Done

✅ Created reusable `LogoWidget` and `LogoIcon` widgets
✅ Updated `pubspec.yaml` to include both logo assets
✅ Integrated logo into home screen header
✅ Configured `flutter_launcher_icons` in `pubspec.yaml`
✅ Added fallback UI for when images aren't loaded

## 🎯 Using the Logo in Your Code

### Full Logo (Rectangular)
```dart
import 'package:diaspora_handbook/widgets/logo_widget.dart';

// In your widget:
const LogoWidget(
  width: 200,
  height: 100,
  fit: BoxFit.contain,
)
```

### App Icon (Square)
```dart
import 'package:diaspora_handbook/widgets/logo_widget.dart';

// In your widget:
const LogoIcon(
  size: 48,
)
```

## 📱 Verify the Changes

After generating the icons, you can verify them:

### iOS
Check: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Android
Check: `android/app/src/main/res/mipmap-*/launcher_icon.png`

### Web
Check: `web/icons/Icon-*.png`

## 🔄 Rebuild Your App

After generating the icons, rebuild your app:

```bash
# For iOS
flutter clean
flutter build ios

# For Android
flutter clean
flutter build apk

# Or just run
flutter run
```

## 🎨 Logo Design Notes

Your Diaspora Handbook logo features:
- 🌅 Yellow/gold sun rays (top left)
- 📘 "DIASPORA" text in blue
- 📗 "HANDBOOK" text in green
- 💜 "YOUR HOMECOMING SEASON GUIDE" tagline in purple

Make sure these colors and elements are clearly visible in both the rectangular and square versions!

## 🆘 Troubleshooting

**Problem**: Icons not showing after generation
**Solution**: Run `flutter clean` and rebuild the app

**Problem**: Logo not showing in app
**Solution**: 
1. Verify image files exist in `assets/` folder
2. Run `flutter pub get` to update assets
3. Hot restart the app (not just hot reload)

**Problem**: Image quality is poor
**Solution**: Use higher resolution source images (at least 1024x1024 for icon, 2048x1024 for logo)

## 📞 Need Help?

If you run into issues, check:
1. Image file paths are correct
2. Image formats are PNG
3. You've run `flutter pub get` after adding new assets
4. You've restarted the app (not just hot reload)

