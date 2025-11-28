import 'package:url_launcher/url_launcher.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<void> openMaps(String location) async {
    // Encode the location for URL
    final encodedLocation = Uri.encodeComponent(location);
    
    // Try to open in Google Maps first, fallback to Apple Maps
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
    final appleMapsUrl = 'https://maps.apple.com/?q=$encodedLocation';

    try {
      final uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to Apple Maps
        final appleUri = Uri.parse(appleMapsUrl);
        if (await canLaunchUrl(appleUri)) {
          await launchUrl(appleUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('Error opening maps: $e');
      rethrow; // Re-throw so caller can handle it
    }
  }

  Future<void> getDirections(String location) async {
    final encodedLocation = Uri.encodeComponent(location);
    final directionsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$encodedLocation';

    try {
      final uri = Uri.parse(directionsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Unable to open maps. Please install a maps application.');
      }
    } catch (e) {
      print('Error getting directions: $e');
      rethrow; // Re-throw so caller can handle it
    }
  }
}

