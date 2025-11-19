// routes.js - Configuration for web routes

import Login from './pages/Login.jsx';
import Register from './components/Register.jsx';
import Index from './components/index.jsx';
import Home from './pages/Home.jsx';
import Asistencia from './pages/Asistencia.jsx';


export const routes = [
  {
    path: '/',
    name: 'Login',
    component: Login,
    protected: false,
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
    protected: false,
  },
  {
    path: '/index',
    name: 'Index',
    component: Index,
    protected: true,
  },
  {
    path: '/home',
    name: 'Home',
    component: Home,
    protected: true,
  },
  {
    path: '/asistencia',
    name: 'Asistencia',
    component: Asistencia,
    protected: true,
  },

];

// Function to get route by path
export const getRouteByPath = (path) => {
  return routes.find(route => route.path === path);
};

// Function to get all routes
export const getAllRoutes = () => {
  return routes;
};