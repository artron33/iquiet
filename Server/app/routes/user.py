from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.user import User

user_bp = Blueprint('user', __name__)

@user_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    email = get_jwt_identity()
    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify(message='User not found'), 404
    return jsonify(
        email=user.email,
        created_at=user.created_at.isoformat()
    ), 200

@user_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    # TODO: implement profile update fields
    return jsonify(message='Not implemented'), 501
