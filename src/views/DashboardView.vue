<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { 
  LayoutDashboard, 
  Users, 
  Building2, 
  GraduationCap, 
  ShieldCheck, 
  Activity, 
  LogOut,
  Ticket,
  Calendar,
  Menu,
  Sparkles,
  ArrowRight,
  MapPin,
  Code2,
  ExternalLink
} from 'lucide-vue-next'

import UserManagement from '../components/dashboard/UserManagement.vue'
import ClubManagement from '../components/dashboard/ClubManagement.vue'
import DepartmentManagement from '../components/dashboard/DepartmentManagement.vue'
import BuildingManagement from '../components/dashboard/BuildingManagement.vue'
import OrganizerVerification from '../components/dashboard/OrganizerVerification.vue'
import SystemLogs from '../components/dashboard/SystemLogs.vue'
import EventManagement from '../components/dashboard/EventManagement.vue'
import OrganizerDashboard from '../components/OrganizerDashboard.vue'
import StudentDashboard from '../components/StudentDashboard.vue'

import { apiService } from '../services/api'

const router = useRouter()
// Load user state from localStorage
const storedUserRaw = localStorage.getItem('user')

// Guard: Redirect unauthenticated guest users immediately to login page
onMounted(() => {
  if (!storedUserRaw) {
    router.push('/auth?tab=login')
    return
  }
  fetchInitialData()
})

const storedUser = JSON.parse(storedUserRaw || '{}')
const user = ref({
  name: storedUser.name || (storedUser.email ? storedUser.email.split('@')[0] : 'Guest'),
  email: storedUser.email || 'user@cuet.ac.bd',
  role: (storedUser.role || 'STUDENT').toUpperCase(),
  avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=250&q=80'
})

const isMobileMenuOpen = ref(false)
const activeMenu = ref('dashboard')

// Shared state collections
const usersList = ref([])
const clubsList = ref([])
const departmentsList = ref([])
const events = ref([])
const registrations = ref([])

const fetchInitialData = async () => {
  try {
    events.value = await apiService.getEvents()
    registrations.value = await apiService.getRegistrations()
  } catch (e) {}

  try {
    const resUsers = await fetch('http://localhost:8080/api/users')
    if (resUsers.ok) usersList.value = await resUsers.json()
  } catch (e) {}

  try {
    const resClubs = await fetch('http://localhost:8080/api/clubs')
    if (resClubs.ok) clubsList.value = await resClubs.json()
  } catch (e) {}

  try {
    const resDepts = await fetch('http://localhost:8080/api/departments')
    if (resDepts.ok) departmentsList.value = await resDepts.json()
  } catch (e) {}
}

const handleUpdateRegistrationStatus = async (regId, status) => {
  await apiService.updateRegistrationStatus(regId, status)
  registrations.value = await apiService.getRegistrations()
}

// Menu configuration based on user role
const menuItems = computed(() => {
  if (user.value.role === 'ADMIN') {
    return [
      { id: 'dashboard', label: 'Overview', icon: LayoutDashboard },
      { id: 'users', label: 'Manage users', icon: Users },
      { id: 'clubs', label: 'Manage clubs', icon: Building2 },
      { id: 'departments', label: 'Manage departments', icon: GraduationCap },
      { id: 'buildings', label: 'Manage buildings', icon: MapPin },
      { id: 'verify', label: 'Verify organizers', icon: ShieldCheck },
      { id: 'logs', label: 'System logs', icon: Activity }
    ]
  } else if (user.value.role === 'ORGANIZER') {
    return [
      { id: 'dashboard', label: 'Overview', icon: LayoutDashboard },
      { id: 'events', label: 'My hosted events', icon: Calendar }
    ]
  } else {
    return [
      { id: 'dashboard', label: 'Overview', icon: LayoutDashboard },
      { id: 'passes', label: 'My event passes', icon: Ticket }
    ]
  }
})

const logout = () => {
  localStorage.removeItem('user')
  router.push('/auth?tab=login')
}
</script>

<template>
  <div class="min-h-screen bg-slate-50 flex font-sans antialiased text-slate-900">
    
    <!-- Mobile Sidebar Backdrop Overlay -->
    <div v-if="isMobileMenuOpen" class="fixed inset-0 bg-slate-900/40 backdrop-blur-xs z-40 lg:hidden" @click="isMobileMenuOpen = false"></div>

    <!-- Sidebar -->
    <aside :class="['fixed lg:static inset-y-0 left-0 z-50 w-64 bg-white border-r border-slate-200 transition-transform duration-200 ease-in-out flex flex-col', isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0']">
      
      <!-- Sidebar Header (Logo) -->
      <div class="h-16 flex items-center px-5 border-b border-slate-200 shrink-0">
        <div @click="router.push('/')" class="flex items-center gap-2.5 cursor-pointer group">
          <div class="w-8 h-8 rounded-lg bg-gradient-to-tr from-blue-700 via-blue-600 to-indigo-600 flex items-center justify-center text-white font-black text-sm shadow-sm">
            <GraduationCap class="w-4 h-4 text-white" />
          </div>
          <span class="font-bold text-lg tracking-tight text-slate-900">CUET <span class="text-blue-600">EventX</span></span>
        </div>
      </div>

      <!-- User Profile Summary in Sidebar -->
      <div class="p-4 border-b border-slate-200 bg-slate-50/80 shrink-0">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-lg bg-slate-900 text-white font-bold flex items-center justify-center text-sm shadow-xs">
            {{ user.name.charAt(0).toUpperCase() }}
          </div>
          <div class="overflow-hidden">
            <h4 class="font-bold text-sm text-slate-900 truncate capitalize">{{ user.name }}</h4>
            <span class="inline-block text-xs font-semibold px-2 py-0.5 rounded bg-blue-100 text-blue-800 border border-blue-200 mt-0.5 uppercase">
              {{ user.role }}
            </span>
          </div>
        </div>
      </div>

      <!-- Navigation Links -->
      <nav class="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        <button 
          v-for="item in menuItems" 
          :key="item.id"
          @click="activeMenu = item.id; isMobileMenuOpen = false"
          :class="[
            'w-full flex items-center gap-3 px-3.5 py-2.5 rounded-lg text-sm font-semibold transition-all text-left',
            activeMenu === item.id 
              ? 'bg-blue-50 text-blue-700 font-bold border border-blue-200 shadow-xs' 
              : 'text-slate-700 hover:bg-slate-100 hover:text-slate-900'
          ]"
        >
          <component :is="item.icon" :class="['w-4.5 h-4.5', activeMenu === item.id ? 'text-blue-600' : 'text-slate-500']" />
          {{ item.label }}
        </button>
      </nav>

      <!-- Sidebar Footer (Logout) -->
      <div class="p-3.5 border-t border-slate-200 shrink-0">
        <button @click="logout" class="w-full flex items-center gap-2.5 px-3.5 py-2.5 rounded-lg text-sm font-semibold text-slate-700 hover:text-red-600 hover:bg-red-50 transition-colors">
          <LogOut class="w-4.5 h-4.5 text-slate-500 group-hover:text-red-500" />
          Sign out
        </button>
      </div>
    </aside>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0 overflow-hidden relative">

      <!-- Top Header -->
      <header class="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-5 sm:px-6 z-30 shrink-0">
        <div class="flex items-center gap-3">
          <button @click="isMobileMenuOpen = true" class="p-1.5 -ml-1 text-slate-600 hover:bg-slate-100 rounded-lg lg:hidden">
            <Menu class="w-5 h-5" />
          </button>
          <h1 class="text-lg font-bold text-slate-900 hidden sm:block">
            {{ activeMenu === 'dashboard' ? 'Overview' : menuItems.find(m => m.id === activeMenu)?.label }}
          </h1>
        </div>
        <div class="flex items-center gap-4">
          <span class="text-sm font-semibold text-slate-600 hidden md:block">{{ user.email }}</span>
          <button @click="router.push('/')" class="text-sm text-blue-600 font-semibold hover:underline flex items-center gap-1">
            Back to portal <ArrowRight class="w-4 h-4" />
          </button>
        </div>
      </header>

      <!-- Main Dashboard Content -->
      <main class="flex-1 overflow-y-auto p-5 sm:p-6">
        <div class="w-full space-y-6">
          
          <h1 class="text-xl font-bold text-slate-900 sm:hidden mb-4">
            {{ activeMenu === 'dashboard' ? 'Overview' : menuItems.find(m => m.id === activeMenu)?.label }}
          </h1>

          <!-- 1. OVERVIEW TAB -->
          <template v-if="activeMenu === 'dashboard'">
            <!-- ADMIN OVERVIEW -->
            <div v-if="user.role === 'ADMIN'" class="space-y-6">
              
              <!-- Clean SQL Showcase Launcher Bar for Overview -->
              <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white p-4 rounded-xl border border-slate-200 shadow-xs">
                <div>
                  <h2 class="text-base font-extrabold text-slate-900">System Overview</h2>
                  <p class="text-xs text-slate-500 font-medium">Real-time stats & MySQL relational database presentation suite</p>
                </div>
                <a 
                  href="/sql-showcase" 
                  target="_blank"
                  class="px-4 py-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-blue-400 text-xs font-mono font-bold flex items-center gap-2 border border-slate-700 transition-all shadow-xs shrink-0"
                >
                  <Code2 class="w-4 h-4 text-blue-400" />
                  <span>Launch SQL Showcase Page</span>
                  <ExternalLink class="w-3.5 h-3.5 text-slate-400" />
                </a>
              </div>

              <!-- KPI Summary Cards -->
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <div @click="activeMenu='users'" class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs hover:border-blue-400 transition-all cursor-pointer group">
                  <div class="flex items-center justify-between mb-3">
                    <span class="text-xs font-semibold text-slate-600">Total users</span>
                    <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center group-hover:scale-105 transition-transform">
                      <Users class="w-5 h-5" />
                    </div>
                  </div>
                  <div class="flex items-baseline justify-between">
                    <h3 class="text-3xl font-bold text-slate-900 font-mono">{{ usersList.length || 5 }}</h3>
                    <span class="text-xs font-semibold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2.5 py-0.5 rounded-md flex items-center gap-0.5">
                      ↑ 12%
                    </span>
                  </div>
                  <p class="text-xs text-slate-500 mt-2 font-medium">Registered campus accounts</p>
                </div>

                <div @click="activeMenu='clubs'" class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs hover:border-emerald-400 transition-all cursor-pointer group">
                  <div class="flex items-center justify-between mb-3">
                    <span class="text-xs font-semibold text-slate-600">Recognized clubs</span>
                    <div class="w-9 h-9 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center group-hover:scale-105 transition-transform">
                      <Building2 class="w-5 h-5" />
                    </div>
                  </div>
                  <div class="flex items-baseline justify-between">
                    <h3 class="text-3xl font-bold text-slate-900 font-mono">{{ clubsList.length || 15 }}</h3>
                    <span class="text-xs font-semibold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-md">
                      100% active
                    </span>
                  </div>
                  <p class="text-xs text-slate-500 mt-2 font-medium">Active student societies</p>
                </div>

                <div @click="activeMenu='departments'" class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs hover:border-purple-400 transition-all cursor-pointer group">
                  <div class="flex items-center justify-between mb-3">
                    <span class="text-xs font-semibold text-slate-600">Departments</span>
                    <div class="w-9 h-9 rounded-lg bg-purple-50 text-purple-600 flex items-center justify-center group-hover:scale-105 transition-transform">
                      <GraduationCap class="w-5 h-5" />
                    </div>
                  </div>
                  <div class="flex items-baseline justify-between">
                    <h3 class="text-3xl font-bold text-slate-900 font-mono">{{ departmentsList.length || 18 }}</h3>
                    <span class="text-xs font-semibold text-purple-700 bg-purple-50 border border-purple-200 px-2 py-0.5 rounded-md">
                      CUET academic
                    </span>
                  </div>
                  <p class="text-xs text-slate-500 mt-2 font-medium">Faculty branches</p>
                </div>

                <div @click="activeMenu='verify'" class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs hover:border-amber-400 transition-all cursor-pointer group">
                  <div class="flex items-center justify-between mb-3">
                    <span class="text-xs font-semibold text-slate-600">Pending reviews</span>
                    <div class="w-9 h-9 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center group-hover:scale-105 transition-transform">
                      <ShieldCheck class="w-5 h-5" />
                    </div>
                  </div>
                  <div class="flex items-baseline justify-between">
                    <h3 class="text-3xl font-bold text-slate-900 font-mono">2</h3>
                    <span class="text-xs font-semibold text-amber-800 bg-amber-50 border border-amber-200 px-2 py-0.5 rounded-md">
                      Action needed
                    </span>
                  </div>
                  <p class="text-xs text-slate-500 mt-2 font-medium">Organizer proof documents</p>
                </div>
              </div>

              <!-- Main Overview Content Grid -->
              <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Left 2 Cols: Recent Registered Users & Platform Quick Actions -->
                <div class="lg:col-span-2 space-y-5">
                  
                  <!-- Management Shortcuts Header -->
                  <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs">
                    <div class="flex items-center justify-between mb-4">
                      <h3 class="font-bold text-slate-900 text-base">Management quick actions</h3>
                      <span class="text-xs font-medium text-slate-500">Direct navigation</span>
                    </div>
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                      <button @click="activeMenu='users'" class="p-3.5 rounded-xl bg-slate-50 hover:bg-blue-50 hover:text-blue-700 text-slate-800 border border-slate-200 flex flex-col items-center gap-2 transition-all font-semibold text-xs text-center">
                        <Users class="w-5 h-5 text-blue-600" />
                        Manage users
                      </button>
                      <button @click="activeMenu='clubs'" class="p-3.5 rounded-xl bg-slate-50 hover:bg-emerald-50 hover:text-emerald-700 text-slate-800 border border-slate-200 flex flex-col items-center gap-2 transition-all font-semibold text-xs text-center">
                        <Building2 class="w-5 h-5 text-emerald-600" />
                        Manage clubs
                      </button>
                      <button @click="activeMenu='departments'" class="p-3.5 rounded-xl bg-slate-50 hover:bg-purple-50 hover:text-purple-700 text-slate-800 border border-slate-200 flex flex-col items-center gap-2 transition-all font-semibold text-xs text-center">
                        <GraduationCap class="w-5 h-5 text-purple-600" />
                        Departments
                      </button>
                      <button @click="activeMenu='verify'" class="p-3.5 rounded-xl bg-slate-50 hover:bg-amber-50 hover:text-amber-700 text-slate-800 border border-slate-200 flex flex-col items-center gap-2 transition-all font-semibold text-xs text-center">
                        <ShieldCheck class="w-5 h-5 text-amber-600" />
                        Review proofs
                      </button>
                    </div>
                  </div>

                  <!-- Recent User Registrations -->
                  <div class="bg-white rounded-xl border border-slate-200 shadow-xs overflow-hidden">
                    <div class="p-5 border-b border-slate-200 flex justify-between items-center">
                      <div>
                        <h3 class="font-bold text-slate-900 text-base">Recent user accounts</h3>
                        <p class="text-xs text-slate-500 font-medium mt-0.5">Live view of registered accounts in MySQL</p>
                      </div>
                      <button @click="activeMenu='users'" class="text-xs font-bold text-blue-600 hover:underline">View all →</button>
                    </div>
                    <div class="overflow-x-auto">
                      <table class="w-full text-left text-xs">
                        <thead class="bg-slate-50 text-slate-600 font-bold border-b border-slate-200">
                          <tr>
                            <th class="py-3 px-5">Name</th>
                            <th class="py-3 px-5">Email</th>
                            <th class="py-3 px-5">Role</th>
                          </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                          <tr v-for="u in usersList.slice(0, 4)" :key="u.userId || u.id" class="hover:bg-slate-50">
                            <td class="py-3.5 px-5 font-bold text-slate-900 flex items-center gap-3">
                              <div class="w-8 h-8 rounded-full bg-blue-100 text-blue-700 font-bold flex items-center justify-center text-xs">
                                {{ u.name?.charAt(0) || 'U' }}
                              </div>
                              {{ u.name }}
                            </td>
                            <td class="py-3.5 px-5 text-slate-700 font-mono text-xs">{{ u.email }}</td>
                            <td class="py-3.5 px-5">
                              <span :class="[
                                'px-2.5 py-1 rounded text-xs font-bold uppercase',
                                u.role === 'ADMIN' ? 'bg-purple-100 text-purple-800 border border-purple-200' :
                                u.role === 'ORGANIZER' ? 'bg-amber-100 text-amber-800 border border-amber-200' : 'bg-blue-100 text-blue-800 border border-blue-200'
                              ]">
                                {{ u.role }}
                              </span>
                            </td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>

                <!-- Right 1 Col: System Status & Audit Activity -->
                <div class="space-y-5">
                  <!-- System Health Card -->
                  <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs space-y-4">
                    <h3 class="font-bold text-slate-900 text-base">System operational status</h3>
                    <div class="space-y-2.5 text-xs">
                      <div class="flex justify-between items-center p-3 bg-slate-50 rounded-lg border border-slate-200">
                        <span class="font-semibold text-slate-700">Spring Boot REST API</span>
                        <span class="inline-flex items-center gap-1.5 text-emerald-700 font-bold">
                          <span class="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span> Online (8080)
                        </span>
                      </div>
                      <div class="flex justify-between items-center p-3 bg-slate-50 rounded-lg border border-slate-200">
                        <span class="font-semibold text-slate-700">MySQL Database</span>
                        <span class="inline-flex items-center gap-1.5 text-emerald-700 font-bold">
                          <span class="w-2.5 h-2.5 rounded-full bg-emerald-500"></span> Connected
                        </span>
                      </div>
                      <div class="flex justify-between items-center p-3 bg-slate-50 rounded-lg border border-slate-200">
                        <span class="font-semibold text-slate-700">Vue 3 Vite Frontend</span>
                        <span class="inline-flex items-center gap-1.5 text-blue-700 font-bold">
                          <span class="w-2.5 h-2.5 rounded-full bg-blue-500"></span> Running (5173)
                        </span>
                      </div>
                    </div>
                  </div>

                  <!-- Quick System Audit Feed -->
                  <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-xs space-y-4">
                    <div class="flex justify-between items-center">
                      <h3 class="font-bold text-slate-900 text-base">Audit log stream</h3>
                      <button @click="activeMenu='logs'" class="text-xs font-bold text-blue-600 hover:underline">Full logs</button>
                    </div>
                    <div class="space-y-2.5 font-mono text-xs">
                      <div class="p-2.5 bg-slate-50 rounded-lg border border-slate-200 text-slate-800">
                        <span class="text-blue-700 font-bold">[AUTH]</span> Admin logged in successfully
                      </div>
                      <div class="p-2.5 bg-slate-50 rounded-lg border border-slate-200 text-slate-800">
                        <span class="text-emerald-700 font-bold">[API]</span> Fetched 15 active clubs
                      </div>
                      <div class="p-2.5 bg-slate-50 rounded-lg border border-slate-200 text-slate-800">
                        <span class="text-purple-700 font-bold">[DB]</span> Executed data seed queries
                      </div>
                    </div>
                  </div>
                </div>

              </div>
            </div>

            <!-- ORGANIZER OVERVIEW -->
            <OrganizerDashboard 
              v-else-if="user.role === 'ORGANIZER'" 
              :events="events" 
              :registrations="registrations" 
              @updateRegistrationStatus="handleUpdateRegistrationStatus" 
            />

            <!-- STUDENT OVERVIEW -->
            <StudentDashboard v-else :registrations="registrations" @navigate="router.push('/' + ($event === 'events' ? '' : $event))" />
          </template>

          <!-- MODULAR MANAGEMENT VIEWS -->
          <UserManagement v-else-if="activeMenu === 'users'" />
          <ClubManagement v-else-if="activeMenu === 'clubs'" />
          <DepartmentManagement v-else-if="activeMenu === 'departments'" />
          <BuildingManagement v-else-if="activeMenu === 'buildings'" />
          <OrganizerVerification v-else-if="activeMenu === 'verify'" />
          <SystemLogs v-else-if="activeMenu === 'logs'" />
          <EventManagement v-else-if="activeMenu === 'events'" />
          <StudentDashboard v-else-if="activeMenu === 'passes'" :registrations="registrations" @navigate="router.push('/' + ($event === 'events' ? '' : $event))" />

        </div>
      </main>
    </div>
  </div>
</template>
