import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'providers/events_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/reminders_provider.dart';
import 'providers/registration_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/search_provider.dart';
import 'providers/achievements_provider.dart';
import 'providers/checkins_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';

void main() {
  // Set up zone for async error handling FIRST
  runZonedGuarded(() async {
    // Initialize Flutter bindings inside the zone
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Log error to crash reporting service in production
      print('Flutter Error: ${details.exceptionAsString()}');
    };
    
    await initializeDateFormatting();
    
    // Initialize services (non-blocking for faster startup)
    // Notification service - can be initialized later
    NotificationService().initialize().catchError((e) {
      print('Error initializing notification service: $e');
    });
    
    // Ad service - initialize in background, don't block app startup
    AdService().initialize().catchError((e) {
      print('Error initializing ad service: $e');
    });
    
    // Run app immediately - services will initialize in background
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => FeedProvider()),
          ChangeNotifierProvider(create: (context) => EventsProvider()),
          ChangeNotifierProxyProvider<EventsProvider, FavoritesProvider>(
            create: (context) => FavoritesProvider(context.read<EventsProvider>()),
            update: (context, eventsProvider, previous) =>
                previous ?? FavoritesProvider(eventsProvider),
          ),
          ChangeNotifierProvider(create: (context) => RemindersProvider()),
          ChangeNotifierProvider(create: (context) => RegistrationProvider()),
          ChangeNotifierProvider(create: (context) => SettingsProvider()),
          ChangeNotifierProvider(create: (context) => SearchProvider()),
          ChangeNotifierProvider(create: (context) => AchievementsProvider()),
          ChangeNotifierProvider(create: (context) => CheckInsProvider()),
          ChangeNotifierProvider(create: (context) => ChatProvider()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    // Handle async errors that weren't caught
    print('Uncaught error: $error');
    print('Stack trace: $stack');
    // In production, send to crash reporting service
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Diaspora Handbook',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

/// Splash screen to check if onboarding is needed
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 500));
    
    final hasCompleted = await OnboardingScreen.hasCompletedOnboarding();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => hasCompleted 
              ? const MainScreen() 
              : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          ],
        ),
      ),
    );
  }
}
