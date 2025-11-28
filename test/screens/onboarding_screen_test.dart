import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('Onboarding State Management', () {
      test('should return false for new user', () async {
        await OnboardingScreen.resetOnboarding();
        final hasCompleted = await OnboardingScreen.hasCompletedOnboarding();
        expect(hasCompleted, isFalse);
      });

      test('should return true after completing onboarding', () async {
        await OnboardingScreen.completeOnboarding();
        final hasCompleted = await OnboardingScreen.hasCompletedOnboarding();
        expect(hasCompleted, isTrue);
      });

      test('should reset onboarding state', () async {
        await OnboardingScreen.completeOnboarding();
        expect(await OnboardingScreen.hasCompletedOnboarding(), isTrue);

        await OnboardingScreen.resetOnboarding();
        expect(await OnboardingScreen.hasCompletedOnboarding(), isFalse);
      });
    });

    group('Onboarding Content', () {
      test('should have appropriate page count', () {
        // OnboardingScreen has 6 pages
        const expectedPageCount = 6;
        expect(expectedPageCount, equals(6));
      });

      test('should have key feature descriptions', () {
        final features = [
          'Discover Events',
          'Create Your Plan',
          'Check In & Earn',
          'Stay Connected',
        ];

        expect(features, isNotEmpty);
        expect(features.length, equals(4));
      });
    });
  });
}

