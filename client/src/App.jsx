import { useState, useEffect } from 'react';
import './App.css';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

function App() {
  const [backendData, setBackendData] = useState(null);
  const [healthStatus, setHealthStatus] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const fetchHealth = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/health`);
      if (!response.ok) throw new Error('Health check failed');
      const data = await response.json();
      setHealthStatus(data);
      setError(null);
    } catch (err) {
      setError('Backend connection failed');
      setHealthStatus(null);
    }
  };

  const fetchData = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_BASE_URL}/api/data`);
      if (!response.ok) throw new Error('Failed to fetch data');
      const data = await response.json();
      setBackendData(data);
    } catch (err) {
      setError(err.message || 'Failed to connect to backend');
      setBackendData(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHealth();
    fetchData();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>Full Stack Application</h1>
        <p className="subtitle">Vite + React Frontend | Node.js + Express Backend</p>
        
        <div className="status-container">
          {healthStatus && (
            <div className="status-badge success">
              <span className="status-dot"></span>
              Backend Connected
            </div>
          )}
          {error && (
            <div className="status-badge error">
              <span className="status-dot"></span>
              {error}
            </div>
          )}
        </div>

        <div className="card">
          <div className="card-header">
            <h2>API Integration Test</h2>
            <p>Test the connection between frontend and backend</p>
          </div>

          <button 
            onClick={fetchData} 
            disabled={loading}
            className="primary-button"
          >
            {loading ? 'Loading...' : 'Fetch Data from API'}
          </button>

          {backendData && (
            <div className="data-display">
              <h3>API Response</h3>
              <pre>{JSON.stringify(backendData, null, 2)}</pre>
            </div>
          )}

          {error && backendData === null && (
            <div className="error-display">
              <p>⚠️ {error}</p>
              <p className="error-hint">Make sure the API server is running on port 5000</p>
            </div>
          )}
        </div>

        <div className="info-section">
          <div className="info-item">
            <strong>Frontend:</strong> Port 5173
          </div>
          <div className="info-item">
            <strong>Backend:</strong> Port 5000
          </div>
          <div className="info-item">
            <strong>Status:</strong> {healthStatus ? 'Connected' : 'Disconnected'}
          </div>
        </div>
      </header>
    </div>
  );
}

export default App;

