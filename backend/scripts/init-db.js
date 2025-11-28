const db = require('../database/db');
const fs = require('fs');
const path = require('path');

async function initDatabase() {
  try {
    await db.connect();
    
    // Read and execute schema
    const schemaPath = path.join(__dirname, '../database/schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    // Execute each statement
    const statements = schema.split(';').filter(s => s.trim().length > 0);
    
    for (const statement of statements) {
      await db.run(statement);
    }
    
    console.log('Database initialized successfully!');
    await db.close();
    process.exit(0);
  } catch (error) {
    console.error('Error initializing database:', error);
    await db.close();
    process.exit(1);
  }
}

initDatabase();

