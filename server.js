const express = require('express');
const { exec } = require('child_process');
const { Client } = require('pg');

const app = express();
const PORT = 5000;

app.use(express.json());

const client = new Client({
  user: 'postgres',
  host: 'db',
  database: 'ansible',
  password: 'test123',
  port: 5432, // default PostgreSQL port
});

client.connect(err => {
  if (err) {
    console.error('Connection error', err.stack);
  } else {
    console.log('Connected to PostgreSQL');
  }
});

app.get('/', (req, res) => {
  res.json({ message: "Backend is running!", code: 0 });
});

app.get('/ansible-ping', (req, res) => {
  const command = `ansible -i ansible/inventory -m ping cisco_ios`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: stderr || error.message });
    }
    res.json({ stdout, code: 0 });
  });
});

app.get('/ansible-pb-info', (req, res) => {
  const command = `ansible-playbook ansible/info_ios.yml -i ansible/inventory`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: stderr || error.message });
    }
    res.json({ stdout, code: 0 });
  });
});

app.get('/db-check', async (req, res) => {
  try {
    const result = await client.query('SELECT NOW()');
    res.json({ message: 'Connected to PostgreSQL', time: result.rows.now, code: 0 });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/get-device', async (req, res) => {
  try {
    const result = await client.query('SELECT * FROM device');
    res.json({ devices: result.rows, code: 0 });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
