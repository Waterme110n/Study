const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const app = express();
const port = 3000;

// PostgreSQL config
const config = {
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '1111',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'xyz',
  port: process.env.DB_PORT || 5432,
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000
};

const pool = new Pool(config);

// Database connection check
async function waitForDatabase() {
  let connected = false;
  let retries = 0;
  const maxRetries = 10;
  
  while (!connected && retries < maxRetries) {
    try {
      await pool.query('SELECT 1');
      console.log('Connected to PostgreSQL');
      connected = true;
    } catch (err) {
      retries++;
      console.log(`Waiting for PostgreSQL (attempt ${retries}/${maxRetries})...`);
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
  }
  
  if (!connected) {
    throw new Error('Could not connect to PostgreSQL');
  }
}

app.use(bodyParser.json());
app.use(express.static('public'));

// CORS
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'); 
  next();
});

// ================ GET Endpoints ================
app.get('/', (req, res) => res.sendFile(__dirname + '/index.html'));

app.get('/api/faculties', handleGet('SELECT * FROM faculty'));
app.get('/api/pulpits', handleGet('SELECT * FROM pulpit'));
app.get('/api/subjects', handleGet('SELECT * FROM subject'));
app.get('/api/auditoriumstypes', handleGet('SELECT * FROM auditorium_type'));
app.get('/api/auditoriums', handleGet('SELECT * FROM auditorium'));

function handleGet(query) {
  return async (req, res) => {
    try {
      const result = await pool.query(query);
      res.json(result.rows);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
}

// ================ POST Endpoints ================
app.post('/api/faculties', handlePost('faculty', ['faculty', 'faculty_name']));
app.post('/api/pulpits', handlePost('pulpit', ['pulpit', 'pulpit_name', 'faculty']));
app.post('/api/subjects', handlePost('subject', ['subject', 'subject_name', 'pulpit']));
app.post('/api/auditoriumstypes', handlePost('auditorium_type', ['auditorium_type', 'auditorium_yypername']));
app.post('/api/auditoriums', handlePost('auditorium', ['auditorium', 'auditorium_name', 'auditorium_capacity', 'auditorium_type']));

function handlePost(table, fields) {
  return async (req, res) => {
    try {
      const values = fields.map(f => req.body[f]);
      const placeholders = fields.map((_, i) => `$${i + 1}`).join(', ');
      const query = `INSERT INTO ${table} (${fields.join(', ')}) VALUES (${placeholders}) RETURNING *`;
      
      const result = await pool.query(query, values);
      res.status(201).json(result.rows[0]);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  };
}

// ================ PUT Endpoints ================
app.put('/api/faculties', handleUpdate('faculty', 'faculty'));
app.put('/api/pulpits', handleUpdate('pulpit', 'pulpit'));
app.put('/api/subjects', handleUpdate('subject', 'subject'));
app.put('/api/auditoriumstypes', handleUpdate('auditorium_type', 'auditorium_type'));
app.put('/api/auditoriums', handleUpdate('auditorium', 'auditorium'));

function handleUpdate(table, idField) {
  return async (req, res) => {
    try {
      const id = req.body[idField];
      const updates = [];
      const values = [];
      let index = 1;

      Object.entries(req.body).forEach(([key, val]) => {
        if (key !== idField) {
          updates.push(`${key} = $${index}`);
          values.push(val);
          index++;
        }
      });

      values.push(id);
      const query = `UPDATE ${table} SET ${updates.join(', ')} WHERE ${idField} = $${index} RETURNING *`;
      
      const result = await pool.query(query, values);
      res.json(result.rows[0]);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  };
}

// ================ DELETE Endpoints ================
app.delete('/api/faculties/:id', handleDelete('faculty'));
app.delete('/api/pulpits/:id', handleDelete('pulpit'));
app.delete('/api/subjects/:id', handleDelete('subject'));
app.delete('/api/auditoriumtypes/:id', handleDelete('auditorium_type'));
app.delete('/api/auditoriums/:id', handleDelete('auditorium'));

function handleDelete(table) {
  return async (req, res) => {
    try {
      const id = req.params.id;
      const query = `DELETE FROM ${table} WHERE ${table} = $1 RETURNING *`;
      const result = await pool.query(query, [id]);
      
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Not found' });
      }
      res.json({ 
        message: `${table} ${id} deleted`,
        deleted: result.rows[0]
      });
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  };
}

// Start server
waitForDatabase()
  .then(() => {
    app.listen(port, '0.0.0.0', () => {
      console.log(`Server running on port ${port}`);
    });
  })
  .catch(err => {
    console.error('Failed to start server:', err);
    process.exit(1);
  });