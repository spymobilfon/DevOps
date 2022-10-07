FROM python:3.9.14

RUN python -m pip install psycopg2

WORKDIR /app

COPY service.py .

ENTRYPOINT ["python3", "service.py"]
