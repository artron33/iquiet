from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.stats_service import get_today_stats, get_weekly_stats
from app.models.user import User
from app import db
from app.services.mongo_service import mongo_service

stats_bp = Blueprint('stats', __name__)

@stats_bp.route('/today', methods=['GET'])
@jwt_required()
def today_stats():
    email = get_jwt_identity()
    mongo_service.log_event('get_today_stats_request', {'user_email': email})
    user = User.query.filter_by(email=email).first()
    if not user:
        mongo_service.log_event('get_today_stats_failure', {'user_email': email, 'reason': 'user_not_found'})
        return jsonify(message='User not found'), 404
    stats = get_today_stats(user)
    return jsonify(stats), 200

@stats_bp.route('/weekly', methods=['GET'])
@jwt_required()
def weekly_stats():
    email = get_jwt_identity()
    mongo_service.log_event('get_weekly_stats_request', {'user_email': email})
    user = User.query.filter_by(email=email).first()
    if not user:
        mongo_service.log_event('get_weekly_stats_failure', {'user_email': email, 'reason': 'user_not_found'})
        return jsonify(message='User not found'), 404
    stats = get_weekly_stats(user)
    return jsonify(stats), 200
