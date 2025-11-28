import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/favorites_provider.dart';
import '../providers/reminders_provider.dart';
import '../providers/registration_provider.dart';
import '../widgets/event_card.dart';
import '../models/event.dart';
import '../services/haptic_service.dart';
import '../services/export_service.dart';
import 'event_detail_screen.dart';
import 'achievements_screen.dart';
import 'resources_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  DateTime? _selectedDay;

  // Group events by day
  Map<DateTime, List<Event>> _groupEventsByDay(List<Event> events) {
    final Map<DateTime, List<Event>> dayGroups = {};
    for (var event in events) {
      final day = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      dayGroups.putIfAbsent(day, () => []).add(event);
    }
    // Sort events within each day by start time
    for (var dayEvents in dayGroups.values) {
      dayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return dayGroups;
  }

  // Check if events overlap (conflict detection)
  bool _eventsOverlap(Event event1, Event event2) {
    return event1.startTime.isBefore(event2.endTime) && 
           event1.endTime.isAfter(event2.startTime);
  }

  // Get conflicts for a specific event
  List<Event> _getConflicts(Event event, List<Event> allEvents) {
    return allEvents.where((e) => 
      e.id != event.id && 
      _eventsOverlap(event, e)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('My Plan'),
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFD700),
            labelColor: Color(0xFFFFD700),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Saved Events'),
              Tab(text: 'Handbook Guide'),
            ],
          ),
        actions: [
          // Export Button
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              final hasFavorites = favoritesProvider.favoriteEvents.isNotEmpty;
              return IconButton(
                icon: const Icon(Icons.share),
                onPressed: hasFavorites
                    ? () {
                        HapticService.lightImpact();
                        _showExportDialog(context, favoritesProvider.favoriteEvents);
                      }
                    : null,
                tooltip: 'Export Schedule',
              );
            },
          ),
          // Achievements Button
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              HapticService.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsScreen(),
                ),
              );
            },
            tooltip: 'Achievements',
          ),
          // Storage Management Button
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () {
              HapticService.lightImpact();
              _showStorageManagementDialog(context);
            },
            tooltip: 'Free Up Space',
          ),
        ],
      ),
        body: TabBarView(
          children: [
            _buildFavoritesList(context),
            const ResourcesScreen(showAppBar: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    return Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final favoriteEvents = favoritesProvider.favoriteEvents;

          if (favoriteEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'No events saved yet.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any event to add it to your plan.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final dayGroups = _groupEventsByDay(favoriteEvents);
          final sortedDays = dayGroups.keys.toList()..sort();
          
          // Set selected day to first day with events, or today if available
          if (_selectedDay == null || !dayGroups.containsKey(_selectedDay)) {
            _selectedDay = sortedDays.isNotEmpty ? sortedDays.first : DateTime.now();
          }

          final selectedDayEvents = dayGroups[_selectedDay!] ?? [];
          final dateFormat = DateFormat('EEEE, MMMM d');
          final shortDateFormat = DateFormat('MMM d');

          return Column(
            children: [
              // Date Selector
              if (sortedDays.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: SizedBox(
                    height: 56,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: sortedDays.length,
                      itemBuilder: (context, index) {
                        final day = sortedDays[index];
                        final isSelected = isSameDay(_selectedDay, day);
                        final isToday = isSameDay(day, DateTime.now());
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              HapticService.selectionClick();
                              setState(() {
                                _selectedDay = day;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              constraints: const BoxConstraints(minHeight: 40),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFFFFD700) 
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: isToday && !isSelected
                                    ? Border.all(color: const Color(0xFFFFD700), width: 2)
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('EEE').format(day).toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    shortDateFormat.format(day),
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      height: 1.1,
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
                ),
              
              // Selected Day Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      dateFormat.format(_selectedDay!),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (selectedDayEvents.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${selectedDayEvents.length} ${selectedDayEvents.length == 1 ? 'event' : 'events'}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Time Slot View
              Expanded(
                child: selectedDayEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 64, color: Colors.grey[700]),
                            const SizedBox(height: 16),
                            Text(
                              'No events for this day.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: selectedDayEvents.length,
                        itemBuilder: (context, index) {
                          final event = selectedDayEvents[index];
                          final conflicts = _getConflicts(event, selectedDayEvents);
                          final hasConflict = conflicts.isNotEmpty;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Time Column
                                SizedBox(
                                  width: 70,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('h:mm a').format(event.startTime),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('h:mm a').format(event.endTime),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (hasConflict) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'CONFLICT',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Timeline Line
                                Column(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: hasConflict ? Colors.red : event.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white, 
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: index < selectedDayEvents.length - 1 ? 180 : 0,
                                      color: hasConflict 
                                          ? Colors.red.withOpacity(0.5)
                                          : Colors.grey.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Event Card
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (hasConflict)
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.red.withOpacity(0.5)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.warning_amber_rounded, 
                                                color: Colors.red, size: 16),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Overlaps with ${conflicts.length} other event${conflicts.length > 1 ? 's' : ''}',
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EventDetailScreen(event: event),
                                            ),
                                          );
                                        },
                                        child: EventCard(
                                          event: event,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EventDetailScreen(event: event),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
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
    );
  }

  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showStorageManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.storage, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text('Free Up Space'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clear app data to free up storage space:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildStorageOption(
                  context,
                  icon: Icons.notifications_off,
                  title: 'Clear Reminders',
                  description: 'Remove all scheduled notifications',
                  onTap: () => _clearReminders(context),
                ),
                const Divider(),
                _buildStorageOption(
                  context,
                  icon: Icons.heart_broken,
                  title: 'Clear Favorites',
                  description: 'Remove all saved events',
                  onTap: () => _clearFavorites(context),
                ),
                const Divider(),
                _buildStorageOption(
                  context,
                  icon: Icons.event_busy,
                  title: 'Clear Registrations',
                  description: 'Remove all event registrations',
                  onTap: () => _clearRegistrations(context),
                ),
                const Divider(),
                _buildStorageOption(
                  context,
                  icon: Icons.delete_sweep,
                  title: 'Clear All Data',
                  description: 'Reset all app data',
                  onTap: () => _clearAllData(context),
                  isDestructive: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticService.lightImpact();
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStorageOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFFFFD700),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDestructive ? Colors.red : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearReminders(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Clear Reminders?',
      message: 'This will cancel all scheduled notifications.',
    );

    if (confirmed && context.mounted) {
      try {
        final remindersProvider = context.read<RemindersProvider>();
        await remindersProvider.clearAllReminders();
        
        if (context.mounted) {
          Navigator.of(context).pop();
          _showSuccessSnackBar(context, 'All reminders cleared successfully');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to clear reminders');
        }
      }
    }
  }

  Future<void> _clearFavorites(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Clear Favorites?',
      message: 'This will remove all events from your plan.',
    );

    if (confirmed && context.mounted) {
      try {
        final favoritesProvider = context.read<FavoritesProvider>();
        await favoritesProvider.clearAllFavorites();
        
        if (context.mounted) {
          Navigator.of(context).pop();
          _showSuccessSnackBar(context, 'All favorites cleared successfully');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to clear favorites');
        }
      }
    }
  }

  Future<void> _clearRegistrations(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Clear Registrations?',
      message: 'This will remove all your event registrations.',
    );

    if (confirmed && context.mounted) {
      try {
        final registrationProvider = context.read<RegistrationProvider>();
        await registrationProvider.clearAllRegistrations();
        
        if (context.mounted) {
          Navigator.of(context).pop();
          _showSuccessSnackBar(context, 'All registrations cleared successfully');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to clear registrations');
        }
      }
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Clear All Data?',
      message: 'This will reset the app and remove all your data including favorites, reminders, and registrations. This action cannot be undone.',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      try {
        final remindersProvider = context.read<RemindersProvider>();
        final favoritesProvider = context.read<FavoritesProvider>();
        final registrationProvider = context.read<RegistrationProvider>();
        
        await Future.wait([
          remindersProvider.clearAllReminders(),
          favoritesProvider.clearAllFavorites(),
          registrationProvider.clearAllRegistrations(),
        ]);
        
        if (context.mounted) {
          Navigator.of(context).pop();
          _showSuccessSnackBar(context, 'All app data cleared successfully');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Failed to clear all data');
        }
      }
    }
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                HapticService.lightImpact();
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                HapticService.mediumImpact();
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Clear',
                style: TextStyle(
                  color: isDestructive ? Colors.red : const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showExportDialog(BuildContext context, List<Event> events) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.share, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text('Export Schedule'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFFFD700)),
                title: const Text('Export as PDF'),
                subtitle: const Text('Generate a PDF document of your schedule'),
                onTap: () async {
                  HapticService.mediumImpact();
                  Navigator.pop(context);
                  _showLoadingDialog(context, 'Generating PDF...');
                  
                  final exportService = ExportService();
                  final success = await exportService.exportToPDF(events);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    if (success) {
                      _showSuccessSnackBar(context, 'PDF exported successfully!');
                    } else {
                      _showErrorSnackBar(context, 'Failed to export PDF');
                    }
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFFFFD700)),
                title: const Text('Add All to Calendar'),
                subtitle: const Text('Add all events to your device calendar'),
                onTap: () async {
                  HapticService.mediumImpact();
                  Navigator.pop(context);
                  _showLoadingDialog(context, 'Adding to calendar...');
                  
                  final exportService = ExportService();
                  final success = await exportService.exportAllToCalendar(events);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    if (success) {
                      _showSuccessSnackBar(context, 'All events added to calendar!');
                    } else {
                      _showErrorSnackBar(context, 'Some events could not be added');
                    }
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.text_snippet, color: Color(0xFFFFD700)),
                title: const Text('Share as Text'),
                subtitle: const Text('Share your schedule as plain text'),
                onTap: () async {
                  HapticService.lightImpact();
                  Navigator.pop(context);
                  
                  final exportService = ExportService();
                  await exportService.shareTextSummary(events);
                },
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
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }
}
