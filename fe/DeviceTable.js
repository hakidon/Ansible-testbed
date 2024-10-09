import React, { useEffect, useState } from 'react';
import './DeviceTable.css'; // Import the CSS file

function DeviceTable() {
  const [devices, setDevices] = useState([]);

  useEffect(() => {
    fetch('http://localhost:5000/get-device')
      .then(response => response.json())
      .then(data => setDevices(data.devices))
      .catch(error => console.error('Error fetching data:', error));
  }, []);

  return (
    <div>
      <h1>Device List</h1>
      <table>
        <thead>
          <tr>
            <th>Device SN</th>
            <th>Hostname</th>
            <th>IP</th>
            <th>OS Version</th>
            <th>Hardware Model</th>
            <th>Uptime</th>
            <th>CPU Consumption (%)</th>
            <th>Memory Consumption (%)</th>
          </tr>
        </thead>
        <tbody>
          {devices.map(device => (
            <tr key={device.device_sn}>
              <td>{device.device_sn}</td>
              <td>{device.hostname}</td>
              <td>{device.ip}</td>
              <td>{device.os_version}</td>
              <td>{device.hardware_model}</td>
              <td>{device.uptime}</td>
              <td>{device.cpu_consumption}</td>
              <td>{device.memory_consumption}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default DeviceTable;