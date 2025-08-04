# Usa la imagen oficial de MySQL
FROM mysql:8.0

# Variables de entorno para inicializar la BD
ENV MYSQL_ROOT_PASSWORD=s3cret
ENV MYSQL_DATABASE=clientesdb

# Copia el script SQL de inicialización
# (define la tabla 'clientes')
COPY schema.sql /docker-entrypoint-initdb.d/

# Exponemos el puerto estándar de MySQL
EXPOSE 3306
