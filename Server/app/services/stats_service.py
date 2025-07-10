from datetime import datetime, date, timedelta
from sqlalchemy import func
from app.models.consumption import Consumption
from app import db


def get_today_stats(user):
    """
    Returns today's total consumption count and total cost for the user.
    """
    today = date.today()
    start = datetime.combine(today, datetime.min.time())
    end = start + timedelta(days=1)
    row = db.session.query(
        func.count(Consumption.id),
        func.coalesce(func.sum(Consumption.cost), 0.0)
    ).filter(
        Consumption.user_id == user.id,
        Consumption.timestamp >= start,
        Consumption.timestamp < end
    ).one()
    return {'count': row[0], 'total_cost': float(row[1])}


def get_weekly_stats(user):
    """
    Returns a list of daily counts and the overall average for the past 7 days.
    """
    today = date.today()
    start_date = today - timedelta(days=6)
    daily = []
    total = 0
    for i in range(7):
        day = start_date + timedelta(days=i)
        day_start = datetime.combine(day, datetime.min.time())
        day_end = day_start + timedelta(days=1)
        count = db.session.query(func.count(Consumption.id)).filter(
            Consumption.user_id == user.id,
            Consumption.timestamp >= day_start,
            Consumption.timestamp < day_end
        ).scalar()
        daily.append({'date': day.isoformat(), 'count': count})
        total += count
    average = total / 7
    return {'daily': daily, 'average': average}
