import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationProvider extends ChangeNotifier {
  Set<String> _registeredEventIds = {};

  Set<String> get registeredEventIds => _registeredEventIds;

  RegistrationProvider() {
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    final prefs = await SharedPreferences.getInstance();
    _registeredEventIds = (prefs.getStringList('registeredEvents') ?? []).toSet();
    notifyListeners();
  }

  Future<void> _saveRegistrations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('registeredEvents', _registeredEventIds.toList());
  }

  Future<void> toggleRegistration(String eventId) async {
    if (_registeredEventIds.contains(eventId)) {
      _registeredEventIds.remove(eventId);
    } else {
      _registeredEventIds.add(eventId);
    }
    await _saveRegistrations();
    notifyListeners();
  }

  bool isRegistered(String eventId) {
    return _registeredEventIds.contains(eventId);
  }

  Future<void> clearAllRegistrations() async {
    try {
      // Clear registrations from memory
      _registeredEventIds.clear();
      
      // Clear from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('registeredEvents');
      
      notifyListeners();
    } catch (e) {
      print('Error clearing all registrations: $e');
      throw Exception('Failed to clear registrations');
    }
  }
}

