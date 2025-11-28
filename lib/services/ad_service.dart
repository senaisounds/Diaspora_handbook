import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ad Service for managing Google AdMob advertisements in the app
/// 
/// IMPORTANT: Replace test ad unit IDs with your actual AdMob ad unit IDs
/// Get them from: https://apps.admob.com/
/// 
/// Test IDs (for development - provided by Google):
/// - Banner: ca-app-pub-3940256099942544/6300978111
/// - Interstitial: ca-app-pub-3940256099942544/1033173712
/// - Rewarded: ca-app-pub-3940256099942544/5224354917

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _initialized = false;
  int _interstitialAdCounter = 0;
  static const int _interstitialAdFrequency = 4; // Show interstitial every 4th event
  
  // TEST MODE: Set to true to use test ad unit IDs
  // Set to false and provide real ad unit IDs for production
  static const bool _isTestMode = true;
  
  // Test ad unit IDs (provided by Google for testing)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  // Production ad unit IDs (replace with your actual IDs from AdMob)
  static const String _prodBannerAdUnitId = 'YOUR_PRODUCTION_BANNER_AD_UNIT_ID';
  static const String _prodInterstitialAdUnitId = 'YOUR_PRODUCTION_INTERSTITIAL_AD_UNIT_ID';
  static const String _prodRewardedAdUnitId = 'YOUR_PRODUCTION_REWARDED_AD_UNIT_ID';
  
  // Get the appropriate ad unit ID based on test mode
  static String get bannerAdUnitId => _isTestMode ? _testBannerAdUnitId : _prodBannerAdUnitId;
  static String get interstitialAdUnitId => _isTestMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;
  static String get rewardedAdUnitId => _isTestMode ? _testRewardedAdUnitId : _prodRewardedAdUnitId;
  
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  /// Initialize the ad service
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await MobileAds.instance.initialize();
      
      // Configure test device IDs for testing with real ad units
      // Uncomment and add your device ID if testing with production ad units
      // You'll see the device ID in console logs when running the app
      /*
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [
            'YOUR_DEVICE_ID_HERE', // Get this from console logs
          ],
        ),
      );
      */
      
      if (_isTestMode) {
        print('🧪 AdMob TEST MODE: Using test ad unit IDs');
        print('   Banner: $bannerAdUnitId');
        print('   Interstitial: $interstitialAdUnitId');
      } else {
        print('📱 AdMob PRODUCTION MODE: Using production ad unit IDs');
      }
      
      _loadInterstitialAd(); // Preload interstitial ad
      _initialized = true;
      print('✅ AdMob initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize ads: $e');
      print('⚠️  This is normal if the plugin isn\'t properly linked. Do a full rebuild.');
      // Continue without ads if initialization fails
      // This allows the app to run even if ads aren't available
      _initialized = true;
    }
  }

  /// Check if ads should be shown (e.g., based on user subscription status)
  bool shouldShowAds() {
    // TODO: Check if user has premium subscription
    // Example: return !SettingsProvider().isPremium;
    return true;
  }

  /// Create a banner ad
  BannerAd? createBannerAd() {
    if (!shouldShowAds() || !_initialized) return null;
    
    try {
      final bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            print('✅ Banner ad loaded successfully');
            if (_isTestMode) {
              print('   🧪 TEST AD - This is a test ad from Google');
            }
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Banner ad failed to load: $error');
            print('   Error code: ${error.code}, message: ${error.message}');
            // Don't dispose immediately - let the widget handle it
            // This prevents layout issues
          },
          onAdOpened: (_) {
            print('👆 Banner ad opened');
          },
          onAdClosed: (_) {
            print('👋 Banner ad closed');
          },
          onAdImpression: (_) {
            print('👁️  Banner ad impression recorded');
          },
        ),
      );
      
      print('🔄 Loading banner ad...');
      return bannerAd;
    } catch (e) {
      print('❌ Failed to create banner ad: $e');
      return null;
    }
  }

  /// Load an interstitial ad
  void _loadInterstitialAd() {
    if (!shouldShowAds() || !_initialized) return;
    
    print('🔄 Loading interstitial ad...');
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          print('✅ Interstitial ad loaded successfully');
          if (_isTestMode) {
            print('   🧪 TEST AD - This is a test ad from Google');
          }
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('👋 Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // Load next ad
            },
            onAdShowedFullScreenContent: (_) {
              print('👁️  Interstitial ad showed full screen');
            },
            onAdImpression: (_) {
              print('👁️  Interstitial ad impression recorded');
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial ad failed to load: $error');
          print('   Error code: ${error.code}, message: ${error.message}');
          _isInterstitialAdReady = false;
          // Retry after a delay
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  /// Show an interstitial ad
  /// This should be called before navigating to a new screen
  /// Set force=true to bypass frequency capping (useful for testing)
  Future<void> showInterstitialAd({bool force = false}) async {
    if (!shouldShowAds() && !force) return;
    if (!_initialized) return;
    
    _interstitialAdCounter++;
    
    // Only show interstitial every N times (to avoid annoying users)
    if (!force && _interstitialAdCounter % _interstitialAdFrequency != 0) {
      print('⏭️  Interstitial ad skipped (frequency capping: ${_interstitialAdCounter % _interstitialAdFrequency}/$_interstitialAdFrequency)');
      return;
    }
    
    if (_isInterstitialAdReady && _interstitialAd != null) {
      try {
        print('🎬 Showing interstitial ad...');
        await _interstitialAd!.show();
        _isInterstitialAdReady = false;
      } catch (e) {
        print('❌ Failed to show interstitial ad: $e');
        _loadInterstitialAd(); // Try to load next ad
      }
    } else {
      print('⏳ Interstitial ad not ready yet, loading...');
      // Ad not ready, try to load it
      _loadInterstitialAd();
    }
  }
  
  /// Force show an interstitial ad (for testing)
  /// This bypasses frequency capping
  Future<void> showInterstitialAdForTesting() async {
    await showInterstitialAd(force: true);
  }

  /// Show a rewarded ad
  /// Returns true if ad was shown and user completed it
  Future<bool> showRewardedAd() async {
    if (!shouldShowAds() || !_initialized) return false;
    
    // TODO: Implement rewarded ads if needed
    // This requires a rewarded ad unit ID
    return false;
  }

  /// Reset the interstitial ad counter (useful for testing)
  void resetInterstitialCounter() {
    _interstitialAdCounter = 0;
    print('🔄 Interstitial ad counter reset');
  }
  
  /// Get current interstitial ad counter (for testing)
  int get interstitialAdCounter => _interstitialAdCounter;
  
  /// Check if interstitial ad is ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  
  /// Check if ads are in test mode
  bool get isTestMode => _isTestMode;

  /// Dispose of ads (call when app is closing)
  void dispose() {
    _interstitialAd?.dispose();
  }
}

