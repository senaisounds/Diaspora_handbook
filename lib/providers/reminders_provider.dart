import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../services/notification_service.dart';

class RemindersProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  Map<String, Duration?> _eventReminders = {}; // eventId -> reminder duration

  Map<String, Duration?> get eventReminders => _eventReminders;

  RemindersProvider() {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
    final prefs = await SharedPreferences.getInstance();
    final reminderData = prefs.getString('eventReminders');
    
    if (reminderData != null) {
      // Parse stored reminders (simplified - in production, use JSON)
      _eventReminders = {};
      final entries = reminderData.split('|');
      for (var entry in entries) {
        if (entry.isEmpty) continue;
        final parts = entry.split(':');
        if (parts.length == 2) {
          final eventId = parts[0];
          final minutes = int.tryParse(parts[1]);
            if (minutes != null && minutes > 0) {
            _eventReminders[eventId] = Duration(minutes: minutes);
          }
        }
      }
    }
    notifyListeners();
    } catch (e) {
      // If loading fails, start with empty reminders
      _eventReminders = {};
      notifyListeners();
      print('Error loading reminders: $e');
    }
  }

  Future<bool> _saveReminders() async {
    try {
    final prefs = await SharedPreferences.getInstance();
    final reminderData = _eventReminders.entries
          .where((e) => e.value != null && e.value!.inMinutes > 0)
          .map((e) => '${e.key}:${e.value!.inMinutes}')
        .join('|');
      return await prefs.setString('eventReminders', reminderData);
    } catch (e) {
      print('Error saving reminders: $e');
      return false;
    }
  }

  Future<bool> setReminder(Event event, Duration? reminderBefore) async {
    try {
      // Cancel existing reminder (ignore errors here)
      try {
    await _notificationService.cancelEventReminder(event.id);
      } catch (e) {
        print('Error canceling reminder: $e');
      }

    if (reminderBefore != null) {
      // Schedule new reminder
        try {
      await _notificationService.scheduleEventReminder(event, reminderBefore);
      _eventReminders[event.id] = reminderBefore;
        } catch (e) {
          print('Error scheduling reminder: $e');
          // If scheduling fails, don't add to reminders
          return false;
        }
    } else {
      _eventReminders.remove(event.id);
    }

      final saved = await _saveReminders();
      if (saved) {
    notifyListeners();
        return true;
      } else {
        // Revert on save failure
        if (reminderBefore != null) {
          _eventReminders.remove(event.id);
        } else {
          _eventReminders[event.id] = reminderBefore;
        }
        return false;
      }
    } catch (e) {
      print('Error setting reminder: $e');
      return false;
    }
  }

  Duration? getReminder(String eventId) {
    return _eventReminders[eventId];
  }

  bool hasReminder(String eventId) {
    return _eventReminders.containsKey(eventId) && _eventReminders[eventId] != null;
  }

  Future<void> clearAllReminders() async {
    try {
      // Cancel all scheduled notifications
      await _notificationService.cancelAllReminders();
      
      // Clear reminders from memory
      _eventReminders.clear();
      
      // Clear from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('eventReminders');
      
      notifyListeners();
    } catch (e) {
      print('Error clearing all reminders: $e');
      throw Exception('Failed to clear reminders');
    }
  }
}

