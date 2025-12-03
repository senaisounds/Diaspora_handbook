const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { Server } = require('socket.io');
const db = require('./database/db');
require('dotenv').config();

// Initialize Sentry for error tracking (optional - only if SENTRY_DSN is set)
let Sentry;
if (process.env.SENTRY_DSN) {
  Sentry = require('@sentry/node');
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV || 'development',
    tracesSampleRate: 1.0, // Capture 100% of transactions for performance monitoring
  });
}

const app = express();
const server = http.createServer(app);

// Environment configuration
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';
const ALLOWED_ORIGINS = process.env.ALLOWED_ORIGINS 
  ? process.env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim())
  : (NODE_ENV === 'production' ? [] : '*');

// Socket.io configuration with CORS
const io = new Server(server, {
  cors: {
    origin: ALLOWED_ORIGINS === '*' ? '*' : ALLOWED_ORIGINS,
    methods: ['GET', 'POST'],
    credentials: true
  }
});

// Security middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }, // Allow static file serving
  contentSecurityPolicy: false // Disable CSP for API (can be configured per route if needed)
}));

// Compression middleware
app.use(compression());

// Request logging
if (NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    if (ALLOWED_ORIGINS === '*' || ALLOWED_ORIGINS.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};
app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute (reduced from 15 min)
  max: NODE_ENV === 'production' ? 300 : 1000, // Increased to 300 requests per minute (5 requests per second)
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

// Body parsing middleware with size limits
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Serve uploaded files statically
app.use('/uploads', express.static('uploads'));

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    name: 'Diaspora Handbook API',
    status: 'running',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      auth: '/api/auth',
      feed: '/api/feed',
      events: '/api/events',
      chat: '/api/chat'
    },
    environment: NODE_ENV,
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint (excluded from rate limiting - must be before limiter)
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Diaspora Handbook API is running',
    environment: NODE_ENV,
    timestamp: new Date().toISOString()
  });
});

// Routes (protected by rate limiting)
const authRouter = require('./routes/auth');
app.use('/api/auth', authRouter);

const feedRouter = require('./routes/feed');
app.use('/api/feed', feedRouter);

const eventsRouter = require('./routes/events');
app.use('/api/events', eventsRouter);

const chatRouter = require('./routes/chat');
app.use('/api/chat', chatRouter);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    error: 'Not Found',
    message: `Cannot ${req.method} ${req.path}`
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  // Send to Sentry if configured
  if (Sentry) {
    Sentry.captureException(err);
  }
  
  // CORS error
  if (err.message === 'Not allowed by CORS') {
    return res.status(403).json({ 
      error: 'Forbidden',
      message: 'Origin not allowed by CORS policy'
    });
  }
  
  // Default error
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error',
    ...(NODE_ENV === 'development' && { stack: err.stack })
  });
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

// Validate required environment variables
function validateEnv() {
  const required = [];
  const warnings = [];
  
  // JWT_SECRET warning (not required for development, but should be set in production)
  if (NODE_ENV === 'production' && (!process.env.JWT_SECRET || process.env.JWT_SECRET === 'diaspora_handbook_secret_key_2025')) {
    warnings.push('⚠️  WARNING: JWT_SECRET is using default value. This is insecure for production!');
  }
  
  if (warnings.length > 0) {
    console.warn('\n' + warnings.join('\n') + '\n');
  }
  
  if (required.length > 0) {
    console.error('❌ Missing required environment variables:', required.join(', '));
    process.exit(1);
  }
}

// Initialize database and start server
async function startServer() {
  try {
    // Validate environment
    validateEnv();
    
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
  if (Sentry) {
    await Sentry.close(2000); // Wait up to 2 seconds for Sentry to flush
  }
  await db.close();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('\nShutting down gracefully...');
  if (Sentry) {
    await Sentry.close(2000); // Wait up to 2 seconds for Sentry to flush
  }
  await db.close();
  process.exit(0);
});

startServer();

