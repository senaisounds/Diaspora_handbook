# API Keys Setup Guide

## Current Status

You're currently using **TEST/DEVELOPMENT** keys. These need to be replaced with **PRODUCTION** keys before App Store submission.

## Keys That Need to Be Replaced

### 1. Google Maps API Key
- **Current (Test)**: `AIzaSyAR3htMyrXioNXKjdmR0qT9u2bmf-RsF3s`
- **Location**: 
  - `android/app/src/main/AndroidManifest.xml` (line 44)
  - `ios/Runner/AppDelegate.swift` (line 12)

### 2. AdMob App IDs
- **iOS Current (Test)**: `ca-app-pub-3940256099942544~1458002511`
- **Android Current (Test)**: `ca-app-pub-3940256099942544~3347511713`
- **Location**:
  - iOS: `ios/Runner/Info.plist` (line 59)
  - Android: `android/app/src/main/AndroidManifest.xml` (line 50)

### 3. AdMob Ad Unit IDs (in code)
- **Current (Test)**: Using test ad unit IDs
- **Location**: `lib/services/ad_service.dart`

---

## Step-by-Step: Getting Your Production Keys

### Part 1: Google Maps API Key

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/
   - Sign in with your Google account

2. **Create or Select a Project**
   - Click the project dropdown at the top
   - Click "New Project" or select existing one
   - Name it (e.g., "Diaspora Handbook")

3. **Enable Maps SDK**
   - Go to "APIs & Services" > "Library"
   - Search for "Maps SDK for Android" → Enable it
   - Search for "Maps SDK for iOS" → Enable it

4. **Create API Key**
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy the key (starts with `AIza...`)

5. **Restrict the API Key** (IMPORTANT for security)
   - Click on the newly created key
   - Under "Application restrictions":
     - For Android: Select "Android apps"
     - Add your package name: `com.senaimotley.diasporahandbook`
     - Add your SHA-1 certificate fingerprint (get it with: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`)
     - For iOS: Select "iOS apps"
     - Add your bundle ID (check in Xcode project settings)
   - Under "API restrictions":
     - Select "Restrict key"
     - Check only: "Maps SDK for Android" and "Maps SDK for iOS"
   - Click "Save"

6. **Replace in Your Code**
   ```bash
   # Android
   # Edit: android/app/src/main/AndroidManifest.xml
   # Line 44: Replace the API key
   
   # iOS  
   # Edit: ios/Runner/AppDelegate.swift
   # Line 12: Replace the API key
   ```

---

### Part 2: AdMob App IDs and Ad Units

1. **Go to AdMob Console**
   - Visit: https://apps.admob.com/
   - Sign in with your Google account

2. **Create an App** (if you haven't already)
   - Click "Apps" in the left menu
   - Click "Add app"
   - Select platform: **iOS** first
   - Enter app name: "Diaspora Handbook"
   - Select app store: "Apple App Store"
   - Copy the **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)
   - Repeat for **Android**:
     - Click "Add app" again
     - Select platform: **Android**
     - Enter app name: "Diaspora Handbook"
     - Select app store: "Google Play Store"
     - Copy the **App ID**

3. **Create Ad Units**
   For each app (iOS and Android), create these ad units:
   
   a. **Banner Ad**
      - Click "Ad units" > "Add ad unit"
      - Select "Banner"
      - Name: "Diaspora Handbook - Banner"
      - Copy the Ad Unit ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)
   
   b. **Interstitial Ad**
      - Click "Add ad unit" again
      - Select "Interstitial"
      - Name: "Diaspora Handbook - Interstitial"
      - Copy the Ad Unit ID
   
   c. **Rewarded Ad** (optional, if you plan to use it)
      - Click "Add ad unit" again
      - Select "Rewarded"
      - Name: "Diaspora Handbook - Rewarded"
      - Copy the Ad Unit ID

4. **Replace in Your Code**

   **App IDs:**
   ```bash
   # iOS App ID
   # Edit: ios/Runner/Info.plist
   # Line 59: Replace GADApplicationIdentifier value
   
   # Android App ID
   # Edit: android/app/src/main/AndroidManifest.xml
   # Line 50: Replace com.google.android.gms.ads.APPLICATION_ID value
   ```

   **Ad Unit IDs:**
   ```bash
   # Edit: lib/services/ad_service.dart
   # Replace the test ad unit IDs with your production ones
   ```

---

## Quick Reference: Files to Edit

### 1. Google Maps API Key
- ✅ `android/app/src/main/AndroidManifest.xml` (line 44)
- ✅ `ios/Runner/AppDelegate.swift` (line 12)

### 2. AdMob App IDs
- ✅ `ios/Runner/Info.plist` (line 59) - `GADApplicationIdentifier`
- ✅ `android/app/src/main/AndroidManifest.xml` (line 50) - `com.google.android.gms.ads.APPLICATION_ID`

### 3. AdMob Ad Unit IDs
- ✅ `lib/services/ad_service.dart` - Replace test IDs with production IDs

---

## After Getting Your Keys

Once you have your production keys, I can help you replace them in the code. Just provide:
1. Your Google Maps API key
2. Your AdMob iOS App ID
3. Your AdMob Android App ID
4. Your AdMob Ad Unit IDs (Banner, Interstitial, Rewarded - for both iOS and Android)

Or you can replace them yourself using the file locations above.

---

## Important Notes

⚠️ **Security**: 
- Never commit production API keys to public repositories
- Consider using environment variables or secure storage for production
- Restrict your API keys to only the services and apps that need them

⚠️ **Testing**:
- Test ads will still work during development (AdMob shows test ads automatically)
- Once you replace with production keys, you'll see real ads
- Make sure your AdMob account is approved before going live

⚠️ **Billing**:
- Google Maps: Free tier includes $200/month credit (usually enough for small apps)
- AdMob: Free to use, you get paid when ads are shown

---

## Need Help?

If you've already created these keys but can't find them:
1. **Google Maps**: Check Google Cloud Console > APIs & Services > Credentials
2. **AdMob**: Check AdMob Console > Apps (for App IDs) and Ad units (for Ad Unit IDs)

Let me know if you need help finding or replacing any of these keys!

