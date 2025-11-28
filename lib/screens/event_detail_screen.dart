import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';
import '../models/event.dart';
import '../providers/events_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/reminders_provider.dart';
import '../providers/registration_provider.dart';
import '../providers/checkins_provider.dart';
import '../providers/achievements_provider.dart';
import '../services/calendar_service.dart';
import '../services/location_service.dart';
import '../services/haptic_service.dart';
import '../services/qr_service.dart';
import '../widgets/event_card.dart';
import '../widgets/ad_banner_widget.dart';
import '../utils/error_handler.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: event.imageUrl != null && event.imageUrl!.isNotEmpty
                  ? FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: event.imageUrl!,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: event.color,
                          child: Center(
                            child: Icon(Icons.event, size: 80, color: Colors.white.withOpacity(0.5)),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: event.color,
                      child: Center(
                        child: Icon(Icons.event, size: 80, color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          label: Text(event.category),
                          backgroundColor: event.color.withOpacity(0.2),
                          labelStyle: TextStyle(color: event.color),
                        ),
                        const Spacer(),
                        Consumer<FavoritesProvider>(
                          builder: (context, favoritesProvider, child) {
                            final isFavorite = favoritesProvider.isFavorite(event.id);
                            return IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
                              onPressed: () async {
                                // Haptic feedback for favorite toggle
                                HapticService.selectionClick();
                                
                                await favoritesProvider.toggleFavorite(event.id);
                                
                                if (!context.mounted) return;
                                
                                // Check achievements
                                final achievementsProvider = Provider.of<AchievementsProvider>(context, listen: false);
                                final favoriteCount = favoritesProvider.favoriteEvents.length;
                                final partyCount = favoritesProvider.favoriteEvents.where((e) => e.category == 'Party').length;
                                final cultureCount = favoritesProvider.favoriteEvents.where((e) => 
                                  ['Exhibition', 'Performance', 'Film', 'Talk'].contains(e.category)
                                ).length;
                                final categoryCount = favoritesProvider.favoriteEvents.map((e) => e.category).toSet().length;
                                
                                final unlockedNewAchievement = await achievementsProvider.checkAchievements(
                                  favoriteCount: favoriteCount,
                                  partyFavoriteCount: partyCount,
                                  cultureFavoriteCount: cultureCount,
                                  categoryCount: categoryCount,
                                );
                                
                                if (unlockedNewAchievement) {
                                  // Special haptic feedback for achievement unlock
                                  HapticService.achievementUnlock();
                                }
                                
                                if (context.mounted) {
                                  // Success haptic feedback
                                  if (isFavorite) {
                                    HapticService.lightImpact();
                                  } else {
                                    if (!unlockedNewAchievement) {
                                      HapticService.success();
                                    }
                                  }
                                  
                                  ErrorHandler.showSuccess(
                                    context,
                                    isFavorite ? 'Removed from My Plan' : 'Added to My Plan',
                                );
                                }
                              },
                            );
                          },
                        ),
                        Consumer<RemindersProvider>(
                          builder: (context, remindersProvider, child) {
                            final hasReminder = remindersProvider.hasReminder(event.id);
                            return IconButton(
                              icon: Icon(
                                hasReminder ? Icons.notifications_active : Icons.notifications_outlined,
                                color: hasReminder ? event.color : null,
                              ),
                              onPressed: () {
                                HapticService.selectionClick();
                                _showReminderDialog(context, event, remindersProvider);
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {
                            HapticService.selectionClick();
                            final timeFormat = DateFormat('h:mm a');
                            final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
                            final shareText = '''
${event.title}

${event.description}

📅 ${dateFormat.format(event.startTime)}
🕐 ${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}
📍 ${event.location}
🏷️ ${event.category}

From Diaspora Handbook - Homecoming Season Guide
                            ''';
                            Share.share(shareText, subject: event.title);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(context, Icons.calendar_today, dateFormat.format(event.startTime)),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, Icons.access_time, '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}'),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final locationService = LocationService();
                        await locationService.openMaps(event.location);
                      },
                      child: _buildInfoRow(
                        context,
                        Icons.location_on,
                        event.location,
                        trailing: const Icon(Icons.open_in_new, size: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Check-in Section
                    Consumer<CheckInsProvider>(
                      builder: (context, checkInsProvider, child) {
                        final isCheckedIn = checkInsProvider.isCheckedIn(event.id);
                        final checkInTime = checkInsProvider.getCheckInTime(event.id);
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCheckedIn
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCheckedIn
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isCheckedIn ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isCheckedIn ? Colors.green : Colors.grey,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isCheckedIn ? 'Checked In!' : 'Check In',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: isCheckedIn ? Colors.green : null,
                                              ),
                                        ),
                                        if (isCheckedIn && checkInTime != null)
                                          Text(
                                            'Checked in on ${DateFormat('MMM d, yyyy at h:mm a').format(checkInTime)}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.green,
                                                ),
                                          )
                                        else
                                          Text(
                                            'Let others know you\'re attending',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!isCheckedIn)
                                        IconButton(
                                          onPressed: () {
                                            HapticService.lightImpact();
                                            QRService().showQRCodeDialog(context, event);
                                          },
                                          icon: const Icon(Icons.qr_code),
                                          tooltip: 'Show QR Code',
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.grey.withOpacity(0.2),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          // Haptic feedback for check-in action
                                          if (isCheckedIn) {
                                            HapticService.lightImpact();
                                            await checkInsProvider.uncheckIn(event.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Check-in removed'),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          } else {
                                            HapticService.success();
                                            await checkInsProvider.checkIn(event.id);
                                            
                                            if (!context.mounted) return;
                                            
                                            // Check achievements
                                            final achievementsProvider = Provider.of<AchievementsProvider>(context, listen: false);
                                            final checkInCount = checkInsProvider.totalCheckIns;
                                            final unlocked = await achievementsProvider.checkAchievements(checkInCount: checkInCount);
                                            
                                            if (unlocked) {
                                              // Special haptic feedback for achievement unlock
                                              HapticService.achievementUnlock();
                                            }
                                            
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(unlocked 
                                                    ? '🎉 Checked in! Achievement unlocked!'
                                                    : '🎉 Checked in successfully!'),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        icon: Icon(isCheckedIn ? Icons.cancel : Icons.check),
                                        label: Text(isCheckedIn ? 'Remove' : 'Check In'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isCheckedIn ? Colors.red : Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              HapticService.mediumImpact();
                              try {
                              final calendarService = CalendarService();
                              final success = await calendarService.addEventToCalendar(event);
                              if (context.mounted) {
                                  if (success) {
                                    ErrorHandler.showSuccess(context, 'Event added to calendar');
                                  } else {
                                    ErrorHandler.showError(context, 'Failed to add event to calendar. Please check calendar permissions.');
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ErrorHandler.showError(context, e);
                                }
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Add to Calendar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: event.color,
                              side: BorderSide(color: event.color),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              HapticService.mediumImpact();
                              try {
                              final locationService = LocationService();
                              await locationService.getDirections(event.location);
                              } catch (e) {
                                if (context.mounted) {
                                  ErrorHandler.showError(context, e);
                                }
                              }
                            },
                            icon: const Icon(Icons.directions, size: 18),
                            label: const Text('Directions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: event.color,
                              side: BorderSide(color: event.color),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Banner ad after About section
                    const AdBannerWidget(),
                    const SizedBox(height: 24),
                    // Nearby Events Section
                    _buildNearbyEvents(context, event),
                    const SizedBox(height: 32),
                    // Similar Events Section
                    _buildSimilarEvents(context, event),
                    const SizedBox(height: 24),
                    Consumer<RemindersProvider>(
                      builder: (context, remindersProvider, child) {
                        final hasReminder = remindersProvider.hasReminder(event.id);
                        final reminderDuration = remindersProvider.getReminder(event.id);
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: hasReminder 
                                ? event.color.withOpacity(0.1) 
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasReminder 
                                  ? event.color.withOpacity(0.3) 
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: hasReminder ? event.color : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Event Reminders',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: hasReminder ? event.color : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasReminder && reminderDuration != null
                                          ? 'Reminder set for ${_formatReminderDuration(reminderDuration)} before event'
                                          : 'Get notified before this event starts',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: hasReminder,
                                onChanged: (value) {
                                  HapticService.selectionClick();
                                  _showReminderDialog(context, event, remindersProvider);
                                },
                                activeColor: event.color,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Consumer<RegistrationProvider>(
                      builder: (context, registrationProvider, child) {
                        final isRegistered = registrationProvider.isRegistered(event.id);
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticService.mediumImpact();
                              _showRegistrationDialog(context, event, registrationProvider);
                            },
                            icon: Icon(isRegistered ? Icons.check_circle : Icons.how_to_reg),
                            label: Text(isRegistered ? 'Registered' : 'Register for Event'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRegistered 
                                  ? Colors.green 
                                  : event.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        if (trailing != null) trailing,
      ],
    );
  }

  void _showRegistrationDialog(BuildContext context, Event event, RegistrationProvider registrationProvider) {
    final isRegistered = registrationProvider.isRegistered(event.id);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRegistered ? 'Registration Confirmed' : 'Register for ${event.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRegistered) ...[
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are registered for this event!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text('Event Details:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(event.startTime)}'),
            Text('Time: ${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}'),
            Text('Location: ${event.location}'),
            if (!isRegistered) ...[
              const SizedBox(height: 16),
              const Text(
                'Registration information will be available soon. '
                'Please check back later or contact the event organizers.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          if (isRegistered)
            ElevatedButton(
              onPressed: () {
                HapticService.mediumImpact();
                registrationProvider.toggleRegistration(event.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registration cancelled'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Registration'),
            )
          else
            ElevatedButton(
              onPressed: () {
                HapticService.success();
                registrationProvider.toggleRegistration(event.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Registration confirmed!'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: event.color,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Registration'),
            ),
        ],
      ),
    );
  }

  void _showReminderDialog(BuildContext context, Event event, RemindersProvider remindersProvider) {
    final currentReminder = remindersProvider.getReminder(event.id);

    showDialog(
      context: context,
      builder: (context) {
        Duration? selectedReminder = currentReminder;
        
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Set Event Reminder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Get notified before the event starts:'),
                const SizedBox(height: 16),
                RadioListTile<Duration?>(
                  title: const Text('15 minutes before'),
                  value: const Duration(minutes: 15),
                  groupValue: selectedReminder,
                  onChanged: (value) {
                    HapticService.selectionClick();
                    setState(() => selectedReminder = value);
                  },
                  activeColor: event.color,
                ),
                RadioListTile<Duration?>(
                  title: const Text('30 minutes before'),
                  value: const Duration(minutes: 30),
                  groupValue: selectedReminder,
                  onChanged: (value) {
                    HapticService.selectionClick();
                    setState(() => selectedReminder = value);
                  },
                  activeColor: event.color,
                ),
                RadioListTile<Duration?>(
                  title: const Text('1 hour before'),
                  value: const Duration(hours: 1),
                  groupValue: selectedReminder,
                  onChanged: (value) {
                    HapticService.selectionClick();
                    setState(() => selectedReminder = value);
                  },
                  activeColor: event.color,
                ),
                RadioListTile<Duration?>(
                  title: const Text('2 hours before'),
                  value: const Duration(hours: 2),
                  groupValue: selectedReminder,
                  onChanged: (value) {
                    HapticService.selectionClick();
                    setState(() => selectedReminder = value);
                  },
                  activeColor: event.color,
                ),
                RadioListTile<Duration?>(
                  title: const Text('1 day before'),
                  value: const Duration(days: 1),
                  groupValue: selectedReminder,
                  onChanged: (value) {
                    HapticService.selectionClick();
                    setState(() => selectedReminder = value);
                  },
                  activeColor: event.color,
                ),
                RadioListTile<Duration?>(
                  title: const Text('No reminder'),
                  value: null,
                  groupValue: selectedReminder,
                  onChanged: (value) {
                    HapticService.selectionClick();
                    setState(() => selectedReminder = value);
                  },
                  activeColor: event.color,
                ),
              ],
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
                                  HapticService.success();
                                  try {
                                    final success = await remindersProvider.setReminder(event, selectedReminder);
                  if (context.mounted) {
                    Navigator.pop(context);
                                      if (success) {
                                        ErrorHandler.showSuccess(
                                          context,
                                          selectedReminder == null
                            ? 'Reminder cancelled'
                                              : 'Reminder set for ${_formatReminderDuration(selectedReminder!)} before event'
                                        );
                                      } else {
                                        ErrorHandler.showError(
                                          context,
                                          'Failed to set reminder. Please check notification permissions.'
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ErrorHandler.showError(context, e);
                                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: event.color,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatReminderDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  Widget _buildNearbyEvents(BuildContext context, Event currentEvent) {
    final allEvents = context.read<EventsProvider>().events;
    // Find events on the same day or within 2 days
    final nearbyEvents = allEvents.where((e) {
      if (e.id == currentEvent.id) return false;
      final daysDiff = (e.startTime.difference(currentEvent.startTime).inDays).abs();
      return daysDiff <= 2 && e.location == currentEvent.location;
    }).take(3).toList();

    if (nearbyEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.near_me, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Text(
              'Nearby Events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: nearbyEvents.length,
            itemBuilder: (context, index) {
              final nearbyEvent = nearbyEvents[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: nearbyEvent),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: nearbyEvent.color,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: nearbyEvent.imageUrl != null && nearbyEvent.imageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: nearbyEvent.imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Icon(Icons.event, size: 48, color: Colors.white.withOpacity(0.7)),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nearbyEvent.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM d, h:mm a').format(nearbyEvent.startTime),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarEvents(BuildContext context, Event currentEvent) {
    final allEvents = context.read<EventsProvider>().events;
    // Find events in the same category
    final similarEvents = allEvents.where((e) {
      return e.id != currentEvent.id && e.category == currentEvent.category;
    }).take(3).toList();

    if (similarEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Text(
              'Similar Events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...similarEvents.map((similarEvent) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EventCard(
              event: similarEvent,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: similarEvent),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
