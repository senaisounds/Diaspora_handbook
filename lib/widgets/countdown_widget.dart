import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/favorites_provider.dart';
import '../services/haptic_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  Event? _nextEvent;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final favoriteEvents = favoritesProvider.favoriteEvents;
    final now = DateTime.now();

    // Find the next upcoming favorite event
    final upcomingFavorites = favoriteEvents.where((e) => e.startTime.isAfter(now)).toList();
    
    if (upcomingFavorites.isEmpty) {
      setState(() {
        _nextEvent = null;
        _timeRemaining = Duration.zero;
      });
      return;
    }

    upcomingFavorites.sort((a, b) => a.startTime.compareTo(b.startTime));
    final nextEvent = upcomingFavorites.first;

    setState(() {
      _nextEvent = nextEvent;
      final difference = nextEvent.startTime.difference(now);
      _timeRemaining = difference.isNegative ? Duration.zero : difference;
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '${days}d ${hours}h';
      }
      return '${days}d';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        if (_nextEvent == null) {
          return const SizedBox.shrink();
        }

        final isLessThanHour = _timeRemaining.inHours < 1;
        final isLessThanDay = _timeRemaining.inDays < 1;

        return InkWell(
          onTap: () {
            HapticService.lightImpact();
            // Could navigate to event detail screen here
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD700).withOpacity(0.2),
                const Color(0xFFFFD700).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: isLessThanHour ? Colors.red : const Color(0xFFFFD700),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Next Event Starts In',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nextEvent!.title.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, h:mm a').format(_nextEvent!.startTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLessThanHour
                          ? Colors.red.withOpacity(0.2)
                          : isLessThanDay
                              ? Colors.orange.withOpacity(0.2)
                              : const Color(0xFFFFD700).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isLessThanHour
                            ? Colors.red
                            : isLessThanDay
                                ? Colors.orange
                                : const Color(0xFFFFD700),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _formatDuration(_timeRemaining),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isLessThanHour
                                ? Colors.red
                                : isLessThanDay
                                    ? Colors.orange
                                    : const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
            ),
        );
      },
    );
  }
}

