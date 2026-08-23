import os
import socket

import psycopg2
from flask import Flask

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "db")
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD")


@app.route("/healthz")
def healthz():
    """Sonda de readiness: dice si ESTE Pod esta vivo, no si la base lo esta.

    Si aqui se comprobara la base de datos, una caida de Postgres sacaria a
    todos los Pods web del Service y el usuario veria un error de conexion en
    vez de la pagina que explica que la base no responde.
    """
    return "ok", 200


@app.route("/")
def index():
    pod = socket.gethostname()
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            connect_timeout=2,
        )
        with conn.cursor() as cur:
            cur.execute("SELECT version()")
            version = cur.fetchone()[0]
        conn.close()
        return (
            "<h1>Conectado a la base de datos</h1>"
            f"<p>Atendido por el pod <code>{pod}</code></p>"
            f"<p>{version}</p>"
        )
    except Exception as exc:
        return (
            "<h1>Fallo la conexion a la base de datos</h1>"
            f"<p>Atendido por el pod <code>{pod}</code></p>"
            f"<pre>{exc}</pre>"
        ), 503


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
