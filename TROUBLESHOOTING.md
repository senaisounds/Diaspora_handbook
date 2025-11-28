# Troubleshooting Connection Error

## Error: Connection refused on port 57853

This is a Flutter development service connection issue, not a code error. Here are solutions:

### Quick Fixes (Try in order):

1. **Restart the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Kill existing Flutter processes:**
   ```bash
   killall -9 dart
   killall -9 flutter
   flutter run
   ```

3. **Restart iOS Simulator:**
   - Quit the iOS Simulator completely
   - Open Xcode → Window → Devices and Simulators
   - Right-click your simulator → Delete
   - Create a new simulator
   - Run: `flutter run`

4. **Check if port is in use:**
   ```bash
   lsof -i :57853
   # If something is using it, kill it:
   kill -9 <PID>
   ```

5. **Reboot your Mac:**
   - Sometimes system-level issues require a restart

6. **Check Flutter doctor:**
   ```bash
   flutter doctor -v
   ```
   Make sure everything shows green checkmarks

### Code Fixes Applied:

✅ Fixed EventsProvider initialization to load cached data first
✅ Made ad service initialization non-blocking
✅ Improved error handling during startup

### If problem persists:

1. Close Xcode completely
2. Close VS Code/Android Studio
3. Open Terminal and run:
   ```bash
   cd /Users/senaimotley/Diaspora_handbook
   flutter clean
   rm -rf ios/Pods ios/Podfile.lock
   cd ios && pod install && cd ..
   flutter pub get
   flutter run
   ```

### Alternative: Run on Physical Device

If simulator keeps having issues:
```bash
flutter devices
# Connect your iPhone via USB
flutter run -d <your-device-id>
```

