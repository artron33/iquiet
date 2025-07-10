#!/bin/bash
# Development environment setup script for IQUIT Flask app

echo "Setting up IQUIT Flask development environment..."

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed. Please install Python 3.8+ first."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Create development database if it doesn't exist
if [ ! -f "iquit_dev.db" ]; then
    echo "Creating development database..."
    python3 -c "
from app import create_app
from app.extensions import db
import os

os.environ['DATABASE_URI'] = 'sqlite:///iquit_dev.db'
os.environ['JWT_SECRET_KEY'] = 'dev-secret-key'
os.environ['DEBUG_FAKE_DATA'] = 'true'

app = create_app()
with app.app_context():
    db.create_all()
    print('Database created successfully!')
"
fi

echo "Development environment setup complete!"
echo "To start the server, run: python3 run_dev.py"
echo "The server will be available at: http://localhost:5002"
echo "Use email: debug@iquit.dev for testing"
