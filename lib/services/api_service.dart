import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import '../models/event.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  
  // Backend URL configuration
  // IMPORTANT: Update this based on your environment
  // 
  // For iOS Simulator: Use your computer's local IP (e.g., http://192.168.1.100:3000/api)
  // For Android Emulator: Use http://10.0.2.2:3000/api
  // For Physical Devices: Use your computer's local IP on same WiFi network
  // For Production: Use your deployed backend URL (e.g., https://api.yourapp.com)
  
  String get baseUrl {
    // Auto-detect platform and use appropriate URL
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:3000/api';
    } else {
      // iOS simulator and physical devices need your computer's IP address
      // Replace with your computer's IP address (run: ipconfig getifaddr en0)
      return 'http://192.168.77.40:3000/api';
    }
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors for logging (optional, useful for debugging)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Update base URL (useful for different environments)
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  // Set Auth Token
  void setToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // Convert hex color string to Color
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff'); // Add alpha if missing
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }
    return const Color(0xFFFFD700); // Default gold color
  }

  // Convert Color to hex string
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // Convert database event to Event model
  Event _eventFromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      location: json['location'] as String,
      category: json['category'] as String,
      color: _hexToColor(json['color'] as String? ?? '#FFD700'),
      imageUrl: json['image_url'] as String?,
    );
  }

  // Convert Event model to JSON for API
  Map<String, dynamic> _eventToJson(Event event) {
    return {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'startTime': event.startTime.toIso8601String(),
      'endTime': event.endTime.toIso8601String(),
      'location': event.location,
      'category': event.category,
      'color': _colorToHex(event.color),
      'imageUrl': event.imageUrl,
    };
  }

  // GET /api/events - Get all events
  Future<List<Event>> getEvents({
    String? category,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _dio.get('/events', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => _eventFromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  // GET /api/events/:id - Get a single event
  Future<Event> getEvent(String id) async {
    try {
      final response = await _dio.get('/events/$id');
      
      if (response.statusCode == 200) {
        return _eventFromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Event not found');
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error fetching event: $e');
    }
  }

  // POST /api/events - Create a new event
  Future<Event> createEvent(Event event) async {
    try {
      final response = await _dio.post(
        '/events',
        data: _eventToJson(event),
      );
      
      if (response.statusCode == 201) {
        return _eventFromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Event with this ID already exists');
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  // PUT /api/events/:id - Update an event
  Future<Event> updateEvent(Event event) async {
    try {
      final response = await _dio.put(
        '/events/${event.id}',
        data: _eventToJson(event),
      );
      
      if (response.statusCode == 200) {
        return _eventFromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Event not found');
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  // DELETE /api/events/:id - Delete an event
  Future<void> deleteEvent(String id) async {
    try {
      final response = await _dio.delete('/events/$id');
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Event not found');
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      // Create a temporary dio instance for health check (different base URL)
      final healthDio = Dio(BaseOptions(
        baseUrl: baseUrl.replaceAll('/api', ''),
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final response = await healthDio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Helper to handle Dio errors
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your settings.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Unauthorized access. Please login again.';
        } else if (e.response?.statusCode == 404) {
          return 'Resource not found.';
        } else if (e.response?.statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Network error. Please try again.';
    }
  }

  // Generic GET request
  Future<dynamic> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Generic POST request (supports multipart)
  Future<dynamic> post(String path, dynamic data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Generic PUT request (supports multipart)
  Future<dynamic> put(String path, dynamic data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
