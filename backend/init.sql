CREATE TABLE IF NOT EXISTS ideas (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add some sample data
INSERT INTO ideas (content, created_at) VALUES 
('Implement a user authentication system', NOW()),
('Add a search feature for ideas', NOW()),
('Create a mobile application', NOW()),
('Integrate with third-party services', NOW())
ON CONFLICT DO NOTHING;
