const { verifyToken } = require('../utils/jwt')

function authMiddleware(req, res, next) {
  const header = req.headers['authorization'] || ''
  const parts = header.split(' ')
  const token = parts.length === 2 && parts[0] === 'Bearer' ? parts[1] : null

  if (!token) {
    return res.status(401).json({ status: 'error', message: 'No autorizado: token requerido', data: null })
  }

  const payload = verifyToken(token)
  if (!payload) {
    return res.status(401).json({ status: 'error', message: 'Token inválido o expirado', data: null })
  }

  req.user = payload
  next()
}

module.exports = { authMiddleware }