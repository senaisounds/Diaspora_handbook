const express = require('express');
const router = express.Router();
const db = require('../database/db');

// GET /api/events - Get all events
router.get('/', async (req, res) => {
  try {
    const { category, location, startDate, endDate } = req.query;
    
    let query = 'SELECT * FROM events WHERE 1=1';
    const params = [];
    
    if (category) {
      query += ' AND category = ?';
      params.push(category);
    }
    
    if (location) {
      query += ' AND location LIKE ?';
      params.push(`%${location}%`);
    }
    
    if (startDate) {
      query += ' AND start_time >= ?';
      params.push(startDate);
    }
    
    if (endDate) {
      query += ' AND end_time <= ?';
      params.push(endDate);
    }
    
    query += ' ORDER BY start_time ASC';
    
    const events = await db.all(query, params);
    res.json(events);
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// GET /api/events/:id - Get a single event
router.get('/:id', async (req, res) => {
  try {
    const event = await db.get('SELECT * FROM events WHERE id = ?', [req.params.id]);
    
    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }
    
    res.json(event);
  } catch (error) {
    console.error('Error fetching event:', error);
    res.status(500).json({ error: 'Failed to fetch event' });
  }
});

// POST /api/events - Create a new event
router.post('/', async (req, res) => {
  try {
    const { id, title, description, startTime, endTime, location, category, color, imageUrl } = req.body;
    
    // Validation
    if (!id || !title || !startTime || !endTime || !location || !category || !color) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    await db.run(
      `INSERT INTO events (id, title, description, start_time, end_time, location, category, color, image_url, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)`,
      [id, title, description, startTime, endTime, location, category, color, imageUrl || null]
    );
    
    const event = await db.get('SELECT * FROM events WHERE id = ?', [id]);
    res.status(201).json(event);
  } catch (error) {
    console.error('Error creating event:', error);
    if (error.message.includes('UNIQUE constraint')) {
      res.status(409).json({ error: 'Event with this ID already exists' });
    } else {
      res.status(500).json({ error: 'Failed to create event' });
    }
  }
});

// PUT /api/events/:id - Update an event
router.put('/:id', async (req, res) => {
  try {
    const { title, description, startTime, endTime, location, category, color, imageUrl } = req.body;
    
    // Check if event exists
    const existing = await db.get('SELECT * FROM events WHERE id = ?', [req.params.id]);
    if (!existing) {
      return res.status(404).json({ error: 'Event not found' });
    }
    
    await db.run(
      `UPDATE events 
       SET title = ?, description = ?, start_time = ?, end_time = ?, location = ?, category = ?, color = ?, image_url = ?, updated_at = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [
        title || existing.title,
        description !== undefined ? description : existing.description,
        startTime || existing.start_time,
        endTime || existing.end_time,
        location || existing.location,
        category || existing.category,
        color || existing.color,
        imageUrl !== undefined ? imageUrl : existing.image_url,
        req.params.id
      ]
    );
    
    const event = await db.get('SELECT * FROM events WHERE id = ?', [req.params.id]);
    res.json(event);
  } catch (error) {
    console.error('Error updating event:', error);
    res.status(500).json({ error: 'Failed to update event' });
  }
});

// DELETE /api/events/:id - Delete an event
router.delete('/:id', async (req, res) => {
  try {
    const event = await db.get('SELECT * FROM events WHERE id = ?', [req.params.id]);
    
    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }
    
    await db.run('DELETE FROM events WHERE id = ?', [req.params.id]);
    res.status(204).send();
  } catch (error) {
    console.error('Error deleting event:', error);
    res.status(500).json({ error: 'Failed to delete event' });
  }
});

module.exports = router;

