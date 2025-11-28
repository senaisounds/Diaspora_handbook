import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';

class MapsService {
  static final MapsService _instance = MapsService._internal();
  factory MapsService() => _instance;
  MapsService._internal();

  Future<void> openLocationInMaps(Event event) async {
    final encodedLocation = Uri.encodeComponent(event.location);
    
    // Try to open in Google Maps first, fallback to Apple Maps
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$encodedLocation');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> getDirectionsToLocation(Event event) async {
    final encodedLocation = Uri.encodeComponent(event.location);
    
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encodedLocation');
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?daddr=$encodedLocation');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }
}

