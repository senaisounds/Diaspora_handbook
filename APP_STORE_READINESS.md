# App Store Readiness Checklist

## ✅ What's Ready

### Basic Configuration
- ✅ App version set: `1.0.0+2`
- ✅ App display name: "Diaspora Handbook"
- ✅ Bundle ID configured (iOS)
- ✅ Application ID configured (Android): `com.senaimotley.diasporahandbook`
- ✅ App icons configured for both platforms
- ✅ Launch screens configured

### Permissions & Privacy
- ✅ Notification permissions (iOS & Android)
- ✅ Location permissions (iOS & Android)
- ✅ Calendar permissions (iOS)
- ⚠️ **MISSING: Photo Library permission for image picker (iOS)**

### Features
- ✅ User authentication
- ✅ Social feed
- ✅ Event scheduling
- ✅ Profile management with avatars
- ✅ Maps integration
- ✅ Ad integration (AdMob)
- ✅ Notifications

### Testing
- ✅ Unit tests (18 tests passing)
- ✅ Widget tests

## ❌ Critical Issues to Fix Before Submission

### 1. **Missing Photo Library Permission (iOS) - CRITICAL**
   - **Issue**: `image_picker` requires `NSPhotoLibraryUsageDescription` in Info.plist
   - **Fix**: Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photos to let you set a profile picture.</string>
   <key>NSCameraUsageDescription</key>
   <string>We need access to your camera to let you take a profile picture.</string>
   ```

### 2. **Test Ad IDs Still in Use - CRITICAL**
   - **Issue**: Both iOS and Android are using Google's test Ad IDs
   - **Current iOS**: `ca-app-pub-3940256099942544~1458002511`
   - **Current Android**: `ca-app-pub-3940256099942544~3347511713`
   - **Fix**: Replace with your real AdMob App IDs from AdMob console

### 3. **Test Google Maps API Key - CRITICAL**
   - **Issue**: Using a test/development API key
   - **Current**: `AIzaSyAR3htMyrXioNXKjdmR0qT9u2bmf-RsF3s`
   - **Fix**: 
     - Create production API key in Google Cloud Console
     - Restrict it to your app's bundle IDs
     - Replace in both `AndroidManifest.xml` and iOS configuration

### 4. **Android App Label - MINOR**
   - **Issue**: Android app label is still "diaspora_handbook" (lowercase)
   - **Fix**: Change in `AndroidManifest.xml`:
   ```xml
   android:label="Diaspora Handbook"
   ```

### 5. **Release Signing Configuration - CRITICAL**
   - **Issue**: Android is using debug signing for release builds
   - **Fix**: Create a release keystore and configure in `android/app/build.gradle.kts`

### 6. **iOS Bundle Identifier - CHECK**
   - **Issue**: Need to verify the bundle ID matches your Apple Developer account
   - **Check**: `ios/Runner.xcodeproj` - ensure PRODUCT_BUNDLE_IDENTIFIER matches your App Store Connect app

## 📋 App Store Connect Requirements

### Required Information
- [ ] App name (max 30 characters)
- [ ] Subtitle (max 30 characters)
- [ ] Description (max 4000 characters)
- [ ] Keywords (max 100 characters)
- [ ] Support URL
- [ ] Marketing URL (optional)
- [ ] Privacy Policy URL (REQUIRED for apps with user accounts)
- [ ] App icon (1024x1024 PNG)
- [ ] Screenshots (various sizes for different devices)
- [ ] App preview videos (optional)

### Privacy Requirements
- [ ] **Privacy Policy** - REQUIRED (you collect user data: emails, usernames, photos)
- [ ] Privacy nutrition labels in App Store Connect
- [ ] Data collection disclosure

### Content Guidelines
- [ ] Age rating questionnaire
- [ ] Export compliance information
- [ ] Content rights (if using third-party content)

## 🔧 Pre-Submission Tasks

### iOS Specific
1. ✅ Add photo library permissions
2. ✅ Replace test Ad ID with production Ad ID
3. ✅ Replace test Maps API key with production key
4. ✅ Configure App Store Connect app
5. ✅ Create App Store screenshots
6. ✅ Write app description and metadata
7. ✅ Set up App Store Connect pricing
8. ✅ Configure in-app purchases (if any)
9. ✅ Archive and upload build via Xcode or `flutter build ipa`
10. ✅ Submit for review

### Android Specific
1. ✅ Fix app label
2. ✅ Replace test Ad ID with production Ad ID
3. ✅ Replace test Maps API key with production key
4. ✅ Create release keystore
5. ✅ Configure release signing
6. ✅ Create Google Play Console listing
7. ✅ Write app description and metadata
8. ✅ Create Play Store screenshots
9. ✅ Set up privacy policy
10. ✅ Build release APK/AAB: `flutter build appbundle`
11. ✅ Upload to Google Play Console
12. ✅ Submit for review

## 🚨 Security Considerations

### Before Production
- [ ] Remove any debug logging
- [ ] Remove test API keys
- [ ] Remove test user accounts
- [ ] Review error messages (don't expose sensitive info)
- [ ] Ensure HTTPS for all API calls
- [ ] Review backend security (SQL injection, XSS, etc.)

## 📝 Recommended Next Steps

1. **IMMEDIATE**: Add photo library permissions to iOS Info.plist
2. **IMMEDIATE**: Create production API keys (Maps, AdMob)
3. **IMMEDIATE**: Create release keystore for Android
4. **BEFORE SUBMISSION**: Write privacy policy
5. **BEFORE SUBMISSION**: Create App Store/Play Store screenshots
6. **BEFORE SUBMISSION**: Test on real devices (iOS and Android)
7. **BEFORE SUBMISSION**: Test all features end-to-end
8. **BEFORE SUBMISSION**: Review App Store/Play Store guidelines

## ⚠️ Important Notes

- **Privacy Policy is MANDATORY** - Your app collects:
  - User account information (email, username)
  - Profile photos
  - User-generated content (posts)
  - Location data (for maps)
  
- **TestFlight/Internal Testing**: Consider using TestFlight (iOS) and Internal Testing (Android) before public release

- **Backend**: Ensure your backend is production-ready:
  - Proper error handling
  - Rate limiting
  - Security headers
  - Database backups
  - Monitoring/logging

