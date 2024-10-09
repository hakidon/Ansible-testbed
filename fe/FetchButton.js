import React, { useState } from 'react';

function FetchButton() {
  const [loading, setLoading] = useState(false);

  const handleClick = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:5000/ansible-pb-info');
      const data = await response.json();
      console.log(data);
    } catch (error) {
      console.error('Error fetching data:', error);
    }
    setLoading(false);
    window.location.reload();
  };

  return (
    <button onClick={handleClick} disabled={loading}>
      {loading ? 'Loading...' : 'Run Playbook'}
    </button>
  );
}

export default FetchButton;
