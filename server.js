const express = require('express');
const { exec } = require('child_process');

const app = express();
const PORT = 5000;

app.use(express.json());

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

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});