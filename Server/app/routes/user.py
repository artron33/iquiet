from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.user import User
from app.extensions import db
from app.services.mongo_service import mongo_service

user_bp = Blueprint('user', __name__)

@user_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    email = get_jwt_identity()
    mongo_service.log_event('get_profile_request', {'user_email': email})
    user = User.query.filter_by(email=email).first()
    if not user:
        mongo_service.log_event('get_profile_failure', {'user_email': email, 'reason': 'user_not_found'})
        return jsonify(message='User not found'), 404
    return jsonify(
        email=user.email,
        created_at=user.created_at.isoformat()
    ), 200

@user_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    current_user_email = get_jwt_identity()
    user = User.query.filter_by(email=current_user_email).first_or_404()
    data = request.get_json()
    if 'username' in data:
        user.username = data['username']
    if 'email' in data:
        user.email = data['email']
    db.session.commit()
    return jsonify(message='Profile updated successfully'), 200
