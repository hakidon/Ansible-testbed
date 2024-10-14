const express = require('express');
const cors = require('cors'); 
const { exec } = require('child_process');
const { Pool } = require('pg'); // Correct import

const app = express();
const PORT = 5000;

app.use(cors()); // Use the cors middleware
app.use(express.json());

function parseLogToJson(log) {
  const jsonMatch = log.match(/"msg": "(.*)"/);
  
  if (jsonMatch && jsonMatch) {
      const jsonString = jsonMatch.replace(/\\"/g, '"');
      
      try {
          return JSON.parse(jsonString);
      } catch (error) {
          console.error('Failed to parse JSON:', error);
      }
  } else {
      console.error('No JSON found in the log.');
  }
  return null;
}

const pool = new Pool({
  user: 'postgres',
  host: 'db',           // Replace with your actual DB host
  database: 'ansible',
  password: 'test123',
  port: 5432,           // Default PostgreSQL port
  max: 10,              // Max number of clients in the pool
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  connectionTimeoutMillis: 2000, // Return an error after 2 seconds if no connection
});

// Exponential backoff retry logic
const retryWithExponentialBackoff = async (fn, retries = 5, delay = 1000) => {
  let attempts = 0;
  
  while (attempts < retries) {
    try {
      return await fn(); // Try executing the function
    } catch (error) {
      attempts++;
      console.error(`Attempt ${attempts} failed: ${error.message}`);

      if (attempts < retries) {
        const retryDelay = delay * Math.pow(2, attempts); // Exponential backoff
        console.log(`Retrying in ${retryDelay / 1000} seconds...`);
        await new Promise(res => setTimeout(res, retryDelay)); // Wait for the delay
      } else {
        console.error('Max retry attempts reached.');
        throw error; // Re-throw the error after max retries
      }
    }
  }
};

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
    const result = await pool.query('SELECT NOW()'); // Use pool instead of client
    res.json({ message: 'Connected to PostgreSQL', time: result.rows.now, code: 0 });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/get-device', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM device'); // Use pool instead of client
    res.json({ devices: result.rows, code: 0 });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});