import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/haptic_service.dart';
import '../services/feedback_service.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      // Keep default version
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Enable event reminders and notifications'),
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    HapticService.selectionClick();
                    settings.setNotificationsEnabled(value);
                    if (!value) {
                      // Cancel all reminders if notifications are disabled
                      NotificationService().cancelAllReminders();
                    }
                  },
                  secondary: const Icon(Icons.notifications),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('Light Mode'),
                      value: ThemeMode.light,
                      groupValue: settings.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          HapticService.selectionClick();
                          settings.setThemeMode(value);
                        }
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark Mode'),
                      value: ThemeMode.dark,
                      groupValue: settings.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          HapticService.selectionClick();
                          settings.setThemeMode(value);
                        }
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      value: ThemeMode.system,
                      groupValue: settings.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          HapticService.selectionClick();
                          settings.setThemeMode(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.feedback, color: Color(0xFFFFD700)),
                  title: const Text('Send Feedback'),
                  subtitle: const Text('Report bugs or suggest features'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticService.lightImpact();
                    FeedbackService().showFeedbackDialog(context);
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.school, color: Color(0xFFFFD700)),
                  title: const Text('Show Tutorial'),
                  subtitle: const Text('View the app tutorial again'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticService.lightImpact();
                    _showTutorialDialog(context);
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  subtitle: Text(_appVersion),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('About Diaspora Handbook'),
                  subtitle: const Text('Homecoming Season Guide'),
                  onTap: () {
                    HapticService.lightImpact();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About'),
                        content: const Text(
                          'Diaspora Handbook - Homecoming Season Guide\n\n'
                          'Your comprehensive guide to all events during the Homecoming Season. '
                          'Discover events, create your schedule, and never miss an important moment.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              HapticService.lightImpact();
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Tutorial'),
        content: const Text(
          'Would you like to view the onboarding tutorial again? '
          'This will restart the app and show you the welcome screens.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticService.mediumImpact();
              await OnboardingScreen.resetOnboarding();
              
              if (context.mounted) {
                // Navigate to onboarding screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: const Text('Show Tutorial'),
          ),
        ],
      ),
    );
  }
}
