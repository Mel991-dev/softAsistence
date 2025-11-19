// Prueba de humo de autenticación: registro, login y /me
// Requiere backend corriendo y MySQL con tabla usuarios

const BASE = process.env.API_BASE_URL || 'http://localhost:3000/api'

async function asJson(res) {
  const ct = res.headers.get('content-type') || ''
  const raw = await res.text()
  try { return ct.includes('application/json') ? JSON.parse(raw) : { raw } } catch { return { raw } }
}

async function registerUser(payload) {
  const res = await fetch(`${BASE}/users`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload)
  })
  const json = await asJson(res)
  if (!res.ok || (json && json.ok === false)) {
    if (res.status === 409) { return { ok: true, duplicated: true, json } }
    throw new Error(`register failed: ${JSON.stringify(json)}`)
  }
  return json
}

async function login(credentials) {
  const res = await fetch(`${BASE}/auth/login`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(credentials)
  })
  const json = await asJson(res)
  if (!res.ok || (json && json.status === 'error')) {
    throw new Error(`login failed: ${JSON.stringify(json)}`)
  }
  return json
}

async function me(token) {
  const res = await fetch(`${BASE}/auth/me`, { headers: { Authorization: `Bearer ${token}` } })
  const json = await asJson(res)
  if (!res.ok || (json && json.status === 'error')) {
    throw new Error(`me failed: ${JSON.stringify(json)}`)
  }
  return json
}

async function run() {
  const user = {
    cedula: 12345678,
    nombre: 'Prueba',
    apellido: 'Auth',
    email: 'prueba.auth@sena.edu.co',
    password: 'Password123',
    rol: 'instrutor',
    activo: true,
  }
  console.log('[auth-smoke] register user')
  try { await registerUser(user) } catch (e) { console.error(e.message) }

  console.log('[auth-smoke] login')
  const loginJson = await login({ cedula: user.cedula, password: user.password })
  const token = loginJson?.data?.token
  console.log('[auth-smoke] token length:', token?.length || 0)

  console.log('[auth-smoke] /me')
  const meJson = await me(token)
  console.log('[auth-smoke] me:', meJson?.data?.user)
}

run().catch(err => { console.error('[auth-smoke] error:', err); process.exit(1) })