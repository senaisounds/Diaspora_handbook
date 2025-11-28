import 'package:flutter/material.dart';
import '../models/event.dart';

// Helper to create dates for this year/next year roughly matching the schedule
// Note: The user images are from Jan 20th-24th (Week 5) and Jan 7th-10th (Week 3)
// We will use the current year or next year to make it relevant.
final int year = DateTime.now().year;
// Assuming January for the Homecoming Season
final DateTime baseDate = DateTime(year, 1, 1);

List<Event> getDummyEvents() {
  return [
    // WEEK 3 EVENTS (from Blue Image)
    Event(
      id: 'w3-1',
      title: 'DOSE SPECIAL EVENT',
      description: 'DJ K-Meta and DJ Eden',
      startTime: DateTime(year, 1, 7, 22, 0), // Tue Jan 07
      endTime: DateTime(year, 1, 8, 4, 0),
      location: 'Venue TBD', // Image doesn't specify venue, just DJs
      category: 'Party',
      color: const Color(0xFFFFD700), // Gold
    ),
    Event(
      id: 'w3-2',
      title: 'HOMEBOUND FORUM',
      description: 'Community discussion and networking.',
      startTime: DateTime(year, 1, 8, 16, 0), // Wed Jan 08
      endTime: DateTime(year, 1, 8, 19, 0),
      location: 'Boston Day Spa Building',
      category: 'Forum',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w3-3',
      title: 'DESIGN WEEK',
      description: 'Showcasing local design talent.',
      startTime: DateTime(year, 1, 9, 10, 0), // Thu Jan 09
      endTime: DateTime(year, 1, 9, 16, 0),
      location: 'Signature Residence',
      category: 'Exhibition',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w3-4',
      title: 'THE HABESHAS IN TECH',
      description: 'Networking for tech professionals.',
      startTime: DateTime(year, 1, 9, 16, 30), // Thu Jan 09
      endTime: DateTime(year, 1, 9, 20, 30),
      location: 'ALX Ethiopia - Lideta Hub, 4th Floor',
      category: 'Tech',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w3-5',
      title: 'REDCUP X WETMED',
      description: 'Evening social event.',
      startTime: DateTime(year, 1, 9, 18, 0), // Thu Jan 09
      endTime: DateTime(year, 1, 10, 1, 0),
      location: 'Millennium Hall',
      category: 'Party',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w3-6',
      title: 'KITFO TV: ROUND TABLE TALK',
      description: 'Discussions on media and culture.',
      startTime: DateTime(year, 1, 10, 9, 0), // Fri Jan 10
      endTime: DateTime(year, 1, 10, 11, 0),
      location: 'Prestige Addis, U.S. Embassy',
      category: 'Talk',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w3-7',
      title: 'KITFO FILM FESTIVAL',
      description: 'Screening of local and diaspora films.',
      startTime: DateTime(year, 1, 10, 12, 0), // Fri Jan 10
      endTime: DateTime(year, 1, 10, 18, 0),
      location: 'Italian Cultural Institute',
      category: 'Film',
      color: const Color(0xFFFFD700),
    ),
     Event(
      id: 'w3-8',
      title: 'FIRST WE DANCE GLOBAL & HOODING COLAB',
      description: 'Music and dance collaboration.',
      startTime: DateTime(year, 1, 10, 22, 0), // Fri Jan 10
      endTime: DateTime(year, 1, 11, 3, 0),
      location: 'Pandora Addis',
      category: 'Party',
      color: const Color(0xFFFFD700),
    ),

    // WEEK 5 EVENTS (from Purple Image)
    Event(
      id: 'w5-1',
      title: 'SONG WRITING CAMP',
      description: 'Collaborative music creation session.',
      startTime: DateTime(year, 1, 20, 11, 0), // Mon Jan 20
      endTime: DateTime(year, 1, 20, 23, 0),
      location: 'TBD',
      category: 'Workshop',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w5-2',
      title: 'FENDIKA',
      description: 'Cultural music and dance performance.',
      startTime: DateTime(year, 1, 20, 18, 0), // Mon Jan 20
      endTime: DateTime(year, 1, 20, 23, 0), // Guessing end time
      location: 'Hyatt Regency',
      category: 'Performance',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w5-3',
      title: 'THE LAST RODEO - HORSE BACK RIDING TRIP',
      description: 'Outdoor adventure and networking.',
      startTime: DateTime(year, 1, 21, 10, 0), // Tue Jan 21
      endTime: DateTime(year, 1, 21, 14, 0),
      location: 'Beka Ferda Ranch',
      category: 'Adventure',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w5-4',
      title: 'VOLUNTEER AT TESFA CHILDREN\'S CANCER CENTER',
      description: 'Giving back to the community.',
      startTime: DateTime(year, 1, 22, 16, 0), // Wed Jan 22
      endTime: DateTime(year, 1, 22, 18, 0),
      location: 'Tesfa Children\'s Cancer Center',
      category: 'Volunteer',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w5-5',
      title: 'THE ARTIST PLAYGROUND LISTENING PARTY',
      description: 'Showcase of new music releases.',
      startTime: DateTime(year, 1, 23, 18, 0), // Thu Jan 23
      endTime: DateTime(year, 1, 23, 22, 0),
      location: '251 Kitchen & Cocktails',
      category: 'Music',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w5-6',
      title: 'LUNA LOUNGE SPECIAL EVENT',
      description: 'Nightlife experience.',
      startTime: DateTime(year, 1, 23, 22, 0), // Thu Jan 23
      endTime: DateTime(year, 1, 24, 3, 0),
      location: 'Luna Lounge',
      category: 'Party',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w5-7',
      title: 'HAFW FASHION WEEK EVENT',
      description: 'Fashion show and exhibition.',
      startTime: DateTime(year, 1, 24, 18, 0), // Fri Jan 24
      endTime: DateTime(year, 1, 24, 22, 0),
      location: 'Millennium Hall',
      category: 'Fashion',
      color: const Color(0xFFFFD700),
    ),
    Event(
      id: 'w5-8',
      title: 'CLASS OF PANDORA: A NIGHT TO REMEMBER',
      description: 'Grand celebration event.',
      startTime: DateTime(year, 1, 24, 22, 0), // Fri Jan 24
      endTime: DateTime(year, 1, 25, 4, 0),
      location: 'Pandora Addis',
      category: 'Party',
      color: const Color(0xFFFFD700),
    ),
  ];
}
