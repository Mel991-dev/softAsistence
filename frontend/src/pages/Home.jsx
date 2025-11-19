import { useState } from 'react';
import Header from '../components/header.jsx';
import Nav from '../components/Nav.jsx';
import Index from '../components/index.jsx';

export default function Home() {
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <div className="flex">
      {menuOpen && <Nav />}
      <div className="flex-1">
        <Header onMenuToggle={() => setMenuOpen(!menuOpen)} />
        <Index />
      </div>
    </div>
  );
}