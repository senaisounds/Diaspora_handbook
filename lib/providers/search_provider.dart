import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends ChangeNotifier {
  List<String> _searchHistory = [];
  List<String> _recentSearches = [];
  DateTime? _dateRangeStart;
  DateTime? _dateRangeEnd;

  List<String> get searchHistory => _searchHistory;
  List<String> get recentSearches => _recentSearches;
  DateTime? get dateRangeStart => _dateRangeStart;
  DateTime? get dateRangeEnd => _dateRangeEnd;

  SearchProvider() {
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('searchHistory') ?? [];
    _recentSearches = _searchHistory.take(5).toList();
    notifyListeners();
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  void addToHistory(String query) {
    if (query.trim().isEmpty) return;
    
    // Remove if already exists
    _searchHistory.remove(query.trim());
    // Add to beginning
    _searchHistory.insert(0, query.trim());
    // Keep only last 20 searches
    if (_searchHistory.length > 20) {
      _searchHistory = _searchHistory.take(20).toList();
    }
    _recentSearches = _searchHistory.take(5).toList();
    _saveSearchHistory();
    notifyListeners();
  }

  void clearHistory() {
    _searchHistory.clear();
    _recentSearches.clear();
    _saveSearchHistory();
    notifyListeners();
  }

  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    _recentSearches = _searchHistory.take(5).toList();
    _saveSearchHistory();
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _dateRangeStart = start;
    _dateRangeEnd = end;
    notifyListeners();
  }

  void clearDateRange() {
    _dateRangeStart = null;
    _dateRangeEnd = null;
    notifyListeners();
  }
}

