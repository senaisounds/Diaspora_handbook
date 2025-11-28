import 'package:flutter/services.dart';

/// Service for providing haptic feedback throughout the app
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  /// Light haptic feedback for subtle interactions
  /// Use for: taps, light selections, minor UI changes
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore errors if haptic feedback is not available
    }
  }

  /// Medium haptic feedback for standard interactions
  /// Use for: button presses, confirmations, selections
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignore errors if haptic feedback is not available
    }
  }

  /// Heavy haptic feedback for significant actions
  /// Use for: important confirmations, achievements, major actions
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignore errors if haptic feedback is not available
    }
  }

  /// Selection haptic feedback for list/item selections
  /// Use for: picking options, scrolling through items, toggles
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Ignore errors if haptic feedback is not available
    }
  }

  /// Vibration for notifications/alerts
  /// Use for: errors, important alerts
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Ignore errors if haptic feedback is not available
    }
  }

  /// Success feedback - combination of medium + light impacts
  /// Use for: successful actions, confirmations
  static Future<void> success() async {
    try {
      await mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await lightImpact();
    } catch (e) {
      // Ignore errors if haptic feedback is not available
    }
  }

  /// Achievement unlock feedback - strong vibration pattern
  /// Use for: achievement unlocks, major milestones
  static Future<void> achievementUnlock() async {
    try {
      await heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await lightImpact();
    } catch (e) {
      // Ignore errors if haptic feedback is not available
    }
  }

  /// Error feedback - short vibration
  /// Use for: errors, invalid actions
  static Future<void> error() async {
    try {
      await heavyImpact();
    } catch (e) {
      // Ignore errors if haptic feedback is not available
    }
  }
}

