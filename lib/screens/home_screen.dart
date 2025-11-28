import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/event_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/random_event_widget.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/logo_widget.dart';
import '../services/haptic_service.dart';
import '../services/ad_service.dart';
import 'event_detail_screen.dart';
import 'settings_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import '../models/event.dart';
import '../providers/search_provider.dart';
import '../providers/events_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedWeekIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  // Helper function to get week number from a date
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    final weekNumber = ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).floor() + 1;
    return weekNumber;
  }

  // Group events by week
  Map<int, List<Event>> _groupEventsByWeek(List<Event> events) {
    final Map<int, List<Event>> weekGroups = {};
    for (var event in events) {
      final weekNumber = _getWeekNumber(event.startTime);
      weekGroups.putIfAbsent(weekNumber, () => []).add(event);
    }
    // Sort events within each week by start time
    for (var weekEvents in weekGroups.values) {
      weekEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return weekGroups;
  }

  // Filter events based on search query, category, and date range
  List<Event> _filterEvents(List<Event> events, SearchProvider? searchProvider) {
    return events.where((event) {
      final matchesSearch = _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.location.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == null || event.category == _selectedCategory;
      
      final matchesDateRange = searchProvider?.dateRangeStart == null || 
          (event.startTime.isAfter(searchProvider!.dateRangeStart!.subtract(const Duration(days: 1))) &&
           (searchProvider.dateRangeEnd == null || 
            event.startTime.isBefore(searchProvider.dateRangeEnd!.add(const Duration(days: 1)))));
      
      return matchesSearch && matchesCategory && matchesDateRange;
    }).toList();
  }

  // Get unique categories from events
  List<String> _getCategories(List<Event> events) {
    final categories = events.map((e) => e.category).toSet().toList();
    categories.sort();
    return categories;
  }

  void _showSearchSuggestions(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    if (searchProvider.recentSearches.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<SearchProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Searches',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearHistory();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...provider.recentSearches.map((search) {
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(search),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          provider.removeFromHistory(search);
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _searchController.text = search;
                          _searchQuery = search;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDateRangePicker(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: searchProvider.dateRangeStart != null && searchProvider.dateRangeEnd != null
          ? DateTimeRange(start: searchProvider.dateRangeStart!, end: searchProvider.dateRangeEnd!)
          : null,
    ).then((dateRange) {
      if (dateRange != null) {
        searchProvider.setDateRange(dateRange.start, dateRange.end);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchProvider, EventsProvider>(
      builder: (context, searchProvider, eventsProvider, child) {
        final allEvents = eventsProvider.events;
        final filteredEvents = _filterEvents(allEvents, searchProvider);
        final weekGroups = _groupEventsByWeek(filteredEvents);
        final sortedWeeks = weekGroups.keys.toList()..sort();
    
    // Set initial week to the first week with events, or current week if available
    if (_selectedWeekIndex >= sortedWeeks.length) {
      _selectedWeekIndex = 0;
    }
    
        final currentWeekNumber = sortedWeeks.isNotEmpty 
            ? sortedWeeks[_selectedWeekIndex] 
            : _getWeekNumber(DateTime.now());
        final currentWeekEvents = weekGroups[currentWeekNumber] ?? [];
        final categories = _getCategories(allEvents);

        return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Offline/Error Banner
            if (eventsProvider.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: eventsProvider.isOffline 
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                child: Row(
                  children: [
                    Icon(
                      eventsProvider.isOffline ? Icons.cloud_off : Icons.warning,
                      color: eventsProvider.isOffline ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        eventsProvider.error!,
                        style: TextStyle(
                          color: eventsProvider.isOffline ? Colors.blue : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (eventsProvider.isOffline)
                      TextButton.icon(
                        onPressed: () {
                          HapticService.lightImpact();
                          eventsProvider.loadEvents(forceRefresh: true);
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
              ),
            // Custom Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Diaspora Handbook Logo
                      const LogoWidget(
                        width: 100,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HOMECOMING',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 24,
                                height: 0.9,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'SEASON - ',
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 24,
                                      height: 0.9,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    'GUIDE',
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 24,
                                      height: 0.9,
                                      color: const Color(0xFFFFD700),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.account_circle),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: () {
                          HapticService.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        tooltip: 'Profile',
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: () {
                          HapticService.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Fun Features Section
                  const CountdownWidget(),
                  RandomEventWidget(
                    onEventSelected: (event) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.date_range, color: Color(0xFFFFD700)),
                            onPressed: () {
                              HapticService.selectionClick();
                              _showDateRangePicker(context);
                            },
                            tooltip: 'Filter by date range',
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                HapticService.lightImpact();
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            ),
                        ],
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      if (value.isNotEmpty) {
                        Provider.of<SearchProvider>(context, listen: false).addToHistory(value);
                      }
                    },
                    onTap: () {
                      _showSearchSuggestions(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Date Range Filter Button
                  Consumer<SearchProvider>(
                    builder: (context, searchProvider, child) {
                      if (searchProvider.dateRangeStart != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Chip(
                                label: Text(
                                  '${DateFormat('MMM d').format(searchProvider.dateRangeStart!)} - ${searchProvider.dateRangeEnd != null ? DateFormat('MMM d').format(searchProvider.dateRangeEnd!) : 'Now'}',
                                ),
                                onDeleted: () {
                                  HapticService.selectionClick();
                                  searchProvider.clearDateRange();
                                },
                                deleteIcon: const Icon(Icons.close, size: 18),
                                backgroundColor: const Color(0xFFFFD700).withOpacity(0.2),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Category Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1, // +1 for "All" option
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = _selectedCategory == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: const Text('All'),
                              selected: isSelected,
                              onSelected: (selected) {
                              HapticService.selectionClick();
                                setState(() {
                                  _selectedCategory = null;
                                });
                              },
                              selectedColor: const Color(0xFFFFD700),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        }
                        final category = categories[index - 1];
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              HapticService.selectionClick();
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                            },
                            selectedColor: const Color(0xFFFFD700),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Week Selector (if multiple weeks)
            if (sortedWeeks.length > 1)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedWeeks.length,
                  itemBuilder: (context, index) {
                    final weekNum = sortedWeeks[index];
                    final isSelected = index == _selectedWeekIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text('WEEK $weekNum'),
                        selected: isSelected,
                        onSelected: (selected) {
                          HapticService.selectionClick();
                          setState(() {
                            _selectedWeekIndex = index;
                          });
                        },
                        selectedColor: const Color(0xFFFFD700),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            // Content Area with "WEEK X" sidebar
            Expanded(
              child: Row(
                children: [
                  // Main Event List
                  Expanded(
                    child: eventsProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : currentWeekEvents.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                                  HapticService.lightImpact();
                                  await eventsProvider.refreshEvents();
                              if (mounted) {
                                setState(() {});
                                    HapticService.success();
                              }
                            },
                            color: const Color(0xFFFFD700),
                            backgroundColor: Colors.black,
                            strokeWidth: 3.0,
                            displacement: 40,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: EmptyStateWidget(
                                      title: eventsProvider.error != null 
                                          ? 'Connection Error' 
                                          : 'No events found',
                                      message: eventsProvider.error != null
                                          ? 'Unable to load events. Please check your connection and ensure the backend server is running.'
                                          : 'No events for Week $currentWeekNumber. Try selecting a different week or adjusting your filters.',
                                      icon: eventsProvider.error != null 
                                          ? Icons.cloud_off 
                                          : Icons.event_busy,
                                ),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                                  HapticService.lightImpact();
                                  await eventsProvider.refreshEvents();
                              if (mounted) {
                                setState(() {});
                                    HapticService.success();
                              }
                            },
                            color: const Color(0xFFFFD700),
                            backgroundColor: Colors.black,
                            strokeWidth: 3.0,
                            displacement: 40,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: currentWeekEvents.length + 1, // +1 for ad banner
                              itemBuilder: (context, index) {
                                // Show ad banner as last item
                                if (index == currentWeekEvents.length) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                    child: AdBannerWidget(),
                                  );
                                }
                                
                                final event = currentWeekEvents[index];
                                return EventCard(
                                  event: event,
                                  onTap: () async {
                                    HapticService.lightImpact();
                                    // Show interstitial ad (with frequency capping)
                                    await AdService().showInterstitialAd();
                                    if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetailScreen(event: event),
                                      ),
                                    );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                  
                  // "WEEK X" Sidebar (Rotated Text)
                  Container(
                    width: 60,
                    padding: const EdgeInsets.only(bottom: 32),
                    alignment: Alignment.bottomCenter,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'WEEK $currentWeekNumber',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: const Color(0xFFFFD700).withOpacity(0.2), // Faded background effect
                          fontSize: 80,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "home_fab", // Unique tag to avoid conflicts
        onPressed: () {
          HapticService.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MapScreen(),
            ),
          );
        },
        icon: const Icon(Icons.map),
        label: const Text('Map View'),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
      ),
        );
      },
    );
  }
}
