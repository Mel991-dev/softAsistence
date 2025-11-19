const PASOS = [
  {
    num: '01',
    titulo: 'Registro Inicial',
    descripcion: 'Complete el formulario de registro con sus datos personales y credenciales de acceso al sistema.'
  },
  {
    num: '02',
    titulo: 'Verificación de Identidad',
    descripcion: 'Valide su cuenta a través del correo electrónico enviado. Este paso es crucial para la seguridad.'
  },
  {
    num: '03',
    titulo: 'Configuración del Perfil',
    descripcion: 'Actualice su información académica, foto de perfil y preferencias de notificación.'
  },
  {
    num: '04',
    titulo: 'Registro de Asistencia',
    descripcion: 'Utilice el código QR o el PIN proporcionado para marcar su asistencia diaria a las sesiones.'
  },
  {
    num: '05',
    titulo: 'Consulta de Historial',
    descripcion: 'Revise su historial completo de asistencias y estadísticas en el panel de control personal.'
  },
];

export default function Main() {
  return (
    <main className="min-h-screen bg-[#FAFAFA] px-2 pb-16">
      {/* Encabezado superior */}
      <section className="max-w-5xl mx-auto pt-8 text-center">
        <div className="flex justify-center">
          <div className="rounded-full bg-[#E7F3EC] flex items-center justify-center w-20 h-20 mb-4">
            <span className="text-4xl text-senaGreen">👥</span>
          </div>
        </div>
        <h1 className="font-extrabold text-4xl sm:text-5xl md:text-6xl mb-3 text-black tracking-tight">
          Sistema de <span className="text-senaGreen">Asistencia</span> de Aprendices
        </h1>
        <p className="text-gray-500 text-xl mb-10">
          Plataforma integral para el control y seguimiento de asistencia educativa
        </p>
      </section>

      {/* Card Acerca del Sistema */}
      <section className="max-w-5xl mx-auto mb-12">
        <div className="bg-white border border-gray-200 shadow rounded-2xl">
          <div className="flex items-center gap-3 px-6 py-6">
            <div className="bg-[#E7F3EC] rounded-lg p-3">
              <span className="text-2xl text-senaGreen">📖</span>
            </div>
            <span className="text-2xl font-bold text-black">Acerca del Sistema</span>
          </div>
          <div className="border-t border-gray-100 px-6 py-6">
            <p className="text-gray-800 text-lg mb-4">
              El Sistema de Asistencia de Aprendices es una plataforma moderna diseñada para facilitar el registro, control y análisis de la asistencia estudiantil. Implementado con tecnologías de última generación, permite a instructores y coordinadores mantener un seguimiento preciso y en tiempo real del cumplimiento académico.
            </p>
            <p className="text-gray-400 text-lg">
              Esta herramienta digital elimina los procesos manuales, reduce errores humanos y proporciona información valiosa mediante reportes automáticos y estadísticas detalladas. Nuestro objetivo es mejorar la eficiencia administrativa y fortalecer el compromiso educativo.
            </p>
          </div>
        </div>
      </section>

      {/* Guía de Uso */}
      <section className="max-w-7xl mx-auto">
        <h2 className="text-4xl font-bold mb-2 text-center text-black">Guía de Uso</h2>
        <p className="text-gray-400 mb-10 text-center">
          Siga estos pasos para comenzar a utilizar el sistema correctamente
        </p>
        <div className="grid gap-8 md:grid-cols-3">
          {PASOS.map((item) => (
            <div
              key={item.num}
              className="bg-white border border-gray-200 rounded-2xl shadow p-7 flex flex-col"
            >
              <div className="flex items-center gap-5 mb-4">
                <div className="rounded-full bg-[#E7F3EC] w-16 h-16 flex items-center justify-center">
                  <span className="text-2xl font-bold text-senaGreen">{item.num}</span>
                </div>
                <span className="text-xl font-semibold text-black">{item.titulo}</span>
              </div>
              <p className="text-gray-500 text-base">
                {item.descripcion}
              </p>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
