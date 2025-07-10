from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.stats_service import get_today_stats, get_weekly_stats
from app.models.user import User
from app import db

stats_bp = Blueprint('stats', __name__)

@stats_bp.route('/today', methods=['GET'])
@jwt_required()
def today_stats():
    email = get_jwt_identity()
    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify(message='User not found'), 404
    stats = get_today_stats(user)
    return jsonify(stats), 200

@stats_bp.route('/weekly', methods=['GET'])
@jwt_required()
def weekly_stats():
    email = get_jwt_identity()
    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify(message='User not found'), 404
    stats = get_weekly_stats(user)
    return jsonify(stats), 200
