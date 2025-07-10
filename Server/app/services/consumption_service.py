from datetime import datetime, date, timedelta
from app.models.consumption import Consumption
from sqlalchemy import func
from app.extensions import db


def log_consumption(user, payload):
    """
    Logs a consumption record for the given user.
    payload: dict with keys substance_type, quantity, unit, cost, notes, timestamp (optional)
    """
    ts = payload.get('timestamp')
    if ts:
        ts = datetime.fromisoformat(ts)
    else:
        ts = datetime.utcnow()
    entry = Consumption(
        user_id=user.id,
        timestamp=ts,
        substance_type=payload['substance_type'],
        quantity=payload['quantity'],
        unit=payload['unit'],
        cost=payload.get('cost', 0.0),
        notes=payload.get('notes'),
        is_debug=(user.email == 'debug@iquit.dev')
    )
    db.session.add(entry)
    db.session.commit()
    return entry


def get_today_consumptions(user):
    today = date.today()
    start = datetime.combine(today, datetime.min.time())
    end = start + timedelta(days=1)
    return Consumption.query.filter(
        Consumption.user_id == user.id,
        Consumption.timestamp >= start,
        Consumption.timestamp < end
    ).all()


def get_weekly_summary(user):
    today = date.today()
    start_date = today - timedelta(days=6)
    summary = []
    for i in range(7):
        day = start_date + timedelta(days=i)
        day_start = datetime.combine(day, datetime.min.time())
        day_end = day_start + timedelta(days=1)
        count = db.session.query(func.count(Consumption.id)).filter(
            Consumption.user_id == user.id,
            Consumption.timestamp >= day_start,
            Consumption.timestamp < day_end
        ).scalar()
        summary.append({'date': day.isoformat(), 'count': count})
    return summary
