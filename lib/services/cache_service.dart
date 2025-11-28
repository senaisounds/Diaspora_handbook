import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../data/dummy_data.dart';

/// Service for caching events locally for offline support
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _eventsCacheKey = 'cached_events';
  static const String _cacheTimestampKey = 'events_cache_timestamp';
  static const Duration _cacheValidity = Duration(hours: 24); // Cache valid for 24 hours

  /// Save events to local cache
  Future<bool> cacheEvents(List<Event> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert events to JSON
      final eventsJson = events.map((event) => _eventToJson(event)).toList();
      final jsonString = jsonEncode(eventsJson);
      
      // Save events and timestamp
      await prefs.setString(_eventsCacheKey, jsonString);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      return true;
    } catch (e) {
      print('Error caching events: $e');
      return false;
    }
  }

  /// Load events from local cache
  Future<List<Event>> loadCachedEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_eventsCacheKey);
      
      if (cachedJson == null || cachedJson.isEmpty) {
        // No cache exists, return dummy data as fallback
        return getDummyEvents();
      }
      
      final List<dynamic> eventsList = jsonDecode(cachedJson);
      return eventsList.map((json) => _eventFromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading cached events: $e');
      // If cache is corrupted, return dummy data
      return getDummyEvents();
    }
  }

  /// Check if cache is still valid
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) < _cacheValidity;
    } catch (e) {
      return false;
    }
  }

  /// Check if cache exists
  Future<bool> hasCachedEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_eventsCacheKey);
    } catch (e) {
      return false;
    }
  }

  /// Clear the cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_eventsCacheKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Convert Event to JSON for caching
  Map<String, dynamic> _eventToJson(Event event) {
    return {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'startTime': event.startTime.toIso8601String(),
      'endTime': event.endTime.toIso8601String(),
      'location': event.location,
      'category': event.category,
      'color': event.color.value.toRadixString(16),
      'imageUrl': event.imageUrl,
    };
  }

  /// Convert JSON to Event from cache
  Event _eventFromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String,
      category: json['category'] as String,
      color: Color(int.parse(json['color'] as String, radix: 16)),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Get cache age
  Future<Duration?> getCacheAge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (timestamp == null) return null;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cacheTime);
    } catch (e) {
      return null;
    }
  }
}

