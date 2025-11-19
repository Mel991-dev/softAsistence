import { useState } from "react";
import api from "../utils/api.js";

export default function RegistroAsistencia() {
  const [form, setForm] = useState({
    cedula: "",
    fecha: "",
    hora: "",
    tipo: "entrada",
  });
  const [touched, setTouched] = useState({});
  const [errors, setErrors] = useState({});

  const validate = (values) => {
    let errs = {};
    if (!values.cedula) errs.cedula = "La cédula es obligatoria";
    else if (!/^\d+$/.test(values.cedula)) errs.cedula = "Solo dígitos";
    else if (values.cedula.length < 8) errs.cedula = "Mínimo 8 dígitos";
    else if (values.cedula.length > 15) errs.cedula = "Máximo 15 dígitos";
    if (!values.fecha) errs.fecha = "La fecha es obligatoria";
    if (!values.hora) errs.hora = "La hora es obligatoria";
    const allowedTipos = ["entrada", "salida"];
    if (!values.tipo || !allowedTipos.includes(values.tipo)) errs.tipo = "Selecciona un tipo válido";
    return errs;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    let val = value;
    if (name === "cedula") {
      val = val.replace(/\D/g, "");
    }
    setForm({ ...form, [name]: val });
    setErrors(validate({ ...form, [name]: val }));
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
      fecha: true,
      hora: true,
      tipo: true,
    });
    if (Object.keys(errs).length === 0) {
      const payload = {
        cedula: Number(form.cedula),
        fecha: form.fecha,
        hora: form.hora,
        tipo: form.tipo,
      };
      try {
        const result = await api.registerAttendance(payload);
        alert("¡Asistencia registrada!");
        console.log('Asistencia registrada', result);
      } catch (e) {
        console.error('Error al registrar asistencia', {
          message: e.message,
          status: e.status,
          api_error: e.json?.error,
          api_code: e.json?.code,
          api_sqlMessage: e.json?.sqlMessage,
        });
        alert(`Error al registrar asistencia: ${e.json?.error || e.message}`);
      }
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-green-50">
      <div className="max-w-4xl w-full bg-white rounded-2xl shadow-lg flex overflow-hidden">
        {/* Izquierda - Ilustración y mensaje */}
        <div className="flex-1 bg-green-600 flex flex-col items-center justify-center py-12 px-6 text-center relative">
          <img src="URL_DE_TU_IMAGEN" alt="Ilustración" className="mx-auto mb-7 w-24 h-24 object-contain" />
          <h2 className="text-white text-xl font-semibold mb-4">
            ¡Registra tu asistencia!
          </h2>
          <p className="text-green-50 text-base">
            Sistema de Asistencia SENA.
          </p>
        </div>
        {/* Derecha - Registro de Asistencia */}
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
              <label className="block text-green-700 font-semibold mb-1">Fecha</label>
              <input
                name="fecha"
                type="date"
                className={`w-full px-4 py-2 rounded bg-gray-100 border border-gray-400 outline-none text-gray-700 placeholder-gray-400 ${touched.fecha && errors.fecha ? "border-red-400" : ""}`}
                value={form.fecha}
                onChange={handleChange}
                onBlur={handleBlur}
                required
              />
              {touched.fecha && errors.fecha && <p className="text-sm text-red-500 mt-1">{errors.fecha}</p>}
            </div>
            <div>
              <label className="block text-green-700 font-semibold mb-1">Hora</label>
              <input
                name="hora"
                type="time"
                className={`w-full px-4 py-2 rounded bg-gray-100 border border-gray-400 outline-none text-gray-700 placeholder-gray-400 ${touched.hora && errors.hora ? "border-red-400" : ""}`}
                value={form.hora}
                onChange={handleChange}
                onBlur={handleBlur}
                required
              />
              {touched.hora && errors.hora && <p className="text-sm text-red-500 mt-1">{errors.hora}</p>}
            </div>
            <div>
              <label className="block text-green-700 font-semibold mb-1">Tipo</label>
              <select
                name="tipo"
                value={form.tipo}
                onChange={handleChange}
                onBlur={handleBlur}
                className="w-full border rounded px-3 py-2"
                required
              >
                <option value="entrada">Entrada</option>
                <option value="salida">Salida</option>
              </select>
              {touched.tipo && errors.tipo && <p className="text-sm text-red-500 mt-1">{errors.tipo}</p>}
            </div>
            <button
              type="submit"
              className="w-full py-3 rounded-full bg-green-600 text-white font-bold shadow hover:bg-green-700 transition mt-2"
            >
              Registrar Asistencia
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
