import 'package:flutter/material.dart';

/// Centralized error handling utility
class ErrorHandler {
  /// Convert exceptions to user-friendly error messages
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('connection refused') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('socketexception')) {
      return 'Unable to connect to the server. Please check your internet connection and ensure the backend server is running.';
    }
    
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Request timed out. Please check your connection and try again.';
    }
    
    // HTTP errors
    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'The requested resource was not found.';
    }
    
    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'You are not authorized to perform this action.';
    }
    
    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Access to this resource is forbidden.';
    }
    
    if (errorString.contains('409') || errorString.contains('conflict')) {
      return 'This resource already exists.';
    }
    
    if (errorString.contains('500') || errorString.contains('server error')) {
      return 'Server error occurred. Please try again later.';
    }
    
    // Storage errors
    if (errorString.contains('sharedpreferences') ||
        errorString.contains('storage') ||
        errorString.contains('permission denied')) {
      return 'Unable to save data. Please check app permissions.';
    }
    
    // Calendar errors
    if (errorString.contains('calendar') || errorString.contains('permission')) {
      return 'Unable to access calendar. Please grant calendar permissions in settings.';
    }
    
    // Location errors
    if (errorString.contains('location') || errorString.contains('maps')) {
      return 'Unable to open maps. Please check if a maps app is installed.';
    }
    
    // Generic error
    return 'An unexpected error occurred. Please try again.';
  }
  
  /// Show error snackbar
  static void showError(BuildContext context, dynamic error) {
    final message = getUserFriendlyMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Handle async operation with error handling
  static Future<T?> handleAsync<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? successMessage,
    bool showErrorMessage = true,
    T? defaultValue,
  }) async {
    try {
      final result = await operation();
      if (successMessage != null && context.mounted) {
        ErrorHandler.showSuccess(context, successMessage);
      }
      return result;
    } catch (e) {
      if (showErrorMessage && context.mounted) {
        ErrorHandler.showError(context, e);
      }
      return defaultValue;
    }
  }
}

