from flask import Blueprint, request, jsonify, current_app
from app.extensions import db
from app.models.user import User
from flask_jwt_extended import create_access_token
from app.services.mongo_service import mongo_service

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    email = data.get('email')
    password = data.get('password')
    username = data.get('username')

    if mongo_service:
        mongo_service.log_event('register_attempt', {'email': email, 'username': username})

    if not email or not password or not username:
        return jsonify(message='Missing email, password, or username'), 400
    if User.query.filter_by(email=email).first() or User.query.filter_by(username=username).first():
        return jsonify(message='User with this email or username already exists'), 409
    # Debug fake mode
    if current_app.config.get('DEBUG_FAKE_DATA') and email == 'debug@iquit.dev':
        # create or skip persistence
        token = create_access_token(identity=email)
        if mongo_service:
            mongo_service.log_event('register_success_debug', {'email': email})
        return jsonify(token=token), 200
    user = User(email=email, username=username)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    token = create_access_token(identity=email)

    if mongo_service:
        mongo_service.log_event('register_success', {'email': email, 'user_id': user.id})

    return jsonify(token=token), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    email = data.get('email')
    password = data.get('password')

    if mongo_service:
        mongo_service.log_event('login_attempt', {'email': email})

    if not email or not password:
        return jsonify(message='Missing email or password'), 400
    # Debug fake mode
    if current_app.config.get('DEBUG_FAKE_DATA') and email == 'debug@iquit.dev':
        token = create_access_token(identity=email)
        if mongo_service:
            mongo_service.log_event('login_success_debug', {'email': email})
        return jsonify(token=token), 200
    user = User.query.filter_by(email=email).first()
    if not user or not user.check_password(password):
        if mongo_service:
            mongo_service.log_event('login_failed', {'email': email})
        return jsonify(message='Invalid credentials'), 401
    token = create_access_token(identity=email)
    if mongo_service:
        mongo_service.log_event('login_success', {'email': email, 'user_id': user.id})
    return jsonify(token=token), 200
