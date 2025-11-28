# Ads Implementation Guide

This guide shows you exactly where to implement ads in your Diaspora Handbook app.

## 📍 Ad Placement Locations

### 1. **HomeScreen** (`lib/screens/home_screen.dart`)

#### Banner Ad at Bottom
Add after the event list, before the floating action button (around line 564):

```dart
// After the ListView.builder for events
Expanded(
  child: RefreshIndicator(
    // ... existing code ...
  ),
),
// ADD BANNER AD HERE
const AdBannerWidget(),
```

#### Native Ads in Event List
Insert between event cards (e.g., every 5th item) in the ListView.builder (around line 544):

```dart
itemBuilder: (context, index) {
  final event = currentWeekEvents[index];
  
  // Show native ad every 5th item
  if (index > 0 && index % 5 == 0) {
    return Column(
      children: [
        EventCard(
          event: event,
          onTap: () { /* ... */ },
        ),
        const SizedBox(height: 8),
        const AdBannerWidget(), // Native ad
        const SizedBox(height: 8),
      ],
    );
  }
  
  return EventCard(
    event: event,
    onTap: () { /* ... */ },
  );
}
```

#### Interstitial Ad on Event Tap
Add before navigating to EventDetailScreen (around line 551):

```dart
onTap: () {
  HapticService.lightImpact();
  // Show interstitial ad before navigation
  AdService().showInterstitialAd();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EventDetailScreen(event: event),
    ),
  );
},
```

---

### 2. **EventDetailScreen** (`lib/screens/event_detail_screen.dart`)

#### Banner Ad After About Section
Add after the description, before "Nearby Events" (around line 360):

```dart
Text(
  event.description,
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
),
const SizedBox(height: 16),
// ADD BANNER AD HERE
const AdBannerWidget(),
const SizedBox(height: 16),
// Nearby Events Section
_buildNearbyEvents(context, event),
```

---

### 3. **ScheduleScreen** (`lib/screens/schedule_screen.dart`)

#### Banner Ad at Bottom
Add at the bottom of the event list (around line 201):

```dart
: ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: selectedEvents.length,
    itemBuilder: (context, index) {
      // ... existing event card code ...
    },
  ),
  // ADD BANNER AD HERE
  const AdBannerWidget(),
),
```

#### Native Ads Between Events
Insert in the ListView.builder (around line 129):

```dart
itemBuilder: (context, index) {
  final event = selectedEvents[index];
  
  // Show native ad every 3rd item
  if (index > 0 && index % 3 == 0) {
    return Column(
      children: [
        // Existing event card code...
        const SizedBox(height: 8),
        const AdBannerWidget(),
        const SizedBox(height: 8),
      ],
    );
  }
  
  // Existing event card code...
}
```

---

### 4. **FavoritesScreen** (`lib/screens/favorites_screen.dart`)

#### Banner Ad at Bottom
Add at the bottom of the event list (around line 352):

```dart
: ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: selectedDayEvents.length,
    itemBuilder: (context, index) {
      // ... existing event card code ...
    },
  ),
  // ADD BANNER AD HERE
  const AdBannerWidget(),
),
```

---

### 5. **MainScreen** (`lib/screens/main_screen.dart`)

#### Interstitial Ad on Tab Switch
Add in the `_onItemTapped` method (around line 23):

```dart
void _onItemTapped(int index) {
  HapticService.selectionClick();
  
  // Show interstitial ad when switching tabs (with frequency limit)
  if (index != _selectedIndex) {
    AdService().showInterstitialAd();
  }
  
  setState(() {
    _selectedIndex = index;
  });
}
```

---

## 🚀 Setup Instructions

### Step 1: Add Ad SDK to pubspec.yaml

For Google AdMob (most common):
```yaml
dependencies:
  google_mobile_ads: ^5.0.0
```

For other ad networks:
- Facebook Audience Network: `audience_network`
- Unity Ads: `unity_ads_flutter`
- AppLovin: `applovin_max`

### Step 2: Initialize Ad Service in main.dart

```dart
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Initialize ad service
  await AdService().initialize();
  
  runApp(/* ... */);
}
```

### Step 3: Update AdService with Real Ad SDK

Replace the placeholder methods in `lib/services/ad_service.dart` with actual ad SDK calls. See the comments in that file for examples.

### Step 4: Get Ad Unit IDs

1. Create an account with your ad network (e.g., Google AdMob)
2. Create ad units for:
   - Banner ads
   - Interstitial ads
   - Rewarded ads (optional)
3. Replace the test ad unit IDs in `AdService` with your real IDs

### Step 5: Add Permissions (Android)

In `android/app/src/main/AndroidManifest.xml`, add:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### Step 6: Add Permissions (iOS)

In `ios/Runner/Info.plist`, add:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

---

## 💡 Best Practices

1. **Frequency Capping**: Don't show interstitial ads too frequently (already implemented with `_interstitialAdFrequency`)

2. **User Experience**: 
   - Don't show ads immediately on app launch
   - Don't interrupt critical user flows
   - Consider showing ads after user completes an action

3. **Premium Users**: 
   - Hide ads for premium/subscribed users
   - Implement this in `AdService.shouldShowAds()`

4. **Testing**: 
   - Always use test ad unit IDs during development
   - Test on both Android and iOS
   - Test with different screen sizes

5. **Performance**:
   - Preload interstitial ads when possible
   - Dispose of ad objects properly to avoid memory leaks

---

## 📊 Recommended Ad Placement Priority

**High Priority (Most Revenue):**
1. Banner ad at bottom of HomeScreen
2. Interstitial ad when opening EventDetailScreen
3. Banner ad in EventDetailScreen

**Medium Priority:**
4. Banner ad in ScheduleScreen
5. Banner ad in FavoritesScreen
6. Interstitial ad on tab switch (with frequency limit)

**Low Priority (Optional):**
7. Native ads between event cards
8. Rewarded ads for premium features

---

## 🔧 Troubleshooting

- **Ads not showing**: Check ad unit IDs, network connection, and ad SDK initialization
- **App crashes**: Ensure ad SDK is properly initialized before showing ads
- **Low fill rate**: Consider using multiple ad networks or mediation

---

## 📝 Notes

- The current implementation uses placeholder widgets
- Replace `AdService` methods with actual ad SDK calls
- Test thoroughly before releasing to production
- Monitor ad performance and adjust placement as needed

