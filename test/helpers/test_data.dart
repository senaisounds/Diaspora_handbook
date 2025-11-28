import 'package:flutter/material.dart';
import 'package:diaspora_handbook/models/event.dart';
import 'package:diaspora_handbook/models/channel.dart';
import 'package:diaspora_handbook/models/message.dart';

class TestData {
  // Test Events
  static final Event event1 = Event(
    id: 'event1',
    title: 'Test Event 1',
    description: 'This is a test event',
    startTime: DateTime(2025, 1, 8, 13, 0),
    endTime: DateTime(2025, 1, 8, 19, 0),
    location: 'Venue TBD',
    category: 'Exhibition',
    color: const Color(0xFFFFD700),
    imageUrl: null,
  );

  static final Event event2 = Event(
    id: 'event2',
    title: 'Test Event 2',
    description: 'Another test event',
    startTime: DateTime(2025, 1, 9, 19, 0),
    endTime: DateTime(2025, 1, 9, 22, 0),
    location: 'Boston Day Spa Building',
    category: 'Community',
    color: const Color(0xFFFFD700),
    imageUrl: null,
  );

  static final Event event3 = Event(
    id: 'event3',
    title: 'Design Week',
    description: 'Showcasing local design talent',
    startTime: DateTime(2025, 1, 9, 13, 0),
    endTime: DateTime(2025, 1, 9, 17, 0),
    location: 'Signature Residence',
    category: 'Design',
    color: const Color(0xFFFFD700),
    imageUrl: null,
  );

  static List<Event> get allEvents => [event1, event2, event3];

  // Test Channels
  static final Channel announcementChannel = Channel(
    id: 'ch_announcements',
    name: 'Announcements',
    description: 'Welcome to the community!',
    icon: '📢',
    emoji: '📢',
    memberCount: 0,
    isAnnouncement: true,
    createdAt: DateTime.now(),
  );

  static final Channel generalChannel = Channel(
    id: 'ch_general',
    name: '#GENERAL',
    description: 'General discussions',
    icon: '💬',
    emoji: '💬',
    memberCount: 267,
    isAnnouncement: false,
    createdAt: DateTime.now(),
  );

  static final Channel eventsChannel = Channel(
    id: 'ch_events',
    name: '#DHEVENTS',
    description: 'Discuss and share diaspora events',
    icon: '🎉',
    emoji: '🎉',
    memberCount: 335,
    isAnnouncement: false,
    createdAt: DateTime.now(),
  );

  static List<Channel> get allChannels => [
        announcementChannel,
        generalChannel,
        eventsChannel,
      ];

  // Test Messages
  static final Message message1 = Message(
    id: 'msg1',
    channelId: 'ch_general',
    userId: 'user1',
    username: 'TestUser1',
    content: 'Hello everyone!',
    messageType: 'text',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  static final Message message2 = Message(
    id: 'msg2',
    channelId: 'ch_general',
    userId: 'user2',
    username: 'TestUser2',
    content: 'Hi there!',
    messageType: 'text',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  );

  static List<Message> get generalMessages => [message1, message2];

  // Test User
  static final ChatUser testUser = ChatUser(
    id: 'user1',
    username: 'TestUser',
    deviceId: 'test-device-123',
    createdAt: DateTime.now(),
  );
}

