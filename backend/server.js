const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');
const db = require('./database/db');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
// Serve uploaded files statically
app.use('/uploads', express.static('uploads'));

// Routes
const authRouter = require('./routes/auth');
app.use('/api/auth', authRouter);

const feedRouter = require('./routes/feed');
app.use('/api/feed', feedRouter);

const eventsRouter = require('./routes/events');
app.use('/api/events', eventsRouter);

const chatRouter = require('./routes/chat');
app.use('/api/chat', chatRouter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Diaspora Handbook API is running' });
});

// Socket.io connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Join a channel
  socket.on('join_channel', (channelId) => {
    socket.join(channelId);
    console.log(`User ${socket.id} joined channel ${channelId}`);
  });

  // Leave a channel
  socket.on('leave_channel', (channelId) => {
    socket.leave(channelId);
    console.log(`User ${socket.id} left channel ${channelId}`);
  });

  // Handle new message
  socket.on('send_message', async (data) => {
    try {
      const { channelId, userId, username, content, messageType = 'text' } = data;
      
      // Save message to database
      const messageId = `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      
      // Use CURRENT_TIMESTAMP for cross-database compatibility (SQLite + Postgres)
      await db.run(
        `INSERT INTO messages (id, channel_id, user_id, username, content, message_type, created_at)
         VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)`,
        [messageId, channelId, userId, username, content, messageType]
      );

      // Get the saved message
      const message = await db.get('SELECT * FROM messages WHERE id = ?', [messageId]);

      // Broadcast to all users in the channel
      io.to(channelId).emit('new_message', message);
    } catch (error) {
      console.error('Error sending message:', error);
      socket.emit('error', { message: 'Failed to send message' });
    }
  });

  // User typing indicator
  socket.on('typing', (data) => {
    socket.to(data.channelId).emit('user_typing', {
      userId: data.userId,
      username: data.username
    });
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Make io accessible to routes
app.set('io', io);

// Initialize database and start server
async function startServer() {
  try {
    await db.connect();
    
    // Initialize database schema if needed
    // Skip auto-init for Postgres (Production) - User should run schema_pg.sql manually
    if (!db.isPostgres) {
      const fs = require('fs');
      const path = require('path');
      const schemaPath = path.join(__dirname, 'database/schema.sql');
      
      if (fs.existsSync(schemaPath)) {
        const schema = fs.readFileSync(schemaPath, 'utf8');
        const statements = schema.split(';').filter(s => s.trim().length > 0);
        
        for (const statement of statements) {
          try {
            await db.run(statement);
          } catch (err) {
            // Ignore errors for existing tables/indexes
            if (!err.message.includes('already exists')) {
              console.warn('Schema initialization warning:', err.message);
            }
          }
        }
      }
    }
    
    server.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`📊 Health check: http://localhost:${PORT}/health`);
      console.log(`📅 Events API: http://localhost:${PORT}/api/events`);
      console.log(`💬 Chat API: http://localhost:${PORT}/api/chat`);
      console.log(`🔌 WebSocket server running`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\nShutting down gracefully...');
  await db.close();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('\nShutting down gracefully...');
  await db.close();
  process.exit(0);
});

startServer();

