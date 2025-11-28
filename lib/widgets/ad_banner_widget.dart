import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// A reusable banner ad widget that can be placed at the bottom of screens
/// 
/// Usage:
/// ```dart
/// AdBannerWidget()
/// ```
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Delay loading to avoid layout issues during initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  Future<void> _loadAd() async {
    if (!mounted) return;
    
    if (!AdService().shouldShowAds()) {
      return;
    }

    try {
      final bannerAd = AdService().createBannerAd();
      if (bannerAd != null && mounted) {
        // Set up listener to update state when ad loads
        bannerAd.load();
        
        setState(() {
          _bannerAd = bannerAd;
        });
      }
    } catch (e) {
      // Handle plugin not available or other errors gracefully
      print('Ad widget error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if ads shouldn't be shown or if there's an error
    if (!AdService().shouldShowAds() || _hasError) {
      return const SizedBox.shrink();
    }

    // Show ad widget only if ad is loaded
    if (_bannerAd != null) {
      try {
        return SizedBox(
          height: AdSize.banner.height.toDouble(),
          width: double.infinity,
          child: AdWidget(ad: _bannerAd!),
        );
      } catch (e) {
        // If AdWidget fails, return empty widget
        print('AdWidget error: $e');
        return const SizedBox.shrink();
      }
    }

    // Return empty widget while loading
    return const SizedBox.shrink();
  }
}

