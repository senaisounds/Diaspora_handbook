# Setup Checklist for Diaspora Handbook

This checklist ensures all third-party services are properly configured before building/running the app.

---

## ✅ Required Configuration

### 1. Google AdMob (REQUIRED - App will crash without this)

#### Android Setup
- [x] **AndroidManifest.xml** - AdMob Application ID added
  - File: `android/app/src/main/AndroidManifest.xml`
  - Currently using: **Test ID** (`ca-app-pub-3940256099942544~3347511713`)
  - ⚠️ **For Production**: Replace with your real Android App ID from [AdMob Console](https://apps.admob.com/)

#### iOS Setup
- [x] **Info.plist** - AdMob Application ID added
  - File: `ios/Runner/Info.plist`
  - Currently using: **Test ID** (`ca-app-pub-3940256099942544~1458002511`)
  - ⚠️ **For Production**: Replace with your real iOS App ID from [AdMob Console](https://apps.admob.com/)

#### Ad Unit IDs
- [x] **ad_service.dart** - Test ad unit IDs configured
  - File: `lib/services/ad_service.dart`
  - Currently in: **Test Mode** (`_isTestMode = true`)
  - ⚠️ **For Production**: 
    1. Create ad units in AdMob Console
    2. Update production ad unit IDs in `ad_service.dart`
    3. Set `_isTestMode = false`

**Documentation**: See `ADMOB_SETUP.md` for detailed instructions

---

### 2. Google Maps API (Optional - for map features)

#### Android Setup
- [ ] **AndroidManifest.xml** - Maps API Key
  - File: `android/app/src/main/AndroidManifest.xml`
  - Status: **Not configured** (commented out)
  - Get key from: [Google Cloud Console](https://console.cloud.google.com/)
  - Uncomment and add your key if using map features

#### iOS Setup
- [ ] **AppDelegate.swift** - Maps API Key
  - File: `ios/Runner/AppDelegate.swift`
  - Status: **Not configured**
  - Add `GMSServices.provideAPIKey("YOUR_API_KEY")` if using map features

**Note**: Map features will not work until API keys are added, but app won't crash.

---

### 3. Backend API (Optional - for live event data)

- [x] **Backend Server Running**
  - Location: `backend/` directory
  - Start command: `cd backend && npm start`
  - Status: ✅ **Currently running** on `http://localhost:3000`

- [x] **API Service Configuration**
  - File: `lib/services/api_service.dart`
  - iOS URL: `http://192.168.77.40:3000/api` (your computer's IP)
  - Android URL: `http://10.0.2.2:3000/api` (auto-configured)
  - Status: ✅ **Configured**

**Note**: App uses cached data if backend is not available. See `BACKEND_CONNECTION_GUIDE.md` for details.

---

## 🔍 Before Each Build

Run this quick checklist before building:

### iOS Build
```bash
# 1. Check Info.plist has AdMob App ID
grep -A 1 "GADApplicationIdentifier" ios/Runner/Info.plist

# 2. Clean build folder
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..

# 3. Build
flutter build ios
```

### Android Build
```bash
# 1. Check AndroidManifest.xml has AdMob App ID
grep -A 2 "com.google.android.gms.ads.APPLICATION_ID" android/app/src/main/AndroidManifest.xml

# 2. Clean build
flutter clean && flutter pub get

# 3. Build
flutter build apk
```

---

## 🚨 Common Issues & Solutions

### Issue: "Showing cached data. Unable to connect to server"

**Cause**: Backend server is not running or unreachable

**Solution**:
1. Start backend: `cd backend && npm start`
2. Restart your Flutter app
3. Pull down to refresh in the app
4. See `QUICK_FIX_CONNECTION.md` for detailed steps

### Issue: "Google Mobile Ads SDK was initialized without an application ID"

**Cause**: Missing AdMob Application ID in AndroidManifest.xml or Info.plist

**Solution**:
1. Check `android/app/src/main/AndroidManifest.xml` has `com.google.android.gms.ads.APPLICATION_ID`
2. Check `ios/Runner/Info.plist` has `GADApplicationIdentifier`
3. Clean and rebuild the app

### Issue: Ads not showing

**Cause**: Multiple possible reasons

**Solution**:
1. Check internet connection
2. Verify ad unit IDs are correct
3. Check AdMob dashboard for app approval status
4. Review console logs for error messages
5. For new apps, it may take time for ads to fill

### Issue: Map not loading

**Cause**: Missing Google Maps API key

**Solution**:
1. Get API key from Google Cloud Console
2. Add to AndroidManifest.xml and AppDelegate.swift
3. Enable Maps SDK for Android/iOS in Google Cloud Console

---

## 📝 Production Deployment Checklist

Before releasing to production:

- [ ] Replace AdMob test App IDs with real App IDs
- [ ] Replace AdMob test ad unit IDs with real ad unit IDs
- [ ] Set `_isTestMode = false` in `ad_service.dart`
- [ ] Add Google Maps API keys (if using maps)
- [ ] Update backend API URL (if using backend)
- [ ] Test on physical devices (both Android and iOS)
- [ ] Verify ads are showing correctly
- [ ] Check app doesn't crash on launch
- [ ] Review privacy policy for AdMob compliance
- [ ] Submit app for AdMob review (if required)

---

## 📚 Documentation References

- **Quick Connection Fix**: `QUICK_FIX_CONNECTION.md` ⭐ Start here if you see connection errors
- **Backend Connection**: `BACKEND_CONNECTION_GUIDE.md`
- **Backend Setup**: `BACKEND_SETUP.md`
- **AdMob Setup**: `ADMOB_SETUP.md`
- **Ads Implementation**: `ADS_IMPLEMENTATION_GUIDE.md`
- **Recommended Strategy**: `RECOMMENDED_ADS_STRATEGY.md`
- **Testing Ads**: `TEST_ADS_GUIDE.md`
- **Troubleshooting**: `TROUBLESHOOTING.md`

---

## 🎯 Quick Status Check

Run this command to check all configurations:

```bash
echo "=== AdMob Configuration Check ==="
echo ""
echo "Android AdMob App ID:"
grep -A 2 "com.google.android.gms.ads.APPLICATION_ID" android/app/src/main/AndroidManifest.xml | grep "android:value"
echo ""
echo "iOS AdMob App ID:"
grep -A 1 "GADApplicationIdentifier" ios/Runner/Info.plist | grep "string"
echo ""
echo "Ad Service Test Mode:"
grep "_isTestMode = " lib/services/ad_service.dart
echo ""
echo "=== Google Maps Configuration Check ==="
echo ""
echo "Android Maps API Key:"
grep -A 2 "com.google.android.geo.API_KEY" android/app/src/main/AndroidManifest.xml | grep "android:value" || echo "Not configured (commented out)"
echo ""
echo "=== Done ==="
```

---

**Last Updated**: November 25, 2025
**Status**: AdMob test IDs configured ✅ | Maps API not configured ⚠️ | Backend optional ℹ️

