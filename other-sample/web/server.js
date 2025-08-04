const express = require("express");
const bodyParser = require("body-parser");
const mysql = require("mysql2/promise");

const app = express();
app.use(bodyParser.json());

// Lee configuración de la BD desde variables de entorno
const dbConfig = {
  host: process.env.DB_HOST || "db",
  port: 3306,
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASS || "s3cret",
  database: process.env.DB_NAME || "clientesdb",
};

// Helper para obtener conexión
async function getConnection() {
  return await mysql.createConnection(dbConfig);
}

// CRUD endpoints

// Listar todos los clientes
app.get("/clientes", async (req, res) => {
  const conn = await getConnection();
  const [rows] = await conn.query("SELECT * FROM clientes");
  await conn.end();
  res.json(rows);
});

// Obtener un cliente por id
app.get("/clientes/:id", async (req, res) => {
  const conn = await getConnection();
  const [rows] = await conn.query("SELECT * FROM clientes WHERE id = ?", [
    req.params.id,
  ]);
  await conn.end();
  if (rows.length) res.json(rows[0]);
  else res.status(404).send({ error: "No encontrado" });
});

// Crear un cliente
app.post("/clientes", async (req, res) => {
  const { nombre, email } = req.body;
  const conn = await getConnection();
  const [result] = await conn.query(
    "INSERT INTO clientes (nombre, email) VALUES (?, ?)",
    [nombre, email]
  );
  await conn.end();
  res.status(201).json({ id: result.insertId, nombre, email });
});

// Actualizar un cliente
app.put("/clientes/:id", async (req, res) => {
  const { nombre, email } = req.body;
  const conn = await getConnection();
  const [result] = await conn.query(
    "UPDATE clientes SET nombre = ?, email = ? WHERE id = ?",
    [nombre, email, req.params.id]
  );
  await conn.end();
  if (result.affectedRows) res.send({ id: +req.params.id, nombre, email });
  else res.status(404).send({ error: "No encontrado" });
});

// Eliminar un cliente
app.delete("/clientes/:id", async (req, res) => {
  const conn = await getConnection();
  const [result] = await conn.query("DELETE FROM clientes WHERE id = ?", [
    req.params.id,
  ]);
  await conn.end();
  if (result.affectedRows) res.status(204).end();
  else res.status(404).send({ error: "No encontrado" });
});

// Arranque
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Web service listening on ${PORT}`));
