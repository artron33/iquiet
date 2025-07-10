from celery import Celery
from app.config import Config

def make_celery(app):
    celery = Celery(
        app.import_name,
        broker=app.config['CELERY_BROKER_URL'],
        backend=app.config['CELERY_RESULT_BACKEND'],
    )
    celery.conf.update(app.config)
    class ContextTask(celery.Task):
        def __call__(self, *args, **kwargs):
            with app.app_context():
                return self.run(*args, **kwargs)
    celery.Task = ContextTask
    return celery

from app import create_app
flask_app = create_app()
celery = make_celery(flask_app)
from celery.schedules import crontab

# Configure beat schedule to run weekly stats every Monday at midnight
celery.conf.beat_schedule = {
    'generate-weekly-stats': {
        'task': 'app.tasks.background_tasks.generate_weekly_stats',
        'schedule': crontab(day_of_week='mon', hour=0, minute=0),
    },
}

@celery.task
async def generate_weekly_stats():
    # This would aggregate consumption stats weekly
    print("Generating weekly stats...")
    # Future: write to DB or send emails
    return True

@celery.task
async def send_reminder_email(user_email: str, subject: str, body: str):
    """Send a reminder email to a user (placeholder implementation)."""
    # TODO: Replace with real SMTP/mail service integration
    print(f"Sending reminder email to {user_email}: {subject}\n{body}")
    return True

@celery.task
async def send_milestone_email(user_email: str, milestone: str):
    """Notify user upon reaching a milestone."""
    subject = f"Congratulations on your {milestone}!"
    body = f"You've reached {milestone} in your journey. Keep up the great work!"
    await send_reminder_email(user_email, subject, body)
    return True
