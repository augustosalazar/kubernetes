import os
import psycopg2
from flask import Flask

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "db")
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD")

@app.route("/")
def index():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            connect_timeout=2
        )
        conn.close()
        return "<h1>✅ Connected to database</h1>"
    except Exception as e:
        return f"<h1>❌ Database connection failed</h1><pre>{e}</pre>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
