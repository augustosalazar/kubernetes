# Imagen con Node.js (elige la versión LTS que prefieras)
FROM node:18

# Directorio de trabajo
WORKDIR /app

# Copiamos definición de dependencias e instalamos
COPY package.json ./
RUN npm install

# Copiamos el código de la aplicación
COPY . .

# Puerto en el que escuchará Express
EXPOSE 8080

# Comando por defecto
CMD ["node", "server.js"]
