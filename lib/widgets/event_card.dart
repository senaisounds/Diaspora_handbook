import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('EEE');
    final monthFormat = DateFormat('MMM');
    final dayNumberFormat = DateFormat('dd');
    // Handling the specific time format from the image (e.g. 10:00 PM)
    final timeFormat = DateFormat('h:mm a');

    // Add "TH", "ST", "ND", "RD" suffix to day number
    String getDaySuffix(int day) {
      if (day >= 11 && day <= 13) {
        return 'TH';
      }
      switch (day % 10) {
        case 1:
          return 'ST';
        case 2:
          return 'ND';
        case 3:
          return 'RD';
        default:
          return 'TH';
      }
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Column (Left)
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayFormat.format(event.startTime).toUpperCase(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFFFD700), // Gold
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    monthFormat.format(event.startTime).toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${dayNumberFormat.format(event.startTime)}${getDaySuffix(event.startTime.day)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Event Image (if available)
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: event.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: event.color.withOpacity(0.3),
                      child: Icon(Icons.image, color: event.color, size: 32),
                    );
                  },
                ),
              ),
            ],
            // Content Column (Right)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFFFD700), // Gold
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        event.endTime.difference(event.startTime).inHours > 12 
                        ? timeFormat.format(event.startTime) // If it's a long "camp" or all day, maybe just show start time or specific range
                        : '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
