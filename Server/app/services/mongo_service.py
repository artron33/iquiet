import os
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure
from flask import current_app
from datetime import datetime

class MongoService:
    def __init__(self):
        self.client = None
        self.db = None

    def init_app(self, app):
        mongo_uri = app.config.get('MONGO_URI')
        if mongo_uri:
            try:
                self.client = MongoClient(mongo_uri)
                # The ismaster command is cheap and does not require auth.
                self.client.admin.command('ismaster')
                self.db = self.client.get_default_database()
                app.logger.info("MongoDB connection successful.")
            except ConnectionFailure as e:
                app.logger.error(f"Could not connect to MongoDB: {e}")
                self.client = None
                self.db = None
        else:
            app.logger.info("MONGO_URI not set, MongoDB logging disabled.")

    def log_event(self, event_type, data):
        if self.db is not None:
            try:
                collection = self.db['events']
                event_data = {
                    'event_type': event_type,
                    'data': data,
                    'timestamp': datetime.utcnow()
                }
                collection.insert_one(event_data)
            except Exception as e:
                current_app.logger.error(f"Failed to log event to MongoDB: {e}")

mongo_service = MongoService()

