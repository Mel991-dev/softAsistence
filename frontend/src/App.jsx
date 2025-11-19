import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { routes } from './routes.js';
import ProtectedRoute from './components/ProtectedRoute.jsx';

function App() {
  return (
    <Router>
      <Routes>
        {routes.map((route, index) => {
          const Element = route.component;
          const wrapped = route.protected
            ? (<ProtectedRoute><Element /></ProtectedRoute>)
            : (<Element />);
          return (
            <Route key={index} path={route.path} element={wrapped} />
          );
        })}
      </Routes>
    </Router>
  );
}

export default App;