const sqlite3 = require('sqlite3').verbose();
const { Pool } = require('pg');
const path = require('path');
require('dotenv').config();

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '../data/diaspora_handbook.db');
const IS_POSTGRES = !!process.env.DATABASE_URL;

class Database {
  constructor() {
    this.db = null;
    this.isPostgres = IS_POSTGRES;
  }

  connect() {
    return new Promise((resolve, reject) => {
      if (this.isPostgres) {
        console.log('Connecting to PostgreSQL...');
        this.db = new Pool({
          connectionString: process.env.DATABASE_URL,
          ssl: {
            rejectUnauthorized: false // Required for some providers like Heroku/Render
          }
        });
        // Test connection
        this.db.query('SELECT NOW()', (err, res) => {
          if (err) {
            console.error('Error connecting to PostgreSQL:', err);
            reject(err);
          } else {
            console.log('Connected to PostgreSQL');
            resolve();
          }
        });
      } else {
        // SQLite Fallback
        const fs = require('fs');
        const dataDir = path.dirname(DB_PATH);
        if (!fs.existsSync(dataDir)) {
          fs.mkdirSync(dataDir, { recursive: true });
        }

        this.db = new sqlite3.Database(DB_PATH, (err) => {
          if (err) {
            console.error('Error opening SQLite database:', err);
            reject(err);
          } else {
            console.log('Connected to SQLite database');
            resolve();
          }
        });
      }
    });
  }

  close() {
    return new Promise((resolve, reject) => {
      if (this.db) {
        if (this.isPostgres) {
          this.db.end().then(resolve).catch(reject);
        } else {
          this.db.close((err) => {
            if (err) reject(err);
            else {
              console.log('Database connection closed');
              resolve();
            }
          });
        }
      } else {
        resolve();
      }
    });
  }

  // Helper to convert SQL from SQLite (?) to Postgres ($1, $2...)
  _convertSql(sql) {
    if (!this.isPostgres) return sql;
    let i = 1;
    return sql.replace(/\?/g, () => `$${i++}`);
  }

  run(sql, params = []) {
    return new Promise((resolve, reject) => {
      if (this.isPostgres) {
        const pgSql = this._convertSql(sql);
        this.db.query(pgSql, params, (err, result) => {
          if (err) reject(err);
          else {
            // Simulate SQLite's 'changes' and 'lastID'
            // Note: lastID is tricky in PG without RETURNING, so we default to null
            // If logic depends on lastID, we need to modify the query to use RETURNING
            resolve({ lastID: null, changes: result.rowCount });
          }
        });
      } else {
        this.db.run(sql, params, function(err) {
          if (err) reject(err);
          else resolve({ lastID: this.lastID, changes: this.changes });
        });
      }
    });
  }

  get(sql, params = []) {
    return new Promise((resolve, reject) => {
      if (this.isPostgres) {
        const pgSql = this._convertSql(sql);
        this.db.query(pgSql, params, (err, result) => {
          if (err) reject(err);
          else resolve(result.rows[0]);
        });
      } else {
        this.db.get(sql, params, (err, row) => {
          if (err) reject(err);
          else resolve(row);
        });
      }
    });
  }

  all(sql, params = []) {
    return new Promise((resolve, reject) => {
      if (this.isPostgres) {
        const pgSql = this._convertSql(sql);
        this.db.query(pgSql, params, (err, result) => {
          if (err) reject(err);
          else resolve(result.rows);
        });
      } else {
        this.db.all(sql, params, (err, rows) => {
          if (err) reject(err);
          else resolve(rows);
        });
      }
    });
  }
}

const db = new Database();
module.exports = db;
