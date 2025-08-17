import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import App from './App';

// Mock fetch for testing
global.fetch = jest.fn();

describe('App Component', () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  test('renders app title', () => {
    // Mock successful API response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ([]),
    });

    render(<App />);
    const titleElement = screen.getByText(/💡 Idea Board/i);
    expect(titleElement).toBeInTheDocument();
  });

  test('renders idea form elements', () => {
    // Mock successful API response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ([]),
    });

    render(<App />);
    
    const inputElement = screen.getByPlaceholderText(/Share your brilliant idea/i);
    expect(inputElement).toBeInTheDocument();
    
    const submitButton = screen.getByText(/✨ Submit Idea/i);
    expect(submitButton).toBeInTheDocument();
  });

  test('renders powered by cheetah footer', () => {
    // Mock successful API response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ([]),
    });

    render(<App />);
    
    const poweredByText = screen.getAllByText(/powered by/i);
    expect(poweredByText[0]).toBeInTheDocument();
    
    const cheetahText = screen.getAllByText(/cheetah/i);
    expect(cheetahText[0]).toBeInTheDocument();
    
    const cheetahLogo = screen.getByAltText(/Cheetah/i);
    expect(cheetahLogo).toBeInTheDocument();
  });

  test('displays ideas from API', async () => {
    // Mock successful API response with ideas
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ([
        { id: 1, content: "Test idea 1", created_at: "2024-01-01T00:00:00Z" },
        { id: 2, content: "Test idea 2", created_at: "2024-01-01T01:00:00Z" }
      ]),
    });

    render(<App />);

    await waitFor(() => {
      expect(screen.getByText("Test idea 1")).toBeInTheDocument();
    });
    
    await waitFor(() => {
      expect(screen.getByText("Test idea 2")).toBeInTheDocument();
    });
  });

  test('displays empty state when no ideas', async () => {
    // Mock successful API response with empty array
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ([]),
    });

    render(<App />);

    await waitFor(() => {
      expect(screen.getByText(/No ideas yet. Be the first to share one!/i)).toBeInTheDocument();
    });
  });

  test('handles API error gracefully', async () => {
    // Mock API error
    fetch.mockRejectedValueOnce(new Error('API Error'));

    render(<App />);

    await waitFor(() => {
      expect(screen.getByText(/Error: API Error/i)).toBeInTheDocument();
    });
  });

  test('submits new idea successfully', async () => {
    // Mock initial fetch
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ([]),
    });

    // Mock POST request
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({ id: 1, content: "New idea", created_at: "2024-01-01T00:00:00Z" }),
    });

    // Mock refetch after submit
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ([
        { id: 1, content: "New idea", created_at: "2024-01-01T00:00:00Z" }
      ]),
    });

    render(<App />);

    const inputElement = screen.getByPlaceholderText(/Share your brilliant idea/i);
    const submitButton = screen.getByText(/✨ Submit Idea/i);

    fireEvent.change(inputElement, { target: { value: 'New idea' } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith('/api/ideas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ content: 'New idea' })
      });
    });
  });

  test('displays loading state', () => {
    // Mock pending API call
    fetch.mockReturnValueOnce(new Promise(() => {}));

    render(<App />);
    
    expect(screen.getByText(/🔄 Loading ideas.../i)).toBeInTheDocument();
  });

  test('handles HTTP error status', async () => {
    // Mock HTTP error response
    fetch.mockResolvedValueOnce({
      ok: false,
      status: 500,
      json: async () => ({ error: 'Server error' }),
    });

    render(<App />);

    await waitFor(() => {
      expect(screen.getByText(/Error: HTTP error! status: 500/i)).toBeInTheDocument();
    });
  });

  test('prevents empty idea submission', async () => {
    // Mock successful API response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ([]),
    });

    render(<App />);

    const inputElement = screen.getByPlaceholderText(/Share your brilliant idea/i);
    const submitButton = screen.getByText(/✨ Submit Idea/i);

    // Try to submit empty idea
    fireEvent.change(inputElement, { target: { value: '   ' } }); // Just spaces
    fireEvent.click(submitButton);

    // Should not make POST request for empty content
    await waitFor(() => {
      expect(fetch).toHaveBeenCalledTimes(1); // Only initial fetch, no POST
    });
  });
});
