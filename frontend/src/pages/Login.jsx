import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../utils/api.js';

export default function Login() {
  const [showPassword, setShowPassword] = useState(false);
  const [form, setForm] = useState({ cedula: '', password: '' });
  const [touched, setTouched] = useState({});
  const [errors, setErrors] = useState({});
  const [submitting, setSubmitting] = useState(false);
  const navigate = useNavigate();

  const validate = (values) => {
    const errs = {};
    if (!values.cedula) errs.cedula = 'La cédula es obligatoria';
    else if (!/^\d+$/.test(values.cedula)) errs.cedula = 'Solo dígitos';
    else if (values.cedula.length < 8) errs.cedula = 'Mínimo 8 dígitos';
    else if (values.cedula.length > 15) errs.cedula = 'Máximo 15 dígitos';
    if (!values.password) errs.password = 'La contraseña es obligatoria';
    else if (values.password.length < 8) errs.password = 'Mínimo 8 caracteres';
    return errs;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((f) => ({ ...f, [name]: value }));
  };

  const handleBlur = (e) => {
    setTouched((t) => ({ ...t, [e.target.name]: true }));
    setErrors(validate(form));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validar formulario
    const errs = validate(form);
    setErrors(errs);
    setTouched({ cedula: true, password: true });
    
    if (Object.keys(errs).length > 0) {
      return;
    }

    setSubmitting(true);

    try {
      // Preparar credenciales
      const credentials = {
        cedula: form.cedula.trim(),
        password: form.password,
      };

      console.log('[Login] Iniciando sesión...');

      // Llamar a la API
      const result = await api.login(credentials);
      
      console.log('[Login] Respuesta recibida:', result);

      // Verificar que se recibió el usuario
      const user = result?.data?.user;
      if (!user) {
        throw new Error('No se recibió información del usuario');
      }

      // Guardar usuario y token en localStorage
      localStorage.setItem('user', JSON.stringify(user));
      if (result?.data?.token) {
        localStorage.setItem('token', result.data.token);
      }
      console.log('[Login] Usuario guardado en localStorage');

      // Redirigir a la página principal
      navigate('/home');
    } catch (error) {
      console.error('[Login] Error de inicio de sesión:', {
        message: error.message,
        status: error.status,
        api_message: error.json?.message,
      });

      // Mostrar mensaje de error al usuario
      const errorMessage = error.json?.message || error.message || 'Error al iniciar sesión';
      alert(errorMessage);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      {/* Contenedor principal */}
      <div className="bg-white rounded-lg shadow-lg flex w-full max-w-4xl overflow-hidden">
        {/* Izquierda: Formulario */}
        <div className="flex-1 p-10 flex flex-col justify-center">
          <h2 className="text-3xl font-bold text-gray-800 mb-2">Sistema de Control de Asistencia</h2>
          <p className="mb-6 text-lg text-gray-500">SENA Regional Caquetá</p>
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-gray-700 mb-2">Cédula *</label>
              <div className="flex items-center bg-gray-100 rounded">
                <span className="px-3 text-gray-400">
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                    <rect x="3" y="4" width="18" height="14" rx="2" />
                  </svg>
                </span>
                <input
                  type="text"
                  inputMode="numeric"
                  maxLength={15}
                  minLength={8}
                  placeholder="Ej: 12345678"
                  name="cedula"
                  value={form.cedula}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  className="bg-gray-100 outline-none p-3 flex-1 rounded"
                  required
                />
              </div>
              {touched.cedula && errors.cedula && (
                <p className="text-sm text-red-500 mt-1">{errors.cedula}</p>
              )}
            </div>
            <div className="mb-4">
              <label className="block text-gray-700 mb-2">Contraseña *</label>
              <div className="flex items-center bg-gray-100 rounded">
                <span className="px-3 text-gray-400">
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                    <rect x="5" y="10" width="14" height="10" rx="2" />
                  </svg>
                </span>
                <input
                  type={showPassword ? 'text' : 'password'}
                  name="password"
                  value={form.password}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  className="bg-gray-100 outline-none p-3 flex-1 rounded"
                  required
                />
                <button type="button"
                  className="px-3 text-gray-400"
                  onClick={() => setShowPassword(!showPassword)}>
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                    <circle cx="12" cy="12" r="6" />
                  </svg>
                </button>
              </div>
              {touched.password && errors.password && (
                <p className="text-sm text-red-500 mt-1">{errors.password}</p>
              )}
            </div>
            <div className="flex items-center justify-between mb-6">
              <label className="flex items-center">
                <input type="checkbox" className="mr-2" />
                <span className="text-gray-600">Recordarme</span>
              </label>
              <a href="#" className="text-green-600 underline">¿Olvidó su contraseña?</a>
            </div>
            <button
              type="submit"
              disabled={submitting}
              className="w-full bg-green-600 hover:bg-green-700 text-white py-3 rounded font-semibold transition disabled:opacity-60">
              Iniciar Sesión
            </button>
          </form>
          {/* Footer */}
          <div className="mt-8 text-xs text-gray-400 text-center">
            © 2025 SENA Regional Caquetá - Todos los derechos reservados
            <div>
              <a href="#" className="underline mx-2">Términos y Condiciones</a>
              |
              <a href="#" className="underline mx-2">Política de Privacidad</a>
            </div>
          </div>
        </div>
        {/* Derecha: Bienvenida */}
        <div className="hidden md:flex flex-1 bg-gradient-to-br from-green-500 to-green-300 items-center justify-center">
          <div className="text-center">
            <h1 className="text-white font-bold text-3xl mb-4">Bienvenido al Sistema de Asistencia</h1>
            <p className="text-white text-lg">Gestiona y registra la asistencia de aprendices de forma digital, rápida y eficiente.</p>
            {/* Puedes agregar aquí el círculo decorativo con Tailwind */}
            <div className="mt-12">
              <div className="w-40 h-40 bg-green-200 opacity-60 rounded-full mx-auto"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
