#!/usr/bin/python3

import psycopg2

try:
    conn_to_db=psycopg2.connect("dbname='confluence' user='confluence' password='111111' host='localhost' port='5432'")
    conn_to_db.close()
    print("Database connected success")
except:
    print("Problem with connect to database")