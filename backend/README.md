# Diaspora Handbook Backend API

A Node.js/Express REST API backend for the Diaspora Handbook Flutter application.

## Features

- RESTful API for managing events
- SQLite database for data persistence
- CORS enabled for Flutter app integration
- Health check endpoint
- Query filtering (category, location, date range)

## Setup

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn

### Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
```

4. Initialize the database:
```bash
npm run init-db
```

5. Seed the database with initial events:
```bash
npm run seed
```

## Running the Server

### Development Mode (with auto-reload)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on `http://localhost:3000` by default.

## API Endpoints

### Health Check
- **GET** `/health`
  - Returns server status

### Events

- **GET** `/api/events`
  - Get all events
  - Query parameters:
    - `category` - Filter by category
    - `location` - Filter by location (partial match)
    - `startDate` - Filter events starting from this date (ISO 8601)
    - `endDate` - Filter events ending before this date (ISO 8601)
  - Example: `GET /api/events?category=Party&location=Addis`

- **GET** `/api/events/:id`
  - Get a single event by ID
  - Example: `GET /api/events/w3-1`

- **POST** `/api/events`
  - Create a new event
  - Request body:
    ```json
    {
      "id": "event-id",
      "title": "Event Title",
      "description": "Event description",
      "startTime": "2024-01-20T11:00:00.000Z",
      "endTime": "2024-01-20T23:00:00.000Z",
      "location": "Event Location",
      "category": "Party",
      "color": "#FFD700",
      "imageUrl": "https://example.com/image.jpg"
    }
    ```

- **PUT** `/api/events/:id`
  - Update an existing event
  - Request body: Same as POST (all fields optional)

- **DELETE** `/api/events/:id`
  - Delete an event

## Database Schema

### Events Table
- `id` (TEXT, PRIMARY KEY)
- `title` (TEXT, NOT NULL)
- `description` (TEXT)
- `start_time` (TEXT, NOT NULL) - ISO 8601 format
- `end_time` (TEXT, NOT NULL) - ISO 8601 format
- `location` (TEXT, NOT NULL)
- `category` (TEXT, NOT NULL)
- `color` (TEXT, NOT NULL) - Hex color code
- `image_url` (TEXT)
- `created_at` (TEXT)
- `updated_at` (TEXT)

## Configuration

Edit `.env` file to configure:

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `DB_PATH` - Path to SQLite database file

## Flutter App Integration

The Flutter app is configured to connect to `http://localhost:3000/api` by default.

For Android emulator, use: `http://10.0.2.2:3000/api`
For iOS simulator, use: `http://localhost:3000/api`
For physical devices, use your computer's IP address: `http://YOUR_IP:3000/api`

To change the API URL in the Flutter app, update `lib/services/api_service.dart`:

```dart
ApiService().setBaseUrl('http://your-api-url/api');
```

## Development

### Project Structure
```
backend/
├── database/
│   ├── db.js          # Database connection and utilities
│   └── schema.sql     # Database schema
├── routes/
│   └── events.js      # Event API routes
├── scripts/
│   ├── init-db.js     # Initialize database schema
│   └── seed-db.js     # Seed database with sample data
├── data/              # SQLite database files (gitignored)
├── server.js          # Main server file
├── package.json       # Dependencies and scripts
└── README.md          # This file
```

## Troubleshooting

### Database errors
- Make sure the `data` directory exists and is writable
- Run `npm run init-db` to recreate the database schema

### CORS issues
- CORS is enabled for all origins in development
- For production, update CORS settings in `server.js`

### Port already in use
- Change the `PORT` in `.env` file
- Or kill the process using port 3000

## License

ISC

