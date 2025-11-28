const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../database/db');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configure multer for storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads/avatars';
    // Ensure directory exists
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    // Generate unique filename: user_timestamp_random.ext
    const uniqueSuffix = Date.now() + '_' + Math.round(Math.random() * 1E9);
    cb(null, 'avatar_' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only images are allowed'));
    }
  }
});

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'diaspora_handbook_secret_key_2025';

// Middleware to authenticate user
const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const user = jwt.verify(token, JWT_SECRET);
    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// Register a new user with optional avatar
router.post('/register', upload.single('avatar'), async (req, res) => {
  try {
    const { username, password, email, deviceId, instagram, habeshaStatus } = req.body;
    
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    // Check if user exists
    const existingUser = await db.get(
      'SELECT id FROM users WHERE username = ? OR email = ?',
      [username, email]
    );

    if (existingUser) {
      // If file was uploaded but registration failed, delete it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(409).json({ error: 'Username or email already exists' });
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);
    
    // Generate ID
    const userId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Determine avatar URL
    let avatarUrl = null;
    if (req.file) {
      // Assuming server runs on port 3000
      // In production, use env var for base URL
      avatarUrl = `/uploads/avatars/${req.file.filename}`;
    }

    // Insert user
    await db.run(
      'INSERT INTO users (id, username, email, password_hash, device_id, instagram_handle, habesha_status, avatar_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [userId, username, email, passwordHash, deviceId, instagram, habeshaStatus, avatarUrl]
    );

    // Generate token
    const token = jwt.sign({ id: userId, username }, JWT_SECRET, { expiresIn: '30d' });

    res.status(201).json({
      token,
      user: {
        id: userId,
        username,
        email,
        avatar_url: avatarUrl,
        instagram_handle: instagram,
        habesha_status: habeshaStatus
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    if (req.file) {
      fs.unlinkSync(req.file.path); // Cleanup on error
    }
    res.status(500).json({ error: 'Failed to register user' });
  }
});

// Login user (unchanged)
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    // Find user
    const user = await db.get(
      'SELECT * FROM users WHERE username = ?',
      [username]
    );

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check password
    const match = await bcrypt.compare(password, user.password_hash);

    if (!match) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate token
    const token = jwt.sign({ id: user.id, username: user.username }, JWT_SECRET, { expiresIn: '30d' });

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        avatar_url: user.avatar_url,
        instagram_handle: user.instagram_handle,
        habesha_status: user.habesha_status
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

// Get current user (unchanged)
router.get('/me', async (req, res) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    return res.status(401).json({ error: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    
    const user = await db.get(
      'SELECT id, username, email, avatar_url, instagram_handle, habesha_status FROM users WHERE id = ?',
      [decoded.id]
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user });
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
});

// Get public user profile by ID
router.get('/user/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    
    const user = await db.get(
      'SELECT id, username, avatar_url, instagram_handle, habesha_status, created_at FROM users WHERE id = ?',
      [userId]
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get post count
    const stats = await db.get(
      'SELECT COUNT(*) as post_count FROM posts WHERE user_id = ?',
      [userId]
    );

    res.json({ 
      user: {
        ...user,
        post_count: stats.post_count || 0
      }
    });
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
});

// Update user profile (with avatar support)
router.put('/profile', authenticate, upload.single('avatar'), async (req, res) => {
  try {
    const { instagram, habeshaStatus } = req.body;
    const userId = req.user.id;

    // Get current user to check for old avatar
    const currentUser = await db.get('SELECT avatar_url FROM users WHERE id = ?', [userId]);

    let updateQuery = 'UPDATE users SET instagram_handle = ?, habesha_status = ?';
    let params = [instagram, habeshaStatus];

    if (req.file) {
      const newAvatarUrl = `/uploads/avatars/${req.file.filename}`;
      updateQuery += ', avatar_url = ?';
      params.push(newAvatarUrl);

      // Delete old avatar if it exists and is a local file
      if (currentUser && currentUser.avatar_url && currentUser.avatar_url.startsWith('/uploads')) {
        const oldAvatarPath = path.join(__dirname, '..', currentUser.avatar_url);
        if (fs.existsSync(oldAvatarPath)) {
          try {
            fs.unlinkSync(oldAvatarPath);
          } catch (err) {
            console.error('Failed to delete old avatar:', err);
          }
        }
      }
    }

    updateQuery += ' WHERE id = ?';
    params.push(userId);

    await db.run(updateQuery, params);

    const updatedUser = await db.get(
      'SELECT id, username, email, avatar_url, instagram_handle, habesha_status FROM users WHERE id = ?',
      [userId]
    );

    res.json({ user: updatedUser });
  } catch (error) {
    console.error('Update profile error:', error);
    if (req.file) {
      fs.unlinkSync(req.file.path);
    }
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

module.exports = router;
