# How to Do a Full Rebuild (Fix Ad Plugin Error)

## The Error You're Seeing

```
MissingPluginException(No implementation found for method _init on channel plugins.flutter.io/google_mobile_ads)
```

This is **NORMAL** after adding a new plugin. The app still works, but ads won't show until you do a full rebuild.

---

## ✅ Solution: Full Rebuild

### Option 1: From Terminal (Recommended)

1. **Stop the app completely** (press `q` in terminal or stop button in IDE)

2. **Run full rebuild:**
   ```bash
   flutter run
   ```

### Option 2: From VS Code

1. **Stop the app** (click stop button or press `Shift+F5`)

2. **Run → Start Debugging** (F5) or **Run → Run Without Debugging** (Ctrl+F5)

   **NOT** "Hot Restart" - that won't work!

### Option 3: From Android Studio

1. **Stop the app** (click stop button)

2. **Run → Run 'main.dart'** (green play button)

   **NOT** "Hot Restart" - that won't work!

---

## 🔍 How to Tell if It Worked

After full rebuild, you should **NOT** see:
- `MissingPluginException` errors
- `Failed to initialize ads` messages

Instead, you should see (if ads load):
- `Banner ad loaded` messages
- Test ads appearing in the app

---

## ⚠️ Important Notes

1. **Hot Restart ≠ Full Rebuild**
   - Hot Restart: Only reloads Dart code (won't link native plugins)
   - Full Rebuild: Compiles everything including native code (required for new plugins)

2. **The App Still Works**
   - Your app functions normally even with this error
   - Events load, navigation works, everything except ads

3. **Ads Will Use Test IDs**
   - Until you set up AdMob account, ads will use test IDs
   - Test ads will show "Test Ad" labels
   - This is normal and expected

---

## 🐛 If Error Persists After Full Rebuild

### For Android:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### For iOS:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

---

## ✅ Success Indicators

After a successful full rebuild:
- ✅ No `MissingPluginException` errors
- ✅ App runs normally
- ✅ Banner ads appear at bottom of screens (if test ads load)
- ✅ Interstitial ads show when tapping events (every 4th event)

---

**Remember**: Always do a **full rebuild** (not hot restart) when adding new plugins!

