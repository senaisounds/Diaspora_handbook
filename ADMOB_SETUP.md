# Google AdMob Setup Guide

## ✅ Implementation Complete!

Ads have been successfully integrated into your app. Now you need to set up your AdMob account and get your ad unit IDs.

---

## 🚀 Quick Setup Steps

### 1. Create AdMob Account

1. Go to [https://apps.admob.com/](https://apps.admob.com/)
2. Sign in with your Google account
3. Click "Get Started" and follow the setup wizard

### 2. Add Your App

1. In AdMob dashboard, click **Apps** → **Add App**
2. Select:
   - **Platform**: Android and iOS (add both separately)
   - **App Name**: Diaspora Handbook
   - **Package Name**: Check your `android/app/build.gradle.kts` and `ios/Runner.xcodeproj` for package names

### 3. Create Ad Units

For each platform (Android and iOS), create these ad units:

#### Banner Ad Unit
1. Click **Ad units** → **Add ad unit**
2. Select **Banner**
3. Name it: "Diaspora Handbook - Banner"
4. Copy the **Ad unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)

#### Interstitial Ad Unit
1. Click **Ad units** → **Add ad unit**
2. Select **Interstitial**
3. Name it: "Diaspora Handbook - Interstitial"
4. Copy the **Ad unit ID**

### 4. Update Ad Unit IDs in Code

Open `lib/services/ad_service.dart` and replace the test IDs:

```dart
// Replace these with your actual AdMob ad unit IDs
static const String bannerAdUnitId = 'YOUR_BANNER_AD_UNIT_ID_HERE';
static const String interstitialAdUnitId = 'YOUR_INTERSTITIAL_AD_UNIT_ID_HERE';
```

**Important**: 
- Use different ad unit IDs for Android and iOS
- You can detect platform and use the appropriate ID, or create separate ad units

### 5. Android Configuration

#### Add App ID to AndroidManifest.xml

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

**Note**: Replace with your Android App ID (found in AdMob → Apps → Your Android App)

#### Add Internet Permission (if not already present)

In `android/app/src/main/AndroidManifest.xml`, ensure you have:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### 6. iOS Configuration

#### Add App ID to Info.plist

1. Open `ios/Runner/Info.plist`
2. Add before `</dict>`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

**Note**: Replace with your iOS App ID (found in AdMob → Apps → Your iOS App)

---

## 🧪 Testing

### Test Ad Unit IDs

During development, you can use these test IDs (already in code):
- **Banner**: `ca-app-pub-3940256099942544/6300978111`
- **Interstitial**: `ca-app-pub-3940256099942544/1033173712`

These will show test ads that won't generate revenue but help you verify the integration works.

### Testing Checklist

- [ ] Banner ad appears at bottom of HomeScreen
- [ ] Banner ad appears in EventDetailScreen after "About" section
- [ ] Interstitial ad shows when tapping events (every 4th event)
- [ ] Ads don't show on first app launch
- [ ] Ads load properly on both Android and iOS

---

## 📍 Ad Placement Summary

### Phase 1 Implementation (Completed)

1. **HomeScreen Banner**
   - Location: Bottom of event list
   - Always visible when scrolling

2. **EventDetailScreen Banner**
   - Location: After "About" section, before "Nearby Events"
   - Good visibility without interrupting flow

3. **Interstitial on Event Tap**
   - Location: Before navigating to EventDetailScreen
   - Frequency: Every 4th event (not every time)
   - Natural transition point

---

## 💰 Revenue Optimization Tips

1. **Wait for Real Traffic**: Test ads won't generate revenue. Wait until you have real users.

2. **Monitor Performance**: 
   - Check AdMob dashboard regularly
   - Monitor fill rates and eCPM
   - Adjust frequency if needed

3. **User Experience**:
   - Current frequency (every 4th event) is a good balance
   - Don't increase interstitial frequency too much
   - Consider premium ad-free option

4. **Platform Differences**:
   - iOS typically has higher eCPM than Android
   - Consider different strategies per platform

---

## 🔧 Troubleshooting

### Ads Not Showing

1. **Check Ad Unit IDs**: Make sure you replaced test IDs with real ones
2. **Check App ID**: Verify AndroidManifest.xml and Info.plist have correct App IDs
3. **Check Network**: Ensure device has internet connection
4. **Check AdMob Status**: Verify your app is approved in AdMob
5. **Check Logs**: Look for error messages in console

### Common Errors

**"Ad failed to load"**
- Ad unit ID might be incorrect
- App might not be approved in AdMob yet
- Network connectivity issue

**"No fill"**
- Normal for new apps with low traffic
- AdMob needs time to optimize
- Consider using mediation (multiple ad networks)

**"App ID mismatch"**
- Check AndroidManifest.xml and Info.plist
- Ensure App ID matches the platform

---

## 📊 Next Steps

1. ✅ Code implementation (DONE)
2. ⏳ Create AdMob account
3. ⏳ Add app to AdMob
4. ⏳ Create ad units
5. ⏳ Update ad unit IDs in code
6. ⏳ Test on device
7. ⏳ Submit app for review (if needed)
8. ⏳ Monitor performance

---

## 📝 Notes

- **Test Mode**: The current implementation uses test ad IDs. Replace them before production.
- **Frequency Capping**: Interstitial ads show every 4th event to avoid annoying users.
- **Premium Option**: You can add a premium subscription later to hide ads (implement in `AdService.shouldShowAds()`).

---

## 🆘 Need Help?

- [AdMob Documentation](https://developers.google.com/admob/flutter/quick-start)
- [AdMob Support](https://support.google.com/admob)
- [Flutter AdMob Plugin](https://pub.dev/packages/google_mobile_ads)

---

**Remember**: Always test with test ad IDs first, then switch to real IDs before production release!

