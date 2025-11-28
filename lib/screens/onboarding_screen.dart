import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const String _onboardingCompleteKey = 'onboarding_complete';

  /// Check if onboarding has been completed
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as complete
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  /// Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
  }

  void _onDone(BuildContext context) async {
    await completeOnboarding();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 16, height: 1.5);
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: Color(0xFFFFD700),
      ),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color(0xFF1A1A1A),
      imagePadding: EdgeInsets.zero,
      contentMargin: EdgeInsets.symmetric(horizontal: 16),
    );

    return IntroductionScreen(
      key: const ValueKey('onboarding_screen'),
      globalBackgroundColor: const Color(0xFF1A1A1A),
      pages: [
        PageViewModel(
          title: "Welcome to\nDiaspora Handbook",
          body: "Your ultimate guide to Homecoming Season! Discover events, connect with the community, and make unforgettable memories.",
          image: _buildImage('assets/icon.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Discover Events",
          body: "Browse through a curated collection of parties, cultural events, performances, and more. Filter by category, search by name, and find exactly what you're looking for.",
          image: _buildIcon(Icons.event, const Color(0xFFFFD700)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Create Your Plan",
          body: "Favorite events to build your personal schedule. Get reminders, add events to your calendar, and never miss a moment.",
          image: _buildIcon(Icons.favorite, Colors.red),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Check In & Earn",
          body: "Check in to events you attend and unlock achievements! Track your progress, compete on leaderboards, and show off your homecoming spirit.",
          image: _buildIcon(Icons.check_circle, Colors.green),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Stay Connected",
          body: "Join community channels to chat with other attendees, share photos, and stay updated on the latest happenings.",
          image: _buildIcon(Icons.forum, const Color(0xFFFFD700)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Ready to Begin?",
          body: "You're all set! Start exploring events and make this Homecoming Season one to remember. Let's go! 🎉",
          image: _buildIcon(Icons.celebration, const Color(0xFFFFD700)),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onDone(context),
      onSkip: () => _onDone(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      skip: const Text(
        'Skip',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
      next: const Icon(
        Icons.arrow_forward,
        color: Color(0xFFFFD700),
      ),
      done: const Text(
        'Get Started',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFD700),
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.white24,
        activeSize: Size(22.0, 10.0),
        activeColor: Color(0xFFFFD700),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  Widget _buildImage(String assetName, {double width = 200}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Image.asset(assetName, width: width),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: Icon(
            icon,
            size: 120,
            color: color,
          ),
        ),
      ),
    );
  }
}

