import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class EventsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;

  EventsProvider() {
    // Initialize with cached data immediately, then try to load fresh data
    _initializeWithCache();
  }
  
  Future<void> _initializeWithCache() async {
    try {
      // Load cached events immediately for offline support
      _events = await _cacheService.loadCachedEvents();
      notifyListeners();
    } catch (e) {
      print('Error loading cached events: $e');
    }
    
    // Then try to load fresh data from API
    loadEvents();
  }

  Future<void> loadEvents({
    String? category,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    _error = null;
    _isOffline = false;
    notifyListeners();

    try {
      // Try to load from API first
      final apiEvents = await _apiService.getEvents(
        category: category,
        location: location,
        startDate: startDate,
        endDate: endDate,
      );
      
      // Success - update cache and events
      _events = apiEvents;
      await _cacheService.cacheEvents(apiEvents);
      _error = null;
      _isOffline = false;
    } catch (e) {
      // API failed - try to load from cache
      print('API error, loading from cache: $e');
      _isOffline = true;
      
      try {
        final cachedEvents = await _cacheService.loadCachedEvents();
        
        if (cachedEvents.isNotEmpty) {
          // Apply filters to cached events
          var filteredEvents = cachedEvents;
          
          if (category != null) {
            filteredEvents = filteredEvents.where((e) => e.category == category).toList();
          }
          
          if (location != null) {
            filteredEvents = filteredEvents.where((e) => e.location.toLowerCase().contains(location.toLowerCase())).toList();
          }
          
          if (startDate != null) {
            filteredEvents = filteredEvents.where((e) => e.startTime.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
          }
          
          if (endDate != null) {
            filteredEvents = filteredEvents.where((e) => e.startTime.isBefore(endDate.add(const Duration(days: 1)))).toList();
          }
          
          _events = filteredEvents;
          _error = 'Showing cached data. ${_getUserFriendlyError(e)}';
        } else {
          // No cache available
          _events = [];
          _error = _getUserFriendlyError(e);
        }
      } catch (cacheError) {
        // Even cache failed - use empty list
        print('Cache error: $cacheError');
        _events = [];
        _error = _getUserFriendlyError(e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load events from cache only (for offline-first approach)
  Future<void> loadCachedEventsOnly() async {
    _isLoading = true;
    _error = null;
    _isOffline = true;
    notifyListeners();
    
    try {
      _events = await _cacheService.loadCachedEvents();
      if (_events.isEmpty) {
        _error = 'No cached events available. Please connect to the internet to load events.';
      } else {
        _error = 'Showing offline data';
      }
    } catch (e) {
      _events = [];
      _error = 'Unable to load cached events';
      print('Error loading cached events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEvents() async {
    await loadEvents();
  }

  Event? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Event> getEventsByCategory(String category) {
    return _events.where((event) => event.category == category).toList();
  }

  List<Event> getEventsByDate(DateTime date) {
    return _events.where((event) => event.isSameDay(date)).toList();
  }

  Future<Event> createEvent(Event event) async {
    try {
      final newEvent = await _apiService.createEvent(event);
      _events.add(newEvent);
      _events.sort((a, b) => a.startTime.compareTo(b.startTime));
      _error = null;
      notifyListeners();
      return newEvent;
    } catch (e) {
      _error = _getUserFriendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<Event> updateEvent(Event event) async {
    try {
      final updatedEvent = await _apiService.updateEvent(event);
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = updatedEvent;
        _events.sort((a, b) => a.startTime.compareTo(b.startTime));
        _error = null;
        notifyListeners();
      }
      return updatedEvent;
    } catch (e) {
      _error = _getUserFriendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _apiService.deleteEvent(id);
      _events.removeWhere((event) => event.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = _getUserFriendlyError(e);
      notifyListeners();
      rethrow;
    }
  }
  
  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('connection refused') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network error') ||
        errorString.contains('no internet connection')) {
      return 'Unable to connect to server. Please check your connection.';
    }
    
    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'The requested resource was not found.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (errorString.contains('409') || errorString.contains('conflict')) {
      return 'This resource already exists.';
    }
    
    return 'An error occurred: ${error.toString()}';
  }

  // Test helper methods
  @visibleForTesting
  void setEvents(List<Event> events) {
    _events = events;
    notifyListeners();
  }

  @visibleForTesting
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @visibleForTesting
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

