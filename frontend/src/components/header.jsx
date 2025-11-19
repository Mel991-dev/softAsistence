export default function Header({ user = { name: "Juan Pérez" }, onMenuToggle }) {
  return (
    <header className="w-full h-16 px-6 bg-green-700 flex items-center justify-between">
      {/* Menú hamburguesa a la izquierda */}
      <button
        className="flex items-center justify-center rounded-md hover:bg-green-800 transition h-10 w-10"
        onClick={onMenuToggle}
        aria-label="Abrir menú de navegación"
      >
        <span className="text-white text-xl">☰</span>
      </button>

      {/* Lado derecho: notifición y usuario */}
      <div className="flex items-center gap-6">
        {/* Notificación */}
        <div className="relative">
          <span className="text-white text-xl">🔔</span>
          <span className="absolute top-0 right-0 block h-2 w-2 rounded-full bg-red-500"></span>
        </div>
        {/* Usuario */}
        <div className="flex items-center gap-2 cursor-pointer">
          <span className="text-white text-xl">👤</span>
          <span className="text-white font-semibold">{user.name}</span>
          <span className="text-white text-sm">▼</span>
        </div>
      </div>
    </header>
  );
}
