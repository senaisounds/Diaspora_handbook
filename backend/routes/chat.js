const express = require('express');
const router = express.Router();
const db = require('../database/db');

// Get all channels
router.get('/channels', async (req, res) => {
  try {
    const channels = await db.all(`
      SELECT * FROM channels 
      ORDER BY is_announcement DESC, name ASC
    `);
    res.json(channels);
  } catch (error) {
    console.error('Error fetching channels:', error);
    res.status(500).json({ error: 'Failed to fetch channels' });
  }
});

// Get a specific channel
router.get('/channels/:id', async (req, res) => {
  try {
    const channel = await db.get(
      'SELECT * FROM channels WHERE id = ?',
      [req.params.id]
    );
    
    if (!channel) {
      return res.status(404).json({ error: 'Channel not found' });
    }
    
    res.json(channel);
  } catch (error) {
    console.error('Error fetching channel:', error);
    res.status(500).json({ error: 'Failed to fetch channel' });
  }
});

// Create a new channel
router.post('/channels', async (req, res) => {
  try {
    const { name, description, icon, emoji, isAnnouncement = false } = req.body;
    
    if (!name || !icon) {
      return res.status(400).json({ error: 'Name and icon are required' });
    }
    
    const id = `ch_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    await db.run(
      `INSERT INTO channels (id, name, description, icon, emoji, is_announcement, member_count, created_at)
       VALUES (?, ?, ?, ?, ?, ?, 0, datetime('now'))`,
      [id, name, description, icon, emoji, isAnnouncement ? 1 : 0]
    );
    
    const channel = await db.get('SELECT * FROM channels WHERE id = ?', [id]);
    res.status(201).json(channel);
  } catch (error) {
    console.error('Error creating channel:', error);
    res.status(500).json({ error: 'Failed to create channel' });
  }
});

// Get messages for a channel
router.get('/channels/:id/messages', async (req, res) => {
  try {
    const { limit = 50, before } = req.query;
    
    let query = `
      SELECT * FROM messages 
      WHERE channel_id = ?
    `;
    const params = [req.params.id];
    
    if (before) {
      query += ' AND created_at < ?';
      params.push(before);
    }
    
    query += ' ORDER BY created_at DESC LIMIT ?';
    params.push(parseInt(limit));
    
    const messages = await db.all(query, params);
    res.json(messages.reverse()); // Return oldest first
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// Create or get user
router.post('/users', async (req, res) => {
  try {
    const { username, deviceId } = req.body;
    
    if (!username || !deviceId) {
      return res.status(400).json({ error: 'Username and deviceId are required' });
    }
    
    // Check if user exists by device ID
    let user = await db.get('SELECT * FROM users WHERE device_id = ?', [deviceId]);
    
    if (!user) {
      // Check if username is taken
      const usernameExists = await db.get('SELECT id FROM users WHERE username = ?', [username]);
      
      if (usernameExists) {
        // If username exists, find an available one
        let uniqueUsername = username;
        let attempts = 0;
        while (attempts < 10) {
          const randomSuffix = Math.floor(Math.random() * 10000);
          uniqueUsername = `User${randomSuffix}`;
          const exists = await db.get('SELECT id FROM users WHERE username = ?', [uniqueUsername]);
          if (!exists) break;
          attempts++;
        }
        
        // Create new user with unique username
        const id = `usr_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        
        await db.run(
          `INSERT INTO users (id, username, device_id, created_at)
           VALUES (?, ?, ?, datetime('now'))`,
          [id, uniqueUsername, deviceId]
        );
        
        user = await db.get('SELECT * FROM users WHERE id = ?', [id]);
      } else {
        // Create new user with provided username
        const id = `usr_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        
        await db.run(
          `INSERT INTO users (id, username, device_id, created_at)
           VALUES (?, ?, ?, datetime('now'))`,
          [id, username, deviceId]
        );
        
        user = await db.get('SELECT * FROM users WHERE id = ?', [id]);
      }
    }
    
    res.json(user);
  } catch (error) {
    console.error('Error creating/getting user:', error);
    res.status(500).json({ error: 'Failed to create/get user' });
  }
});

// Join a channel
router.post('/channels/:id/join', async (req, res) => {
  try {
    const { userId } = req.body;
    const channelId = req.params.id;
    
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }
    
    // Check if already a member
    const existing = await db.get(
      'SELECT * FROM channel_members WHERE channel_id = ? AND user_id = ?',
      [channelId, userId]
    );
    
    if (!existing) {
      await db.run(
        `INSERT INTO channel_members (channel_id, user_id, joined_at)
         VALUES (?, ?, datetime('now'))`,
        [channelId, userId]
      );
      
      // Update member count
      await db.run(
        'UPDATE channels SET member_count = member_count + 1 WHERE id = ?',
        [channelId]
      );
    }
    
    res.json({ success: true });
  } catch (error) {
    console.error('Error joining channel:', error);
    res.status(500).json({ error: 'Failed to join channel' });
  }
});

// Leave a channel
router.post('/channels/:id/leave', async (req, res) => {
  try {
    const { userId } = req.body;
    const channelId = req.params.id;
    
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }
    
    await db.run(
      'DELETE FROM channel_members WHERE channel_id = ? AND user_id = ?',
      [channelId, userId]
    );
    
    // Update member count
    await db.run(
      'UPDATE channels SET member_count = member_count - 1 WHERE id = ?',
      [channelId]
    );
    
    res.json({ success: true });
  } catch (error) {
    console.error('Error leaving channel:', error);
    res.status(500).json({ error: 'Failed to leave channel' });
  }
});

// Get user's joined channels
router.get('/users/:userId/channels', async (req, res) => {
  try {
    const channels = await db.all(`
      SELECT c.* FROM channels c
      INNER JOIN channel_members cm ON c.id = cm.channel_id
      WHERE cm.user_id = ?
      ORDER BY c.is_announcement DESC, c.name ASC
    `, [req.params.userId]);
    
    res.json(channels);
  } catch (error) {
    console.error('Error fetching user channels:', error);
    res.status(500).json({ error: 'Failed to fetch user channels' });
  }
});

module.exports = router;

