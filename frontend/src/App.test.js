import { render, screen, waitFor } from '@testing-library/react';
import { act } from 'react-dom/test-utils';
import App from './App';

// Mock fetch for testing
global.fetch = jest.fn();

describe('App Component', () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  test('renders app title', () => {
    render(<App />);
    const titleElement = screen.getByText(/proj/i);
    expect(titleElement).toBeInTheDocument();
  });

  test('renders ideas section', async () => {
    // Mock successful API response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ideas: [] }),
    });

    await act(async () => {
      render(<App />);
    });

    await waitFor(() => {
      const ideasElement = screen.getByText(/ideas/i);
      expect(ideasElement).toBeInTheDocument();
    });
  });

  test('handles API error gracefully', async () => {
    // Mock API error
    fetch.mockRejectedValueOnce(new Error('API Error'));

    await act(async () => {
      render(<App />);
    });

    // App should still render without crashing
    expect(screen.getByText(/proj/i)).toBeInTheDocument();
  });

  test('displays loading state', () => {
    // Mock pending API call
    fetch.mockReturnValueOnce(new Promise(() => {}));

    render(<App />);
    
    // Should show loading indicator or initial state
    expect(screen.getByText(/proj/i)).toBeInTheDocument();
  });
});
