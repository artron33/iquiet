# IQUIT Server Setup Guide

This guide will help you set up the IQUIT Flask backend server for development.

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)

## Quick Setup (Development Mode)

1. **Navigate to the Server directory:**
   ```bash
   cd /Users/pichane/Project/IQUIET/Server
   ```

2. **Run the setup script:**
   ```bash
   ./setup_dev.sh
   ```

3. **Start the development server:**
   ```bash
   python3 run_dev.py
   ```

The server will be available at `http://localhost:5002`.

## Manual Setup (Alternative)

If you prefer to set up manually:

1. **Create a virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Start the server:**
   ```bash
   python3 run_dev.py
   ```

## Testing the Connection

### Using the iOS App

1. Make sure your iOS simulator and development server are running
2. In the iOS app, try to log in with these test credentials:
   - Email: `debug@iquit.dev`
   - Password: `password123`

### Using curl (Terminal)

Test the registration endpoint:
```bash
curl -X POST http://localhost:5002/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123", "username": "testuser"}'
```

Test the login endpoint:
```bash
curl -X POST http://localhost:5002/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "debug@iquit.dev", "password": "password123"}'
```

## API Endpoints

The server provides the following endpoints:

### Authentication
- `POST /auth/register` - Register a new user
- `POST /auth/login` - Login user

### User Management
- `GET /user/profile` - Get user profile (requires authentication)
- `PUT /user/profile` - Update user profile (requires authentication)

### Consumption Tracking
- `POST /consumption` - Log consumption (requires authentication)
- `GET /consumption/today` - Get today's consumption (requires authentication)
- `GET /consumption/weekly` - Get weekly consumption stats (requires authentication)

### Statistics
- `GET /stats/today` - Get today's statistics (requires authentication)
- `GET /stats/weekly` - Get weekly statistics (requires authentication)

## Debug Mode

The server includes a debug mode that allows testing without a real database:

- Use email: `debug@iquit.dev` with any password
- This will bypass normal authentication and database operations
- Perfect for testing the iOS app connection

## Configuration

The development server uses these settings:
- Port: 5002
- Database: SQLite (iquit_dev.db)
- Debug mode: Enabled
- CORS: Enabled for all origins
- JWT Secret: dev-secret-key

## Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   lsof -ti:5002 | xargs kill
   ```

2. **Module import errors:**
   - Make sure you're in the virtual environment
   - Reinstall requirements: `pip install -r requirements.txt`

3. **Database errors:**
   - Delete the database file: `rm iquit_dev.db`
   - Restart the server to recreate it

### iOS App Connection Issues

Make sure the iOS app is configured to connect to the correct URL:
- The AuthClient should use `http://localhost:5002` (not 5000)
- The simulator should be able to access localhost

## Production Deployment

For production deployment, use Docker:

```bash
docker-compose up -d
```

This will start:
- Flask backend on port 5002
- PostgreSQL database
- MongoDB for logging
- RabbitMQ for background tasks
