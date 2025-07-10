from celery import Celery
from app import create_app
from app import db

celery = Celery(__name__, broker='redis://redis:6379/0')

def make_celery(app):
    celery.conf.update(app.config)
    class ContextTask(celery.Task):
        def __call__(self, *args, **kwargs):
            with app.app_context():
                return self.run(*args, **kwargs)
    celery.Task = ContextTask
    return celery

app = create_app()
celery = make_celery(app)

@celery.task
def generate_weekly_stats():
    # TODO: implement weekly stats generation
    pass
