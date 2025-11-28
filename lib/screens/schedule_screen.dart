import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import '../providers/events_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/registration_provider.dart';
import '../services/haptic_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedView = 0; // 0: All, 1: My Schedule

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Event> _getEvents(BuildContext context) {
    final allEvents = context.watch<EventsProvider>().events;
    
    if (_selectedView == 1) {
      final favoritesProvider = context.watch<FavoritesProvider>();
      final registrationProvider = context.watch<RegistrationProvider>();
      
      return allEvents.where((event) {
        return favoritesProvider.isFavorite(event.id) || 
               registrationProvider.isRegistered(event.id);
      }).toList();
    }
    
    return allEvents;
  }

  List<Event> _getEventsForDay(DateTime day, List<Event> events) {
    return events.where((event) => event.isSameDay(day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEvents(context);
    final selectedEvents = _getEventsForDay(_selectedDay!, events);
    // Sort events by start time
    selectedEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  label: Text('All Events'),
                  icon: Icon(Icons.calendar_view_day),
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text('My Schedule'),
                  icon: Icon(Icons.person),
                ),
              ],
              selected: {_selectedView},
              onSelectionChanged: (Set<int> newSelection) {
                HapticService.selectionClick();
                setState(() {
                  _selectedView = newSelection.first;
                });
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFFFFD700);
                    }
                    return Colors.transparent;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.black;
                    }
                    return Colors.white;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) => _getEventsForDay(day, events),
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: Color(0xFF00E5FF),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white70),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonTextStyle: TextStyle(color: Colors.white),
              formatButtonDecoration: BoxDecoration(
                border: Border.fromBorderSide(BorderSide(color: Colors.white)),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 16.0),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: selectedEvents.isEmpty
                  ? RefreshIndicator(
                      onRefresh: () async {
                        HapticService.lightImpact();
                        await context.read<EventsProvider>().refreshEvents();
                        if (mounted) {
                          HapticService.success();
                        }
                      },
                      color: const Color(0xFFFFD700),
                      backgroundColor: Colors.black,
                      strokeWidth: 3.0,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedView == 1 ? Icons.event_available : Icons.event_busy, 
                                  size: 64, 
                                  color: Colors.grey[800]
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedView == 1 
                                    ? 'No events in your schedule for this day.'
                                    : 'No events for this day.',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                if (_selectedView == 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Add events by tapping the heart icon\nor registering for them.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                ),
                                const SizedBox(height: 8),
                                if (_selectedView == 0)
                                Text(
                                  'Pull down to refresh',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        HapticService.lightImpact();
                        await context.read<EventsProvider>().refreshEvents();
                        if (mounted) {
                          HapticService.success();
                        }
                      },
                      color: const Color(0xFFFFD700),
                      backgroundColor: Colors.black,
                      strokeWidth: 3.0,
                      displacement: 40,
                      child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = selectedEvents[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 50,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm').format(event.startTime),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('HH:mm').format(event.endTime),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Timeline Line
                              Column(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: event.color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 140, // Height of the card + padding roughly
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
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
                        );
                      },
                    ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

