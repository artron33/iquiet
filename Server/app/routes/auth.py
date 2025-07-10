from flask import Blueprint, request, jsonify, current_app
auth_bp = Blueprint('auth', __name__)
from app import db
from app.models.user import User
from flask_jwt_extended import create_access_token

@auth_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json() or {}
    email = data.get('email')
    password = data.get('password')
    if not email or not password:
        return jsonify(message='Missing email or password'), 400
    if User.query.filter_by(email=email).first():
        return jsonify(message='User already exists'), 409
    # Debug fake mode
    if current_app.config.get('DEBUG_FAKE_DATA') and email == 'debug@iquit.dev':
        # create or skip persistence
        token = create_access_token(identity=email)
        return jsonify(token=token), 200
    user = User(email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    token = create_access_token(identity=email)
    return jsonify(token=token), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    email = data.get('email')
    password = data.get('password')
    if not email or not password:
        return jsonify(message='Missing email or password'), 400
    # Debug fake mode
    if current_app.config.get('DEBUG_FAKE_DATA') and email == 'debug@iquit.dev':
        token = create_access_token(identity=email)
        return jsonify(token=token), 200
    user = User.query.filter_by(email=email).first()
    if not user or not user.check_password(password):
        return jsonify(message='Invalid credentials'), 401
    token = create_access_token(identity=email)
    return jsonify(token=token), 200
