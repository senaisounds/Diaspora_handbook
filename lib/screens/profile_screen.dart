import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/achievements_provider.dart';
import '../services/api_service.dart';
import 'auth/login_screen.dart';
import 'achievements_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _instagramController = TextEditingController();
  final _habeshaStatusController = TextEditingController();
  File? _newAvatarFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _instagramController.text = user.instagramHandle ?? '';
      _habeshaStatusController.text = user.habeshaStatus ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newAvatarFile = File(pickedFile.path);
        _isEditing = true; // Automatically enable edit mode when picking image
      });
    }
  }

  Future<void> _openInstagram(String? handle) async {
    if (handle == null || handle.isEmpty) return;
    
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Instagram: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      await context.read<AuthProvider>().updateProfile(
        instagram: _instagramController.text.trim(),
        habeshaStatus: _habeshaStatusController.text.trim(),
        avatarFile: _newAvatarFile,
      );
      setState(() {
        _isEditing = false;
        _newAvatarFile = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (!auth.isAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Join the community'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Login / Register'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = auth.user;
        final baseUrl = ApiService().baseUrl.replaceAll('/api', ''); // Helper to get base URL for images

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                      _loadUserData();
                    });
                  },
                )
              else
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveProfile,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFFFD700),
                      backgroundImage: _newAvatarFile != null
                          ? FileImage(_newAvatarFile!)
                          : (user?.avatarUrl != null
                              ? NetworkImage('$baseUrl${user!.avatarUrl}')
                              : null) as ImageProvider?,
                      child: (_newAvatarFile == null && user?.avatarUrl == null)
                          ? Text(
                              user?.username.substring(0, 1).toUpperCase() ?? '?',
                              style: const TextStyle(fontSize: 40, color: Colors.black),
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFFFD700),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.username ?? 'User',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 32),
                
                // Instagram Section
                _buildInfoSection(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Instagram',
                  value: user?.instagramHandle,
                  controller: _instagramController,
                  isEditing: _isEditing,
                  prefix: '@',
                  isClickable: true,
                ),
                
                const SizedBox(height: 16),
                
                // Habesha Status Section
                _buildInfoSection(
                  context,
                  icon: Icons.question_answer,
                  label: 'How Habesha are you?',
                  value: user?.habeshaStatus,
                  controller: _habeshaStatusController,
                  isEditing: _isEditing,
                ),

                const SizedBox(height: 32),
                
                // Achievements Section
                _buildAchievementsSection(context),

                const SizedBox(height: 32),
                if (_isEditing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _newAvatarFile = null;
                            _loadUserData();
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                  
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    auth.logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? value,
    required TextEditingController controller,
    required bool isEditing,
    String? prefix,
    bool isClickable = false,
  }) {
    final hasValue = value?.isNotEmpty ?? false;
    
    return Card(
      color: Colors.white.withOpacity(0.05),
      child: InkWell(
        onTap: (!isEditing && hasValue && isClickable) 
            ? () => _openInstagram(value)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFFD700)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isEditing)
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          prefixText: prefix,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hasValue 
                                  ? '${prefix ?? ''}$value' 
                                  : 'Not set',
                              style: TextStyle(
                                color: hasValue 
                                    ? Colors.white 
                                    : Colors.grey[600],
                                fontStyle: hasValue 
                                    ? FontStyle.normal 
                                    : FontStyle.italic,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (hasValue && isClickable && !isEditing)
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Consumer<AchievementsProvider>(
      builder: (context, achievementsProvider, child) {
        final unlockedCount = achievementsProvider.unlockedCount;
        final totalCount = achievementsProvider.totalAchievements;
        final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
        final unlockedAchievements = achievementsProvider.unlockedAchievements;
        final recentAchievements = unlockedAchievements.take(3).toList();

        return Card(
          color: Colors.white.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Achievements',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$unlockedCount of $totalCount unlocked',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (unlockedCount > 0)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AchievementsScreen(),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFD700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Recent Achievements
                if (unlockedCount > 0) ...[
                  Text(
                    'Recent Achievements',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recentAchievements.map((achievement) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                achievement.type.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement.type.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM d, yyyy').format(achievement.unlockedAt),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (unlockedCount > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AchievementsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'View ${unlockedCount - 3} more',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ),
                    ),
                ] else ...[
                  Text(
                    'Start exploring events to unlock achievements!',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                    child: const Text('View All Achievements'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
