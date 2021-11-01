FROM python:3.9-slim
WORKDIR /app
ADD ./requirements.txt /app
RUN pip install -r requirements.txt
ADD ./app /app
CMD gunicorn --bind=0.0.0.0:5000 app_file:app
