/**
 * Servicio de Usuario
 * Contiene la lógica de acceso a datos de usuarios
 */

const { pool } = require('../db')

let schemaVerified = false

/**
 * Verifica que la tabla usuarios tenga la estructura correcta
 * @returns {Promise<boolean>} true si la estructura es válida
 * @throws {Error} Si la estructura de la tabla es inválida
 */
async function verifyUserTableSchema() {
  if (schemaVerified) return true

  try {
    const [rows] = await pool.query('DESCRIBE usuarios')
    const columns = new Set(rows.map(r => r.Field))
    const requiredColumns = ['cedula', 'nombre', 'apellido', 'email', 'password_hash', 'rol', 'activo']
    
    const missingColumns = requiredColumns.filter(col => !columns.has(col))
    if (missingColumns.length > 0) {
      throw new Error(`Estructura de tabla usuarios inválida. Faltan columnas: ${missingColumns.join(', ')}`)
    }

    schemaVerified = true
    return true
  } catch (error) {
    console.error('[user.service] Error al verificar esquema:', error)
    throw error
  }
}

/**
 * Obtiene un usuario por su email
 * @param {string} email - Email del usuario
 * @returns {Promise<object|null>} Usuario encontrado o null
 */
async function getUserByEmail(email) {
  if (!email || typeof email !== 'string') {
    return null
  }

  try {
    await verifyUserTableSchema()
    
    const [rows] = await pool.query(
      `SELECT cedula, nombre, apellido, email, password_hash, rol, activo 
       FROM usuarios 
       WHERE email = ? 
       LIMIT 1`,
      [email.trim().toLowerCase()]
    )

    return rows[0] || null
  } catch (error) {
    console.error('[user.service] Error al buscar usuario por email:', error)
    throw error
  }
}

/**
 * Obtiene un usuario por su cédula
 * @param {number} cedula - Cédula del usuario
 * @returns {Promise<object|null>} Usuario encontrado o null
 */
async function getUserByCedula(cedula) {
  if (!cedula || isNaN(Number(cedula)) || Number(cedula) <= 0) {
    return null
  }

  try {
    await verifyUserTableSchema()
    
    const [rows] = await pool.query(
      `SELECT cedula, nombre, apellido, email, password_hash, rol, activo 
       FROM usuarios 
       WHERE cedula = ? 
       LIMIT 1`,
      [Number(cedula)]
    )

    return rows[0] || null
  } catch (error) {
    console.error('[user.service] Error al buscar usuario por cédula:', error)
    throw error
  }
}

module.exports = {
  verifyUserTableSchema,
  getUserByEmail,
  getUserByCedula,
}

