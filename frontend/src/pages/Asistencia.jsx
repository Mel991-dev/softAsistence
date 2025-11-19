import { useState } from 'react';
import Header from '../components/header.jsx';
import Nav from '../components/Nav.jsx';
import RegistroAsistencia from '../components/RegistroAsistencia.jsx';

export default function Asistencia() {
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <div className="flex">
      {menuOpen && <Nav />}
      <div className="flex-1">
        <Header onMenuToggle={() => setMenuOpen(!menuOpen)} />
        <RegistroAsistencia />
      </div>
    </div>
  );
}