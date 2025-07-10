from flask import Flask
from flask_cors import CORS

from app.extensions import db, migrate, jwt, mongo_service


def create_app():
    app = Flask(__name__)
    app.config.from_object('app.config.Config')
    CORS(app)

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    mongo_service.init_app(app)

    # Register Blueprints
    from app.routes.auth import auth_bp
    from app.routes.user import user_bp
    from app.routes.consumption import consumption_bp
    from app.routes.stats import stats_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(user_bp, url_prefix='/user')
    app.register_blueprint(consumption_bp, url_prefix='/consumption')
    app.register_blueprint(stats_bp, url_prefix='/stats')

    return app
