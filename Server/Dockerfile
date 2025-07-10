# Dockerfile for IQUIT Flask app
FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . /app

# Environment variables
ENV FLASK_APP=wsgi.py
ENV FLASK_ENV=production

# Expose port
EXPOSE 5001

# Run with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:5001", "wsgi:app"]
