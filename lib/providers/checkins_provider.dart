import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckInsProvider extends ChangeNotifier {
  final Map<String, DateTime> _checkIns = {};
  int _totalCheckIns = 0;

  Map<String, DateTime> get checkIns => Map.unmodifiable(_checkIns);
  int get totalCheckIns => _totalCheckIns;
  List<String> get checkedInEventIds => List.unmodifiable(_checkIns.keys);

  CheckInsProvider() {
    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    final checkInIds = prefs.getStringList('checkInIds') ?? [];
    
    for (final id in checkInIds) {
      final timestamp = prefs.getInt('checkIn_$id') ?? DateTime.now().millisecondsSinceEpoch;
      _checkIns[id] = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    _totalCheckIns = _checkIns.length;
    notifyListeners();
  }

  bool isCheckedIn(String eventId) {
    return _checkIns.containsKey(eventId);
  }

  DateTime? getCheckInTime(String eventId) {
    return _checkIns[eventId];
  }

  Future<void> checkIn(String eventId) async {
    if (_checkIns.containsKey(eventId)) return;

    _checkIns[eventId] = DateTime.now();
    _totalCheckIns = _checkIns.length;

    final prefs = await SharedPreferences.getInstance();
    final checkInIds = prefs.getStringList('checkInIds') ?? [];
    checkInIds.add(eventId);
    await prefs.setStringList('checkInIds', checkInIds);
    await prefs.setInt('checkIn_$eventId', _checkIns[eventId]!.millisecondsSinceEpoch);

    notifyListeners();
  }

  Future<void> uncheckIn(String eventId) async {
    if (!_checkIns.containsKey(eventId)) return;

    _checkIns.remove(eventId);
    _totalCheckIns = _checkIns.length;

    final prefs = await SharedPreferences.getInstance();
    final checkInIds = prefs.getStringList('checkInIds') ?? [];
    checkInIds.remove(eventId);
    await prefs.setStringList('checkInIds', checkInIds);
    await prefs.remove('checkIn_$eventId');

    notifyListeners();
  }
}

