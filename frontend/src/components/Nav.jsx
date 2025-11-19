const NAV_ITEMS = [
  {
    name: 'Dashboard',
    icon: '🏠',
    active: true
  },
  {
    name: 'Registrar Asistencia',
    icon: '📋',
  },
  {
    name: 'Mis Formaciones',
    icon: '📚',
  },
  {
    name: 'Aprendices',
    icon: '👥',
  },
  {
    name: 'Reportes',
    icon: '📊',
  },
  {
    name: 'Ayuda',
    icon: '❓',
  }
];

export default function SidebarNavbar() {
  return (
    <aside className="min-h-screen bg-white border-r border-gray-100 w-64 flex flex-col justify-between">
      <nav className="pt-4 px-3">
        <ul className="space-y-1">
          {NAV_ITEMS.map((item) => (
            <li key={item.name}>
              <button
                className={`flex items-center gap-3 w-full text-left px-4 py-2 rounded-lg font-medium transition ${
                  item.active
                    ? "bg-green-50 text-green-600"
                    : "text-gray-600 hover:bg-gray-50"
                }`}
              >
                <span>{item.icon}</span>
                <span>{item.name}</span>
              </button>
            </li>
          ))}
        </ul>
      </nav>
      <div className="border-t border-gray-100 px-6 py-5 flex items-center gap-2 text-gray-500 cursor-pointer hover:text-green-600 transition">
        <span>⬅️</span>
        <span className="font-medium">Contraer</span>
      </div>
    </aside>
  );
}
