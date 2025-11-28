import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/event.dart';
import '../providers/events_provider.dart';
import '../services/haptic_service.dart';
import 'package:intl/intl.dart';

class RandomEventWidget extends StatefulWidget {
  final Function(Event) onEventSelected;

  const RandomEventWidget({super.key, required this.onEventSelected});

  @override
  State<RandomEventWidget> createState() => _RandomEventWidgetState();
}

class _RandomEventWidgetState extends State<RandomEventWidget>
    with SingleTickerProviderStateMixin {
  bool _isSpinning = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _spinForRandomEvent() {
    if (_isSpinning) return;

    // Haptic feedback for starting the spin
    HapticService.mediumImpact();

    setState(() {
      _isSpinning = true;
    });

    _animationController.forward(from: 0).then((_) {
      final events = context.read<EventsProvider>().events;
      if (events.isEmpty) {
        setState(() {
          _isSpinning = false;
        });
        _animationController.reset();
        return;
      }
      final random = Random();
      final randomEvent = events[random.nextInt(events.length)];
      
      setState(() {
        _isSpinning = false;
      });

      _animationController.reset();

      // Success haptic feedback when event is found
      HapticService.success();

      // Show the event in a dialog
      _showRandomEventDialog(randomEvent);
    });
  }

  void _showRandomEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.stars, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            const Text('🎲 Surprise Event!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: event.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.event,
                  size: 64,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              event.title.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(event.startTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticService.mediumImpact();
              Navigator.pop(context);
              widget.onEventSelected(event);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          );
        },
        child: ElevatedButton.icon(
          onPressed: _isSpinning ? null : _spinForRandomEvent,
          icon: Icon(_isSpinning ? Icons.refresh : Icons.casino),
          label: Text(_isSpinning ? 'Spinning...' : '🎲 Surprise Me!'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: _isSpinning ? 0 : 4,
          ),
        ),
      ),
    );
  }
}

