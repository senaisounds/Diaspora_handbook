#!/bin/bash

# Diaspora Handbook - Icon Generation Script
# This script generates all platform-specific app icons

echo "🎨 Diaspora Handbook - App Icon Generator"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Check if icon file exists
if [ ! -f "assets/icon.png" ]; then
    echo "⚠️  Warning: assets/icon.png not found!"
    echo "   Please save your logo image to: assets/icon.png"
    echo "   Recommended size: 1024x1024 pixels (square)"
    echo ""
    read -p "Press Enter once you've saved the icon file, or Ctrl+C to exit..."
fi

# Check if logo file exists
if [ ! -f "assets/logo.png" ]; then
    echo "⚠️  Warning: assets/logo.png not found!"
    echo "   Please save your full logo to: assets/logo.png"
    echo "   Recommended size: 1024x512 pixels (rectangular)"
    echo ""
fi

echo "📦 Running: flutter pub get..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Error: flutter pub get failed"
    exit 1
fi

echo ""
echo "🎨 Generating app icons for all platforms..."
flutter pub run flutter_launcher_icons

if [ $? -ne 0 ]; then
    echo "❌ Error: Icon generation failed"
    exit 1
fi

echo ""
echo "✅ Success! App icons have been generated."
echo ""
echo "Generated icons for:"
echo "  ✓ iOS (ios/Runner/Assets.xcassets/AppIcon.appiconset/)"
echo "  ✓ Android (android/app/src/main/res/mipmap-*/)"
echo "  ✓ Web (web/icons/)"
echo ""
echo "🔄 Next steps:"
echo "  1. Run: flutter clean"
echo "  2. Rebuild your app: flutter run"
echo ""
echo "🎉 Your Diaspora Handbook app now has a professional icon!"

