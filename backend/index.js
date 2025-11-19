const express = require('express')
const cors = require('cors')
const { ping } = require('./db')
const { pool } = require('./db')
const bcrypt = require('bcryptjs')
const authRoutes = require('./routes/auth.routes')

const app = express()
const port = process.env.PORT || 3000

app.use(cors())
// Respuesta manual para preflight CORS (OPTIONS) compatible con Express v5
app.use((req, res, next) => {
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Origin', '*')
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    res.set('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS')
    return res.sendStatus(204)
  }
  next()
})
app.use(express.json())

// Middleware de logging ANTES de las rutas para capturar todas las solicitudes
app.use((req, res, next) => {
  const start = Date.now()
  console.log(`[req] ${req.method} ${req.originalUrl}`)
  if (req.method === 'POST' && req.body) {
    console.log(`[req.body]`, JSON.stringify(req.body).substring(0, 200))
  }
  res.on('finish', () => {
    console.log(`[res] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${Date.now() - start}ms)`) 
  })
  next()
})

// Rutas de autenticación
app.use('/api/auth', authRoutes)

app.get('/api/db-ping', async (req, res) => {
  try {
    const rows = await ping()
    const [[info]] = await pool.query('SELECT DATABASE() AS db, VERSION() AS version')
    res.json({ ok: true, rows, info })
  } catch (error) {
    const msg = error?.message || error?.code || String(error) || 'Error'
    console.error('db-ping error:', error)
    res.status(500).json({ ok: false, error: msg })
  }
})

app.post('/api/users', async (req, res) => {
  try {
    console.log('[users.create.body]', req.body)
    const {
      cedula,
      nombre,
      apellido,
      email = null,
      password,
      rol = 'instrutor',
      activo = true,
    } = req.body

    if (!cedula || !password || !nombre || !apellido) {
      return res.status(400).json({ ok: false, error: 'cedula, nombre, apellido y password son obligatorios' })
    }

    let rolValue = String(rol)
    const allowedRoles = ['administrador', 'instrutor', 'instructor']
    if (rolValue && !allowedRoles.includes(rolValue)) {
      return res.status(400).json({ ok: false, error: 'rol inválido, use "administrador" o "instrutor"' })
    }
    if (rolValue === 'instructor') rolValue = 'instrutor'

    const password_hash = await bcrypt.hash(password, 10)

    const [result] = await pool.query(
      'INSERT INTO usuarios (cedula, nombre, apellido, email, password_hash, rol, activo, fecha_creacion, fecha_actualizacion) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())',
      [Number(cedula), nombre, apellido, email, password_hash, rolValue, activo ? 1 : 0]
    )

    console.log('[users.create.result]', { insertId: result.insertId })
    res.status(201).json({ ok: true, cedula: Number(cedula) })
  } catch (error) {
    const msg = error?.message || error?.code || String(error) || 'Error'
    console.error('POST /api/users error:', error)
    if (error && error.code === 'ER_DUP_ENTRY') {
      const e = (error.sqlMessage || '').toLowerCase()
      const field = e.includes('uk_email') ? 'email' : e.includes('primary') ? 'cedula' : 'registro'
      return res.status(409).json({ ok: false, error: `duplicado en ${field}` })
    }
    if (error && error.code === 'ER_NO_SUCH_TABLE') {
      return res.status(500).json({ ok: false, error: 'tabla usuarios no existe' })
    }
    if (error && error.code === 'ER_BAD_DB_ERROR') {
      return res.status(500).json({ ok: false, error: 'base de datos no encontrada' })
    }
    res.status(500).json({ ok: false, error: msg, code: error?.code || null, sqlMessage: error?.sqlMessage || null })
  }
})

 

app.get('/api/debug/routes', (req, res) => {
  try {
    const routes = []
    const stack = (app._router && app._router.stack) || []
    for (const layer of stack) {
      if (layer.route && layer.route.path) {
        const methods = Object.keys(layer.route.methods || {}).filter(m => layer.route.methods[m])
        routes.push({ path: layer.route.path, methods })
      } else if (layer.name === 'router' && layer.handle && layer.handle.stack) {
        for (const nested of layer.handle.stack) {
          if (nested.route && nested.route.path) {
            const methods = Object.keys(nested.route.methods || {}).filter(m => nested.route.methods[m])
            routes.push({ path: nested.route.path, methods })
          }
        }
      }
    }
    res.json({ ok: true, routes })
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) })
  }
})

app.get('/api/users', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT cedula, nombre, apellido, email, rol, activo, fecha_creacion, fecha_actualizacion FROM usuarios ORDER BY fecha_creacion DESC')
    res.json({ ok: true, data: rows })
  } catch (error) {
    const msg = error?.message || error?.code || String(error) || 'Error'
    console.error('GET /api/users error:', error)
    res.status(500).json({ ok: false, error: msg })
  }
})

app.get('/api/hello', (req, res) => {
  res.json({ message: 'hola desde backend' })
})

app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`)
})