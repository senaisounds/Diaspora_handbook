import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import 'events_provider.dart';

class FavoritesProvider extends ChangeNotifier {
  final EventsProvider _eventsProvider;
  List<String> _favoriteIds = [];
  List<Event> _favoriteEvents = [];

  List<Event> get favoriteEvents => _favoriteEvents;

  FavoritesProvider(this._eventsProvider) {
    _loadFavorites();
    // Listen to events provider changes to update favorites
    _eventsProvider.addListener(_updateFavoriteEvents);
  }

  @override
  void dispose() {
    _eventsProvider.removeListener(_updateFavoriteEvents);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList('favoriteIds') ?? [];
    _updateFavoriteEvents();
    notifyListeners();
    } catch (e) {
      // If loading fails, start with empty favorites
      _favoriteIds = [];
      _favoriteEvents = [];
      notifyListeners();
      print('Error loading favorites: $e');
    }
  }

  void _updateFavoriteEvents() {
    final allEvents = _eventsProvider.events;
    _favoriteEvents = allEvents.where((event) => _favoriteIds.contains(event.id)).toList();
    // Sort by start time
    _favoriteEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();
  }

  Future<bool> toggleFavorite(String eventId) async {
    try {
    final prefs = await SharedPreferences.getInstance();
      final wasFavorite = _favoriteIds.contains(eventId);
      
      if (wasFavorite) {
      _favoriteIds.remove(eventId);
    } else {
      _favoriteIds.add(eventId);
    }
    
      final success = await prefs.setStringList('favoriteIds', _favoriteIds);
      if (success) {
    _updateFavoriteEvents();
    notifyListeners();
        return true;
      } else {
        // Revert on failure
        if (!wasFavorite) {
          _favoriteIds.remove(eventId);
        } else {
          _favoriteIds.add(eventId);
        }
        return false;
      }
    } catch (e) {
      // Revert on error
      final wasFavorite = _favoriteIds.contains(eventId);
      if (!wasFavorite && _favoriteIds.contains(eventId)) {
        _favoriteIds.remove(eventId);
      } else if (wasFavorite && !_favoriteIds.contains(eventId)) {
        _favoriteIds.add(eventId);
      }
      print('Error toggling favorite: $e');
      return false;
    }
  }

  bool isFavorite(String eventId) {
    return _favoriteIds.contains(eventId);
  }

  Future<void> clearAllFavorites() async {
    try {
      // Clear favorites from memory
      _favoriteIds.clear();
      _favoriteEvents.clear();
      
      // Clear from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favoriteIds');
      
      notifyListeners();
    } catch (e) {
      print('Error clearing all favorites: $e');
      throw Exception('Failed to clear favorites');
    }
  }
}

