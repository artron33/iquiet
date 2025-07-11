from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from app.services.mongo_service import MongoService

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
mongo_service = MongoService()
