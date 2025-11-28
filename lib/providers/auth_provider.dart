import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    
    if (_token != null) {
      _apiService.setToken(_token);
      try {
        await fetchCurrentUser();
      } catch (e) {
        // Token might be invalid/expired
        logout();
      }
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', {
        'username': username,
        'password': password,
      });

      _token = response['token'];
      _user = User.fromJson(response['user']);
      
      _apiService.setToken(_token);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String username, 
    String email, 
    String password, {
    String? instagram, 
    String? habeshaStatus,
    File? avatarFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'username': username,
        'email': email,
        'password': password,
        'instagram': instagram,
        'habeshaStatus': habeshaStatus,
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(avatarFile.path),
      });

      final response = await _apiService.post('/auth/register', formData);

      _token = response['token'];
      _user = User.fromJson(response['user']);
      
      _apiService.setToken(_token);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      
      _error = null;
    } catch (e) {
      // Format user-friendly error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (errorMessage.contains('409') || errorMessage.contains('Conflict')) {
        errorMessage = 'Username or email already exists. Please try logging in.';
      } else if (errorMessage.contains('400')) {
        errorMessage = 'Please check your input details.';
      } else if (errorMessage.contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }
      
      _error = errorMessage;
      throw Exception(errorMessage); // Re-throw with clean message for UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? instagram, 
    String? habeshaStatus,
    File? avatarFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'instagram': instagram,
        'habeshaStatus': habeshaStatus,
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(avatarFile.path),
      });

      final response = await _apiService.put('/auth/profile', formData);

      _user = User.fromJson(response['user']);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      _user = User.fromJson(response['user']);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get('/auth/user/$userId');
      return User.fromJson(response['user']);
    } catch (e) {
      throw Exception('Failed to load user profile');
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _apiService.setToken(null);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    notifyListeners();
  }
}
