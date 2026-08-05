import { createRouter, createWebHistory } from 'vue-router'
import AuthView from '../views/AuthView.vue'
import DashboardView from '../views/DashboardView.vue'
import HomeView from '../components/HelloWorld.vue' // Placeholder for main event hub if needed

const routes = [
  {
    path: '/',
    name: 'home',
    component: () => import('../views/HomeView.vue') // We will move App.vue content here
  },
  {
    path: '/auth',
    name: 'auth',
    component: AuthView
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: DashboardView,
    // meta: { requiresAuth: true }
  },
  {
    path: '/sql-showcase',
    name: 'sql-showcase',
    component: () => import('../views/SqlShowcaseView.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
