from datetime import datetime
autoimport
from app import db

class Consumption(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    substance_type = db.Column(db.String(50), nullable=False)
    quantity = db.Column(db.Float, nullable=False)
    unit = db.Column(db.String(20), nullable=False)
    cost = db.Column(db.Float, default=0.0)
    notes = db.Column(db.String(255))
    is_debug = db.Column(db.Boolean, default=False)

    user = db.relationship('User', backref=db.backref('consumptions', lazy=True))
