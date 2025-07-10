#!/usr/bin/env python3
"""
Development server runner for IQUIT Flask app
This script starts the Flask server for local development without Docker
"""

import os
from app import create_app

if __name__ == '__main__':
    # Set development environment variables
    os.environ['FLASK_ENV'] = 'development'
    os.environ['DEBUG_FAKE_DATA'] = 'true'
    
    # Use SQLite for development instead of PostgreSQL
    os.environ['DATABASE_URI'] = 'sqlite:///iquit_dev.db'
    
    # JWT secret key for development
    os.environ['JWT_SECRET_KEY'] = 'dev-secret-key'
    
    # Create the Flask app
    app = create_app()
    
    # Import models to ensure they're registered
    from app.models.user import User
    from app.models.consumption import Consumption
    
    # Create tables if they don't exist
    with app.app_context():
        from app.extensions import db
        db.create_all()
        print("Database tables created successfully!")
    
    # Run the development server
    print("Starting IQUIT Flask development server...")
    print("Server will be available at: http://localhost:5002")
    print("Debug mode enabled - use debug@iquit.dev for testing")
    
    app.run(host='0.0.0.0', port=5002, debug=True)
