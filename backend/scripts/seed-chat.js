const db = require('../database/db');

async function seedChat() {
  try {
    await db.connect();
    console.log('Seeding chat data...');

    // Default channels
    const channels = [
      {
        id: 'ch_announcements',
        name: 'Announcements',
        description: 'Welcome to the community!',
        icon: '📢',
        emoji: '📢',
        isAnnouncement: true
      },
      {
        id: 'ch_dhevents',
        name: '#DHEVENTS',
        description: 'Discuss and share diaspora events',
        icon: '🎉',
        emoji: '🎉',
        isAnnouncement: false
      },
      {
        id: 'ch_general',
        name: '#GENERAL',
        description: 'General discussions',
        icon: '💬',
        emoji: '💬',
        isAnnouncement: false
      },
      {
        id: 'ch_networking',
        name: '#DHNETWORKING',
        description: 'Network and connect with others',
        icon: '💼',
        emoji: '💼',
        isAnnouncement: false
      },
      {
        id: 'ch_wheretoeat',
        name: '#DHWHERETOEAT',
        description: 'Share restaurant recommendations',
        icon: '🍽️',
        emoji: '🍽️',
        isAnnouncement: false
      },
      {
        id: 'ch_traveltips',
        name: '#DHTRAVELTIPS',
        description: 'Share travel tips and advice',
        icon: '✈️',
        emoji: '✈️',
        isAnnouncement: false
      },
      {
        id: 'ch_fitness',
        name: '#DHFITNESS&HEALTH',
        description: 'Health and fitness discussions',
        icon: '🎯',
        emoji: '🎯',
        isAnnouncement: false
      }
    ];

    // Insert channels with random member counts
    for (const channel of channels) {
      const memberCount = channel.isAnnouncement ? 0 : Math.floor(Math.random() * 300) + 50;
      
      await db.run(
        `INSERT OR REPLACE INTO channels 
         (id, name, description, icon, emoji, is_announcement, member_count, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))`,
        [
          channel.id,
          channel.name,
          channel.description,
          channel.icon,
          channel.emoji,
          channel.isAnnouncement ? 1 : 0,
          memberCount
        ]
      );
      
      console.log(`✓ Created channel: ${channel.name} (${memberCount} members)`);
    }

    // Add a welcome message to announcements
    await db.run(
      `INSERT INTO messages (id, channel_id, user_id, username, content, message_type, created_at)
       VALUES (?, ?, ?, ?, ?, ?, datetime('now'))`,
      [
        'msg_welcome',
        'ch_announcements',
        'system',
        'Diaspora Handbook',
        'Welcome to the Diaspora Handbook community! 🎉\n\nJoin different groups to connect with others, share experiences, and discover events.',
        'text'
      ]
    );

    console.log('✓ Chat data seeded successfully!');
    await db.close();
  } catch (error) {
    console.error('Error seeding chat data:', error);
    process.exit(1);
  }
}

seedChat();

