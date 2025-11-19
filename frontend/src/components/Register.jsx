import { useState } from "react";
import api from "../utils/api.js";
import Header from './header.jsx';
import Nav from './Nav.jsx';

export default function RegistroUsuario() {
  const [menuOpen, setMenuOpen] = useState(false);
  const [form, setForm] = useState({
    cedula: "",
    nombre: "",
    apellido: "",
    email: "",
    password: "",
    rol: "instrutor",
    agree: false,
  });
  const [touched, setTouched] = useState({});
  const [errors, setErrors] = useState({});

  const validate = (values) => {
    let errs = {};
    if (!values.cedula) errs.cedula = "La cédula es obligatoria";
    else if (!/^\d+$/.test(values.cedula)) errs.cedula = "Solo dígitos";
    else if (values.cedula.length < 8) errs.cedula = "Mínimo 8 dígitos";
    else if (values.cedula.length > 15) errs.cedula = "Máximo 15 dígitos";
    if (!values.nombre) errs.nombre = "El nombre es obligatorio";
    if (!values.apellido) errs.apellido = "El apellido es obligatorio";
    if (!values.email) errs.email = "El correo es obligatorio";
    else if (!/^\S+@\S+\.\S+$/.test(values.email)) errs.email = "Correo inválido";
    if (!values.password) errs.password = "La contraseña es obligatoria";
    else if (values.password.length < 8) errs.password = "Mínimo 8 caracteres";
    const allowedRoles = ["administrador", "instrutor"];
    if (!values.rol || !allowedRoles.includes(values.rol)) errs.rol = "Selecciona un rol válido";
    if (!values.agree) errs.agree = "Debes aceptar los términos";
    return errs;
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    let val = value;
    // Solo permitir dígitos en cedula
    if (name === "cedula") {
      val = val.replace(/\D/g, "");
    }
    setForm({ ...form, [name]: type === "checkbox" ? checked : val });
    setErrors(validate({ ...form, [name]: type === "checkbox" ? checked : val }));
  };

  const handleBlur = (e) => {
    setTouched({ ...touched, [e.target.name]: true });
    setErrors(validate(form));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const errs = validate(form);
    setErrors(errs);
    setTouched({
      cedula: true,
      nombre: true,
      apellido: true,
      email: true,
      password: true,
      rol: true,
      agree: true,
    });
    if (Object.keys(errs).length === 0) {
      const payload = {
        cedula: Number(form.cedula),
        nombre: form.nombre,
        apellido: form.apellido,
        email: form.email,
        password: form.password,
        rol: form.rol,
        activo: true,
      };
      try {
        const result = await api.registerUser(payload);
        alert("¡Usuario registrado!");
        console.log('Registro exitoso', result);
      } catch (e) {
        console.error('Error al registrar', {
          message: e.message,
          status: e.status,
          api_error: e.json?.error,
          api_code: e.json?.code,
          api_sqlMessage: e.json?.sqlMessage,
        });
        alert(`Error al registrar: ${e.json?.error || e.message}`);
      }
    }
  };

  return (
    <div className="flex">
      {menuOpen && <Nav />}
      <div className="flex-1">
        <Header onMenuToggle={() => setMenuOpen(!menuOpen)} />
        <div className="min-h-screen flex items-center justify-center bg-green-50">
      <div className="max-w-4xl w-full bg-white rounded-2xl shadow-lg flex overflow-hidden">
        {/* Izquierda - Ilustración y mensaje */}
        <div className="flex-1 bg-green-600 flex flex-col items-center justify-center py-12 px-6 text-center relative">
          <img src="URL_DE_TU_IMAGEN" alt="Ilustración" className="mx-auto mb-7 w-24 h-24 object-contain" />
          <h2 className="text-white text-xl font-semibold mb-4">
            ¡Únete a nuestro equipo y disfruta aprendiendo!
          </h2>
          <p className="text-green-50 text-base">
            Te damos la bienvenida al Sistema de Asistencia SENA.
          </p>
        </div>
        {/* Derecha - Registro */}
        <div className="flex-1 bg-white py-12 px-8 flex flex-col justify-center">
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label className="block text-green-700 font-semibold mb-1">
                Cédula
                <span className="ml-1 text-xs text-gray-500">(solo dígitos, 8-15)</span>
              </label>
              <input
                name="cedula"
                type="text"
                inputMode="numeric"
                maxLength={15}
                minLength={8}
                placeholder="Ej: 12345678"
                className={`w-full px-4 py-2 rounded bg-gray-100 border border-gray-400 outline-none text-gray-700 placeholder-gray-400 ${touched.cedula && errors.cedula ? "border-red-400" : ""}`}
                value={form.cedula}
                onChange={handleChange}
                onBlur={handleBlur}
                required
              />
              {touched.cedula && errors.cedula && <p className="text-sm text-red-500 mt-1">{errors.cedula}</p>}
            </div>
            <div>
              <label className="block text-green-700 font-semibold mb-1">Nombre</label>
              <input
                name="nombre"
                type="text"
                placeholder="Ingresa tu nombre"
                className={`w-full px-4 py-2 rounded bg-gray-100 border border-gray-400 outline-none text-gray-700 placeholder-gray-400 ${touched.nombre && errors.nombre ? "border-red-400" : ""}`}
                value={form.nombre}
                onChange={handleChange}
                onBlur={handleBlur}
                required
              />
              {touched.nombre && errors.nombre && <p className="text-sm text-red-500 mt-1">{errors.nombre}</p>}
            </div>
            <div>
              <label className="block text-green-700 font-semibold mb-1">Apellido</label>
              <input
                name="apellido"
                type="text"
                placeholder="Ingresa tu apellido"
                className={`w-full px-4 py-2 rounded bg-gray-100 border border-gray-400 outline-none text-gray-700 placeholder-gray-400 ${touched.apellido && errors.apellido ? "border-red-400" : ""}`}
                value={form.apellido}
                onChange={handleChange}
                onBlur={handleBlur}
                required
              />
              {touched.apellido && errors.apellido && <p className="text-sm text-red-500 mt-1">{errors.apellido}</p>}
            </div>
            <div>
              <label className="block text-green-700 font-semibold mb-1">Correo electrónico</label>
              <input
                name="email"
                type="email"
                placeholder="ejemplo@sena.edu.co"
                className={`w-full px-4 py-2 rounded bg-gray-100 border border-gray-400 outline-none text-gray-700 placeholder-gray-400 ${touched.email && errors.email ? "border-red-400" : ""}`}
                value={form.email}
                onChange={handleChange}
                onBlur={handleBlur}
                required
              />
              {touched.email && errors.email && <p className="text-sm text-red-500 mt-1">{errors.email}</p>}
            </div>
            <div>
              <label className="block text-green-700 font-semibold mb-1">Contraseña</label>
              <input
                name="password"
                type="password"
                placeholder="********"
                className={`w-full px-4 py-2 rounded bg-gray-100 border border-gray-400 outline-none text-gray-700 placeholder-gray-400 ${touched.password && errors.password ? "border-red-400" : ""}`}
                value={form.password}
                onChange={handleChange}
                onBlur={handleBlur}
                required
              />
              {touched.password && errors.password && <p className="text-sm text-red-500 mt-1">{errors.password}</p>}
            </div>
            <div>
              <label className="block text-green-700 font-semibold mb-1">Rol</label>
              <select
                name="rol"
                value={form.rol}
                onChange={handleChange}
                onBlur={handleBlur}
                className="w-full border rounded px-3 py-2"
                required
              >
                <option value="instrutor">Instrutor (por defecto)</option>
                <option value="administrador">Administrador</option>
              </select>
              {touched.rol && errors.rol && <p className="text-sm text-red-500 mt-1">{errors.rol}</p>}
            </div>
            <div className="flex items-center gap-2">
              <input
                name="agree"
                type="checkbox"
                className="accent-green-700"
                checked={form.agree}
                onChange={handleChange}
                onBlur={handleBlur}
                required
              />
              <span className="text-gray-700 text-sm">
                Al registrarte aceptas los <a href="#" className="underline text-green-700">Términos y Condiciones</a>
              </span>
            </div>
            {touched.agree && errors.agree && <p className="text-sm text-red-500 mt-1">{errors.agree}</p>}
            <button
              type="submit"
              className="w-full py-3 rounded-full bg-green-600 text-white font-bold shadow hover:bg-green-700 transition mt-2"
            >
              Registrarse
            </button>
          </form>
        </div>
      </div>
        </div>
      </div>
    </div>
  );
}
