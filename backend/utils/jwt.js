const jwt = require('jsonwebtoken')

const {
  JWT_SECRET = 'dev-secret-softasistence',
  JWT_EXPIRES_IN = '1d',
} = process.env

function signToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN })
}

function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET)
  } catch (e) {
    return null
  }
}

module.exports = { signToken, verifyToken }