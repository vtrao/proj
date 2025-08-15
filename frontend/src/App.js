import logo from './logo.svg';
import './App.css';

import React, { useState, useEffect } from 'react';

function App() {
  const [ideas, setIdeas] = useState([]);
  const [newIdea, setNewIdea] = useState("");

  useEffect(() => {
    fetch('/api/ideas')
      .then(res => res.json())
      .then(setIdeas);
  }, []);

  const submitIdea = async (e) => {
    e.preventDefault();
    await fetch('/api/ideas', {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ content: newIdea })
    });
    setNewIdea('');
    fetch('/api/ideas')
      .then(res => res.json())
      .then(setIdeas);
  };

  return (
    <div>
      <h1>Idea Board</h1>
      <form onSubmit={submitIdea}>
        <input
          value={newIdea}
          onChange={e => setNewIdea(e.target.value)}
          placeholder="Type your idea"
          required
        />
        <button type="submit">Submit</button>
      </form>
      <ul>
        {ideas.map(idea => (
          <li key={idea.id}>{idea.content} <small>{new Date(idea.created_at).toLocaleString()}</small></li>
        ))}
      </ul>
    </div>
  )
}

export default App;

