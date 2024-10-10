import React, { useState } from 'react';
import './FetchButton.css'; // Make sure to import the CSS

function FetchButton() {
  const [loading, setLoading] = useState(false);
  
  const handleClick = async () => {
    setLoading(true);
    document.getElementById('loading-popup').classList.add('active'); // Show loading popup
    try {
      const response = await fetch('http://localhost:5000/ansible-pb-info');
      const data = await response.json();
      console.log(data);
    } catch (error) {
      console.error('Error fetching data:', error);
    }
    setLoading(false);
    document.getElementById('loading-popup').classList.remove('active'); // Hide loading popup
    window.location.reload();
  };

  return (
    <>
      <button id="fetch-button" onClick={handleClick} disabled={loading}>
        {loading ? 'Loading...' : 'Run Playbook'}
      </button>
      <div id="loading-popup" className="loading-popup">
        Script is running, please wait...
      </div>
    </>
  );
}

export default FetchButton;