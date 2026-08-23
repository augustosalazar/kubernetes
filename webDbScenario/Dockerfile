FROM python:3.12-slim

# Sin esto, los print() y los logs de Flask se quedan en el buffer y
# `kubectl logs` parece vacio hasta que el proceso muere.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# --no-cache-dir: pip no deja su cache dentro de la imagen.
# Versiones fijadas para que la imagen sea reproducible.
RUN pip install --no-cache-dir flask==3.0.3 psycopg2-binary==2.9.9

COPY app.py .

EXPOSE 8080

CMD ["python", "app.py"]
