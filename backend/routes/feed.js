const express = require('express');
const router = express.Router();
const db = require('../database/db');
const jwt = require('jsonwebtoken');

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

// GET all posts
router.get('/', async (req, res) => {
  try {
    // If user is logged in, we want to know if they liked the posts
    let currentUserId = null;
    if (req.headers.authorization) {
        try {
            const token = req.headers.authorization.split(' ')[1];
            const decoded = jwt.verify(token, JWT_SECRET);
            currentUserId = decoded.id;
        } catch (e) {
            // Ignore invalid token for public feed view (or enforce auth)
        }
    }

    const posts = await db.all(`
      SELECT 
        p.id, 
        p.content, 
        p.image_url, 
        p.created_at, 
        p.likes_count,
        u.id as user_id, 
        u.username, 
        u.avatar_url,
        CASE WHEN pl.user_id IS NOT NULL THEN 1 ELSE 0 END as is_liked
      FROM posts p
      JOIN users u ON p.user_id = u.id
      LEFT JOIN post_likes pl ON p.id = pl.post_id AND pl.user_id = ?
      ORDER BY p.created_at DESC
      LIMIT 50
    `, [currentUserId]);

    res.json(posts);
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
});

// CREATE a post
router.post('/', authenticate, async (req, res) => {
  try {
    const { content, imageUrl } = req.body;
    
    if (!content && !imageUrl) {
      return res.status(400).json({ error: 'Post must have content or image' });
    }

    const postId = `post_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const userId = req.user.id;

    await db.run(
      'INSERT INTO posts (id, user_id, content, image_url) VALUES (?, ?, ?, ?)',
      [postId, userId, content, imageUrl]
    );

    // Return the created post with user info
    const post = await db.get(`
      SELECT 
        p.id, 
        p.content, 
        p.image_url, 
        p.created_at, 
        p.likes_count,
        u.id as user_id, 
        u.username, 
        u.avatar_url,
        0 as is_liked
      FROM posts p
      JOIN users u ON p.user_id = u.id
      WHERE p.id = ?
    `, [postId]);

    res.status(201).json(post);
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ error: 'Failed to create post' });
  }
});

// LIKE/UNLIKE a post
router.post('/:id/like', authenticate, async (req, res) => {
  try {
    const postId = req.params.id;
    const userId = req.user.id;

    // Check if already liked
    const existingLike = await db.get(
      'SELECT id FROM post_likes WHERE post_id = ? AND user_id = ?',
      [postId, userId]
    );

    if (existingLike) {
      // Unlike
      await db.run('DELETE FROM post_likes WHERE post_id = ? AND user_id = ?', [postId, userId]);
      await db.run('UPDATE posts SET likes_count = likes_count - 1 WHERE id = ?', [postId]);
      res.json({ liked: false });
    } else {
      // Like
      await db.run('INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)', [postId, userId]);
      await db.run('UPDATE posts SET likes_count = likes_count + 1 WHERE id = ?', [postId]);
      res.json({ liked: true });
    }
  } catch (error) {
    console.error('Error toggling like:', error);
    res.status(500).json({ error: 'Failed to toggle like' });
  }
});

// DELETE a post
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const postId = req.params.id;
    const userId = req.user.id;

    const post = await db.get('SELECT user_id FROM posts WHERE id = ?', [postId]);

    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    if (post.user_id !== userId) {
      return res.status(403).json({ error: 'Not authorized to delete this post' });
    }

    await db.run('DELETE FROM posts WHERE id = ?', [postId]);
    res.json({ message: 'Post deleted' });
  } catch (error) {
    console.error('Error deleting post:', error);
    res.status(500).json({ error: 'Failed to delete post' });
  }
});

module.exports = router;

