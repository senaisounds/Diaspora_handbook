const db = require('../database/db');

// Convert Color to hex string (0xFFFFD700 -> #FFD700)
function colorToHex(colorValue) {
  // Remove 0x prefix and convert to hex string
  const hex = colorValue.toString(16).toUpperCase();
  return `#${hex}`;
}

async function seedDatabase() {
  try {
    await db.connect();
    
    const year = new Date().getFullYear();
    const events = [
      // WEEK 3 EVENTS
      {
        id: 'w3-1',
        title: 'DOSE SPECIAL EVENT',
        description: 'DJ K-Meta and DJ Eden',
        start_time: new Date(year, 0, 7, 22, 0).toISOString(),
        end_time: new Date(year, 0, 8, 4, 0).toISOString(),
        location: 'Venue TBD',
        category: 'Party',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w3-2',
        title: 'HOMEBOUND FORUM',
        description: 'Community discussion and networking.',
        start_time: new Date(year, 0, 8, 16, 0).toISOString(),
        end_time: new Date(year, 0, 8, 19, 0).toISOString(),
        location: 'Boston Day Spa Building',
        category: 'Forum',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w3-3',
        title: 'DESIGN WEEK',
        description: 'Showcasing local design talent.',
        start_time: new Date(year, 0, 9, 10, 0).toISOString(),
        end_time: new Date(year, 0, 9, 16, 0).toISOString(),
        location: 'Signature Residence',
        category: 'Exhibition',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w3-4',
        title: 'THE HABESHAS IN TECH',
        description: 'Networking for tech professionals.',
        start_time: new Date(year, 0, 9, 16, 30).toISOString(),
        end_time: new Date(year, 0, 9, 20, 30).toISOString(),
        location: 'ALX Ethiopia - Lideta Hub, 4th Floor',
        category: 'Tech',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w3-5',
        title: 'REDCUP X WETMED',
        description: 'Evening social event.',
        start_time: new Date(year, 0, 9, 18, 0).toISOString(),
        end_time: new Date(year, 0, 10, 1, 0).toISOString(),
        location: 'Millennium Hall',
        category: 'Party',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w3-6',
        title: 'KITFO TV: ROUND TABLE TALK',
        description: 'Discussions on media and culture.',
        start_time: new Date(year, 0, 10, 9, 0).toISOString(),
        end_time: new Date(year, 0, 10, 11, 0).toISOString(),
        location: 'Prestige Addis, U.S. Embassy',
        category: 'Talk',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w3-7',
        title: 'KITFO FILM FESTIVAL',
        description: 'Screening of local and diaspora films.',
        start_time: new Date(year, 0, 10, 12, 0).toISOString(),
        end_time: new Date(year, 0, 10, 18, 0).toISOString(),
        location: 'Italian Cultural Institute',
        category: 'Film',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w3-8',
        title: 'FIRST WE DANCE GLOBAL & HOODING COLAB',
        description: 'Music and dance collaboration.',
        start_time: new Date(year, 0, 10, 22, 0).toISOString(),
        end_time: new Date(year, 0, 11, 3, 0).toISOString(),
        location: 'Pandora Addis',
        category: 'Party',
        color: '#FFD700',
        image_url: null
      },
      // WEEK 5 EVENTS
      {
        id: 'w5-1',
        title: 'SONG WRITING CAMP',
        description: 'Collaborative music creation session.',
        start_time: new Date(year, 0, 20, 11, 0).toISOString(),
        end_time: new Date(year, 0, 20, 23, 0).toISOString(),
        location: 'TBD',
        category: 'Workshop',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w5-2',
        title: 'FENDIKA',
        description: 'Cultural music and dance performance.',
        start_time: new Date(year, 0, 20, 18, 0).toISOString(),
        end_time: new Date(year, 0, 20, 23, 0).toISOString(),
        location: 'Hyatt Regency',
        category: 'Performance',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w5-3',
        title: 'THE LAST RODEO - HORSE BACK RIDING TRIP',
        description: 'Outdoor adventure and networking.',
        start_time: new Date(year, 0, 21, 10, 0).toISOString(),
        end_time: new Date(year, 0, 21, 14, 0).toISOString(),
        location: 'Beka Ferda Ranch',
        category: 'Adventure',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w5-4',
        title: 'VOLUNTEER AT TESFA CHILDREN\'S CANCER CENTER',
        description: 'Giving back to the community.',
        start_time: new Date(year, 0, 22, 16, 0).toISOString(),
        end_time: new Date(year, 0, 22, 18, 0).toISOString(),
        location: 'Tesfa Children\'s Cancer Center',
        category: 'Volunteer',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w5-5',
        title: 'THE ARTIST PLAYGROUND LISTENING PARTY',
        description: 'Showcase of new music releases.',
        start_time: new Date(year, 0, 23, 18, 0).toISOString(),
        end_time: new Date(year, 0, 23, 22, 0).toISOString(),
        location: '251 Kitchen & Cocktails',
        category: 'Music',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w5-6',
        title: 'LUNA LOUNGE SPECIAL EVENT',
        description: 'Nightlife experience.',
        start_time: new Date(year, 0, 23, 22, 0).toISOString(),
        end_time: new Date(year, 0, 24, 3, 0).toISOString(),
        location: 'Luna Lounge',
        category: 'Party',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w5-7',
        title: 'HAFW FASHION WEEK EVENT',
        description: 'Fashion show and exhibition.',
        start_time: new Date(year, 0, 24, 18, 0).toISOString(),
        end_time: new Date(year, 0, 24, 22, 0).toISOString(),
        location: 'Millennium Hall',
        category: 'Fashion',
        color: '#FFD700',
        image_url: null
      },
      {
        id: 'w5-8',
        title: 'CLASS OF PANDORA: A NIGHT TO REMEMBER',
        description: 'Grand celebration event.',
        start_time: new Date(year, 0, 24, 22, 0).toISOString(),
        end_time: new Date(year, 0, 25, 4, 0).toISOString(),
        location: 'Pandora Addis',
        category: 'Party',
        color: '#FFD700',
        image_url: null
      }
    ];

    // Clear existing events
    await db.run('DELETE FROM events');
    
    // Insert events
    for (const event of events) {
      await db.run(
        `INSERT INTO events (id, title, description, start_time, end_time, location, category, color, image_url)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          event.id,
          event.title,
          event.description,
          event.start_time,
          event.end_time,
          event.location,
          event.category,
          event.color,
          event.image_url
        ]
      );
    }
    
    console.log(`Seeded ${events.length} events into database`);
    await db.close();
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    await db.close();
    process.exit(1);
  }
}

seedDatabase();

