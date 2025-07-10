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

@celery.task
async def generate_weekly_stats():
    # This would aggregate consumption stats weekly
    print("Generating weekly stats...")
    # Future: write to DB or send emails
    return True
