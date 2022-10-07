import json
import logging
import random
import time
import os
import psycopg2
from datetime import datetime, timezone

POSTGRES_PASSWORD = os.environ['POSTGRES_PASSWORD']
POSTGRES_USER = os.environ['POSTGRES_USER']
POSTGRES_DB = os.environ['POSTGRES_DB']
POSTGRES_HOST = os.environ['POSTGRES_HOST']

logging.basicConfig(
    level="INFO",
    format="%(asctime)s — %(name)s — %(levelname)s — %(message)s",
)
logger = logging.getLogger(__name__)

if __name__ == "__main__":
    while True:
        msg = dict()
        for level in range(50):
            (
                msg[f"bid_{str(level).zfill(2)}"],
                msg[f"ask_{str(level).zfill(2)}"],
            ) = (
                random.randrange(1, 100),
                random.randrange(100, 200),
            )
        msg["stats"] = {
            "sum_bid": sum(v for k, v in msg.items() if "bid" in k),
            "sum_ask": sum(v for k, v in msg.items() if "ask" in k),
        }
        logger.info(f"{json.dumps(msg)}")
        time.sleep(0.001)

        conn_to_db = psycopg2.connect(database=POSTGRES_DB, user=POSTGRES_USER, password=POSTGRES_PASSWORD, host=POSTGRES_HOST, port='5432')
        cur = conn_to_db.cursor()
        cur.execute("CREATE TABLE IF NOT EXISTS t_service (time TIMESTAMP, json JSONB);")
        cur.execute("INSERT INTO t_service VALUES (%s,%s)", (datetime.now(timezone.utc),json.dumps(msg),))
        conn_to_db.commit()
        conn_to_db.close()

        if msg["ask_01"] + msg["bid_01"] < 105:
            conn_to_db = psycopg2.connect(database=POSTGRES_DB, user=POSTGRES_USER, password=POSTGRES_PASSWORD, host=POSTGRES_HOST, port='5432')
            cur = conn_to_db.cursor()
            cur.execute("CREATE TABLE IF NOT EXISTS t_alert (time TIMESTAMP, json JSONB);")
            cur.execute("INSERT INTO t_alert VALUES (%s,%s)", (datetime.now(timezone.utc),json.dumps(msg),))
            conn_to_db.commit()
            conn_to_db.close()
