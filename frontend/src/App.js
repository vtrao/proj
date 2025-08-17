import './App.css';
import cheetahLogo from './cheetah-logo.svg';

import React, { useState, useEffect } from 'react';

function App() {
  const [ideas, setIdeas] = useState([]);
  const [newIdea, setNewIdea] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchIdeas();
  }, []);

  const fetchIdeas = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch('/api/ideas');
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      setIdeas(data);
    } catch (err) {
      setError(err.message);
      console.error('Error fetching ideas:', err);
    } finally {
      setLoading(false);
    }
  };

  const submitIdea = async (e) => {
    e.preventDefault();
    if (!newIdea.trim()) return;

    try {
      const response = await fetch('/api/ideas', {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ content: newIdea.trim() })
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      setNewIdea('');
      await fetchIdeas(); // Refresh the list
    } catch (err) {
      setError(err.message);
      console.error('Error submitting idea:', err);
    }
  };

  return (
    <div className="app-container">
      <div className="main-content">
        <div className="idea-board">
          <h1>💡 Idea Board</h1>
          
          <form onSubmit={submitIdea} className="idea-form">
            <input
              className="idea-input"
              value={newIdea}
              onChange={e => setNewIdea(e.target.value)}
              placeholder="Share your brilliant idea..."
              required
              maxLength={500}
            />
            <button type="submit" className="submit-button">
              ✨ Submit Idea
            </button>
          </form>

          {error && (
            <div style={{ 
              color: 'red', 
              padding: '10px', 
              background: '#ffebee', 
              borderRadius: '8px',
              margin: '10px 0'
            }}>
              Error: {error}
            </div>
          )}

          {loading ? (
            <div style={{ 
              padding: '20px', 
              color: '#666',
              fontSize: '16px'
            }}>
              🔄 Loading ideas...
            </div>
          ) : (
            <ul className="ideas-list">
              {ideas.length === 0 ? (
                <li style={{ 
                  textAlign: 'center', 
                  color: '#888', 
                  padding: '40px',
                  fontSize: '16px'
                }}>
                  🌟 No ideas yet. Be the first to share one!
                </li>
              ) : (
                ideas.map(idea => (
                  <li key={idea.id} className="idea-item">
                    <div className="idea-content">{idea.content}</div>
                    <small className="idea-timestamp">
                      📅 {new Date(idea.created_at).toLocaleString()}
                    </small>
                  </li>
                ))
              )}
            </ul>
          )}
        </div>
      </div>
      
      {/* Powered by Cheetah footer */}
      <div className="cheetah-footer">
        <span className="cheetah-text">powered by</span>
        <img 
          src={cheetahLogo} 
          alt="Cheetah" 
          className="cheetah-logo"
        />
        <span className="cheetah-text">cheetah</span>
      </div>
    </div>
  );
}

export default App;

