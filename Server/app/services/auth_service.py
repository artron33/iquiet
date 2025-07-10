from app.models.user import User
from app.extensions import db
from flask_jwt_extended import create_access_token
from flask import current_app


def signup_user(email, password):
    # Fake debug mode shortcut
    if current_app.config.get('DEBUG_FAKE_DATA') and email == 'debug@iquit.dev':
        token = create_access_token(identity=email)
        return token, 200
    if User.query.filter_by(email=email).first():
        return None, 409
    user = User(email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    token = create_access_token(identity=email)
    return token, 201


def login_user(email, password):
    # Fake debug mode shortcut
    if current_app.config.get('DEBUG_FAKE_DATA') and email == 'debug@iquit.dev':
        token = create_access_token(identity=email)
        return token, 200
    user = User.query.filter_by(email=email).first()
    if not user or not user.check_password(password):
        return None, 401
    token = create_access_token(identity=email)
    return token, 200
