import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {};
  Event? _selectedEvent;
  bool _mapError = false;

  // Addis Ababa coordinates (approximate center)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(9.1450, 38.7614),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
  }

  void _loadEventMarkers(List<Event> events) {
    final markers = <Marker>{};

    // Create markers for each event
    // Note: In a real app, you'd geocode the addresses to get coordinates
    // For now, we'll use approximate locations based on venue names
    for (var event in events) {
      final position = _getLocationForEvent(event);
      if (position != null) {
        markers.add(
          Marker(
            markerId: MarkerId(event.id),
            position: position,
            infoWindow: InfoWindow(
              title: event.title,
              snippet: event.location,
              onTap: () {
                setState(() {
                  _selectedEvent = event;
                });
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerColor(event.category),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers.addAll(markers);
    });
  }

  LatLng? _getLocationForEvent(Event event) {
    // Approximate coordinates for known venues in Addis Ababa
    // In a real app, use geocoding service
    final venueMap = {
      'Millennium Hall': const LatLng(9.0102, 38.7614),
      'Pandora Addis': const LatLng(9.0200, 38.7700),
      'Hyatt Regency': const LatLng(9.0300, 38.7800),
      'Luna Lounge': const LatLng(9.0150, 38.7650),
      '251 Kitchen & Cocktails': const LatLng(9.0250, 38.7750),
      'Beka Ferda Ranch': const LatLng(9.1000, 38.8000),
      'ALX Ethiopia - Lideta Hub, 4th Floor': const LatLng(9.0400, 38.7500),
      'Italian Cultural Institute': const LatLng(9.0350, 38.7600),
      'Prestige Addis, U.S. Embassy': const LatLng(9.0450, 38.7700),
      'Signature Residence': const LatLng(9.0500, 38.7800),
      'Boston Day Spa Building': const LatLng(9.0550, 38.7900),
      'Tesfa Children\'s Cancer Center': const LatLng(9.0600, 38.8000),
    };

    return venueMap[event.location] ?? const LatLng(9.1450, 38.7614); // Default to city center
  }

  double _getMarkerColor(String category) {
    // Map categories to marker colors
    final colorMap = {
      'Party': BitmapDescriptor.hueYellow,
      'Forum': BitmapDescriptor.hueBlue,
      'Exhibition': BitmapDescriptor.hueGreen,
      'Tech': BitmapDescriptor.hueCyan,
      'Talk': BitmapDescriptor.hueOrange,
      'Film': BitmapDescriptor.hueMagenta,
      'Workshop': BitmapDescriptor.hueViolet,
      'Performance': BitmapDescriptor.hueRed,
      'Adventure': BitmapDescriptor.hueRose,
      'Volunteer': BitmapDescriptor.hueAzure,
      'Music': BitmapDescriptor.hueYellow,
      'Fashion': BitmapDescriptor.hueMagenta,
    };
    return colorMap[category] ?? BitmapDescriptor.hueYellow;
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final events = eventsProvider.events;
    
    // Load markers when events change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventMarkers(events);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              _showEventList(context, events);
            },
          ),
        ],
      ),
      body: _mapError
          ? _buildErrorView()
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  onTap: (LatLng position) {
                    setState(() {
                      _selectedEvent = null;
                    });
                  },
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    // Map created successfully
                  },
                ),
                if (_selectedEvent != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 8,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(event: _selectedEvent!),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedEvent!.title,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: const Color(0xFFFFD700),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _selectedEvent = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedEvent!.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _selectedEvent!.location,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailScreen(event: _selectedEvent!),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD700),
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              'Map Unavailable',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Google Maps requires an API key to function. Please configure your API key in the AndroidManifest.xml and Info.plist files.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final eventsProvider = context.read<EventsProvider>();
                _showEventList(context, eventsProvider.events);
              },
              icon: const Icon(Icons.list),
              label: const Text('View Event List Instead'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _mapError = false;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventList(BuildContext context, List<Event> events) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Events (${events.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: event.color,
                        child: Icon(Icons.event, color: Colors.white),
                      ),
                      title: Text(event.title),
                      subtitle: Text('${event.location} • ${DateFormat('MMM d').format(event.startTime)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailScreen(event: event),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

