import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  Future<void> _openInstagram(BuildContext context, String handle) async {
    // Remove @ if present
    final cleanHandle = handle.replaceFirst('@', '');
    
    // Try to open Instagram app first, then fallback to web
    final instagramAppUrl = Uri.parse('instagram://user?username=$cleanHandle');
    final instagramWebUrl = Uri.parse('https://www.instagram.com/$cleanHandle/');
    
    try {
      // Try Instagram app first
      if (await canLaunchUrl(instagramAppUrl)) {
        await launchUrl(instagramAppUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web
        await launchUrl(instagramWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // If both fail, show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Instagram: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<User>(
        future: context.read<AuthProvider>().getUserProfile(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load profile'),
                  TextButton(
                    onPressed: () {
                      // Retry by rebuilding
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!;
          final baseUrl = ApiService().baseUrl.replaceAll('/api', '');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFFFD700),
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage('$baseUrl${user.avatarUrl}')
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 40, color: Colors.black),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (user.habeshaStatus != null && user.habeshaStatus!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      user.habeshaStatus!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFFFFD700),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                const SizedBox(height: 32),
                if (user.instagramHandle != null && user.instagramHandle!.isNotEmpty)
                  Card(
                    color: Colors.white.withOpacity(0.05),
                    child: InkWell(
                      onTap: () => _openInstagram(context, user.instagramHandle!),
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: const Icon(Icons.camera_alt, color: Color(0xFFFFD700)),
                        title: const Text('Instagram'),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text('@${user.instagramHandle}'),
                            ),
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

