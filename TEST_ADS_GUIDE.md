# Testing Ads in Your App

## ✅ Test Mode is Now Enabled

Your app is currently configured with **proper Google AdMob test ad unit IDs**. These are official test IDs provided by Google that will show test ads during development.

---

## 🧪 Test Ad Unit IDs (Currently Active)

- **Banner Ad**: `ca-app-pub-3940256099942544/6300978111`
- **Interstitial Ad**: `ca-app-pub-3940256099942544/1033173712`
- **Rewarded Ad**: `ca-app-pub-3940256099942544/5224354917` (available but not implemented yet)

These test IDs are **safe to use** and won't generate invalid traffic.

---

## 📱 How to Test Ads

### 1. **Full Rebuild Required**

Make sure you've done a **full rebuild** (not hot restart):
```bash
flutter run
```

### 2. **What You'll See**

#### Banner Ads
- Appear at the bottom of **HomeScreen** (after scrolling through events)
- Appear in **EventDetailScreen** (after the "About" section)
- Will show "Test Ad" label (this is normal and expected)

#### Interstitial Ads
- Show when tapping on events (every 4th event)
- Full-screen ads that appear before navigating to event details
- Will show "Test Ad" label

### 3. **Console Logs**

You'll see helpful logs in your console:
- ✅ `AdMob TEST MODE: Using test ad unit IDs`
- ✅ `Banner ad loaded successfully`
- ✅ `Interstitial ad loaded successfully`
- 🧪 `TEST AD - This is a test ad from Google`

---

## 🔍 Testing Features

### Check Ad Status

The `AdService` now has helpful methods for testing:

```dart
// Check if ads are in test mode
AdService().isTestMode  // Returns true

// Check if interstitial ad is ready
AdService().isInterstitialAdReady  // Returns true/false

// Get current interstitial counter
AdService().interstitialAdCounter  // Returns current count

// Force show interstitial (bypasses frequency capping)
AdService().showInterstitialAdForTesting()

// Reset interstitial counter
AdService().resetInterstitialCounter()
```

---

## 🎯 Testing Checklist

- [ ] Do a full rebuild (`flutter run`)
- [ ] Check console for "AdMob TEST MODE" message
- [ ] Scroll to bottom of HomeScreen - banner ad should appear
- [ ] Open an event detail - banner ad should appear after "About" section
- [ ] Tap on events - interstitial ad should show every 4th event
- [ ] Check console logs for ad loading messages
- [ ] Verify test ads show "Test Ad" label

---

## 🚀 Switching to Production

When you're ready to use real ads:

1. **Get your AdMob ad unit IDs** from [apps.admob.com](https://apps.admob.com/)

2. **Update `lib/services/ad_service.dart`**:
   ```dart
   // Change this:
   static const bool _isTestMode = true;
   
   // To this:
   static const bool _isTestMode = false;
   ```

3. **Replace production ad unit IDs**:
   ```dart
   static const String _prodBannerAdUnitId = 'YOUR_ACTUAL_BANNER_ID';
   static const String _prodInterstitialAdUnitId = 'YOUR_ACTUAL_INTERSTITIAL_ID';
   ```

4. **Remove test device configuration** (if you added any)

5. **Test thoroughly** before releasing

---

## ⚠️ Important Notes

1. **Test ads are free** - They don't generate revenue but are perfect for testing
2. **Test ads always load** - Unlike real ads, test ads have 100% fill rate
3. **Test ads show labels** - You'll see "Test Ad" labels (this is normal)
4. **No AdMob account needed** - Test ads work without an AdMob account
5. **Full rebuild required** - Hot restart won't link the native plugin

---

## 🐛 Troubleshooting

### Ads Not Showing?

1. **Check console logs** - Look for error messages
2. **Verify full rebuild** - Make sure you did `flutter run` (not hot restart)
3. **Check initialization** - Look for "AdMob initialized successfully" message
4. **Check ad loading** - Look for "Banner ad loaded" or "Interstitial ad loaded" messages

### Still Having Issues?

1. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check plugin linking**:
   - Android: Check `android/app/build.gradle` has the plugin
   - iOS: Run `cd ios && pod install && cd ..`

---

## 📊 Expected Console Output

When ads are working correctly, you should see:

```
✅ AdMob initialized successfully
🧪 AdMob TEST MODE: Using test ad unit IDs
   Banner: ca-app-pub-3940256099942544/6300978111
   Interstitial: ca-app-pub-3940256099942544/1033173712
🔄 Loading banner ad...
✅ Banner ad loaded successfully
   🧪 TEST AD - This is a test ad from Google
🔄 Loading interstitial ad...
✅ Interstitial ad loaded successfully
   🧪 TEST AD - This is a test ad from Google
```

---

## ✅ Success Indicators

- ✅ No `MissingPluginException` errors
- ✅ "AdMob initialized successfully" message
- ✅ "Banner ad loaded successfully" message
- ✅ "Interstitial ad loaded successfully" message
- ✅ Test ads appear in the app
- ✅ Test ads show "Test Ad" labels

---

**You're all set!** Test ads are properly configured and ready to test. Just do a full rebuild and you should see test ads working in your app! 🎉

