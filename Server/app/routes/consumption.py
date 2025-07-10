from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.extensions import db
from app.models.consumption import Consumption
from app.models.user import User
from app.services.mongo_service import mongo_service
from datetime import datetime, date, timedelta

consumption_bp = Blueprint('consumption', __name__)

@consumption_bp.route('', methods=['POST'])
@jwt_required()
def log_consumption():
    user_email = get_jwt_identity()
    mongo_service.log_event('log_consumption_request', {'user_email': user_email})
    data = request.get_json() or {}
    # Required fields
    substance = data.get('substance_type')
    quantity = data.get('quantity')
    unit = data.get('unit')
    cost = data.get('cost', 0.0)
    timestamp = data.get('timestamp')
    if not substance or quantity is None or not unit:
        return jsonify(message='Missing fields'), 400
    # parse timestamp if provided
    if timestamp:
        try:
            ts = datetime.fromisoformat(timestamp)
        except ValueError:
            return jsonify(message='Invalid timestamp'), 400
    else:
        ts = datetime.utcnow()
    # debug flag
    is_debug = current_app.config.get('DEBUG_FAKE_DATA') and user_email == 'debug@iquit.dev'
    entry = Consumption(user_id=None,  # will set user_id below
                        timestamp=ts,
                        substance_type=substance,
                        quantity=quantity,
                        unit=unit,
                        cost=cost,
                        notes=data.get('notes'),
                        is_debug=is_debug)
    # associate user by email
    user = User.query.filter_by(email=user_email).first()
    if not user:
        mongo_service.log_event('log_consumption_failure', {'user_email': user_email, 'reason': 'user_not_found'})
        return jsonify(message='User not found'), 404
    entry.user = user
    db.session.add(entry)
    db.session.commit()
    mongo_service.log_event('log_consumption_success', {'user_email': user_email, 'consumption_id': entry.id})
    return jsonify(id=entry.id), 201

@consumption_bp.route('/today', methods=['GET'])
@jwt_required()
def get_today():
    user_email = get_jwt_identity()
    mongo_service.log_event('get_today_consumption_request', {'user_email': user_email})
    today = date.today()
    start = datetime.combine(today, datetime.min.time())
    end = datetime.utcnow()
    entries = Consumption.query.join(Consumption.user).filter(
        User.email == user_email,
        Consumption.timestamp >= start,
        Consumption.timestamp <= end
    ).all()
    result = [
        {
            'id': e.id,
            'timestamp': e.timestamp.isoformat(),
            'substance_type': e.substance_type,
            'quantity': e.quantity,
            'unit': e.unit,
            'cost': e.cost,
            'notes': e.notes,
            'is_debug': e.is_debug
        }
        for e in entries
    ]
    return jsonify(result), 200

@consumption_bp.route('/weekly', methods=['GET'])
@jwt_required()
def get_weekly():
    user_email = get_jwt_identity()
    mongo_service.log_event('get_weekly_consumption_request', {'user_email': user_email})
    today = date.today()
    start_date = today - timedelta(days=6)
    # aggregate per day
    stats = []
    for i in range(7):
        day = start_date + timedelta(days=i)
        day_start = datetime.combine(day, datetime.min.time())
        day_end = datetime.combine(day, datetime.max.time())
        count = Consumption.query.join(Consumption.user).filter(
            User.email == user_email,
            Consumption.timestamp >= day_start,
            Consumption.timestamp <= day_end
        ).count()
        stats.append({'date': day.isoformat(), 'count': count})
    return jsonify(stats), 200
