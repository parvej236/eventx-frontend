<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Calendar, MapPin, Users, LayoutDashboard, Search, GraduationCap, LogOut, Menu, X } from 'lucide-vue-next'

const props = defineProps({
  currentView: String,
  currentRole: String
})

const emit = defineEmits(['navigate', 'switchRole', 'openSearch'])
const router = useRouter()

const mobileMenuOpen = ref(false)
const hasUser = ref(false)
const userName = ref('')
const userRole = ref('')
const userInitials = ref('')

onMounted(() => {
  const storedUser = localStorage.getItem('user')
  if (storedUser) {
    try {
      const user = JSON.parse(storedUser)
      hasUser.value = true
      userName.value = user.name || user.email ? user.email.split('@')[0] : 'User'
      userRole.value = user.role || 'STUDENT'
      userInitials.value = userName.value.substring(0, 2).toUpperCase()
    } catch (e) {
      console.error(e)
    }
  }
})

const handleRouterNavigate = (path) => {
  router.push(path)
  mobileMenuOpen.value = false
}

const handleLogout = () => {
  localStorage.removeItem('user')
  hasUser.value = false
  userName.value = ''
  userRole.value = ''
  userInitials.value = ''
  router.push('/auth?tab=login')
}

// Nav items computed dynamically based on authentication state
const navItems = computed(() => {
  const items = [
    { id: 'events', label: 'Events', icon: Calendar },
    { id: 'venues', label: 'Venues', icon: MapPin },
    { id: 'clubs', label: 'Clubs', icon: Users }
  ]
  // Only show Dashboard menu if user is signed in
  if (hasUser.value) {
    items.push({ id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard })
  }
  return items
})

const handleNavigate = (id) => {
  if (id === 'dashboard') {
    if (!hasUser.value) {
      router.push('/auth?tab=login')
      return
    }
    router.push('/dashboard')
  } else {
    emit('navigate', id)
  }
  mobileMenuOpen.value = false
}
</script>

<template>
  <header class="fixed top-0 left-0 right-0 z-40 bg-white/90 backdrop-blur-xl border-b border-slate-200/80 shadow-xs transition-all">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-14 flex items-center justify-between">
      
      <!-- Professional Brand Logo -->
      <div 
        @click="handleNavigate('events')" 
        class="flex items-center gap-2.5 cursor-pointer group shrink-0"
      >
        <div class="w-9 h-9 rounded-lg overflow-hidden border border-slate-200/80 shadow-sm group-hover:scale-105 transition-transform flex items-center justify-center p-0.5">
          <img src="/logo.png" alt="EventX CUET Logo" class="w-full h-full object-contain" />
        </div>
        <div class="flex items-center gap-1.5">
          <span class="text-base font-extrabold tracking-tight text-slate-900">CUET</span>
          <span class="text-base font-extrabold tracking-tight text-blue-600">EventX</span>
        </div>
      </div>

      <!-- Professional Center Navigation -->
      <nav class="hidden md:flex items-center gap-1 bg-slate-100/60 p-1 rounded-xl border border-slate-200/60">
        <button
          v-for="item in navItems"
          :key="item.id"
          @click="handleNavigate(item.id)"
          :class="[
            currentView === item.id 
              ? 'bg-white text-blue-700 font-bold shadow-xs border border-slate-200/80' 
              : 'text-slate-600 hover:text-slate-900 hover:bg-white/50 font-medium',
            'flex items-center gap-1.5 px-3 py-1 rounded-lg text-xs transition-all'
          ]"
        >
          <component :is="item.icon" class="w-3.5 h-3.5" />
          <span>{{ item.label }}</span>
        </button>
      </nav>

      <!-- Right Action Bar -->
      <div class="flex items-center gap-2.5">
        
        <!-- Professional Inline Search Input Trigger -->
        <button 
          @click="emit('openSearch')"
          class="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-xl bg-slate-100/80 hover:bg-slate-200/80 border border-slate-200/80 text-slate-500 hover:text-slate-900 text-xs transition-all w-44 lg:w-56 justify-between group"
          title="Search Events, Clubs, Venues"
        >
          <div class="flex items-center gap-2 min-w-0">
            <Search class="w-3.5 h-3.5 text-slate-400 group-hover:text-blue-600 transition-colors shrink-0" />
            <span class="truncate">Search events, clubs...</span>
          </div>
          <kbd class="hidden lg:inline-flex items-center gap-0.5 px-1.5 py-0.5 text-[9px] font-mono text-slate-400 bg-white border border-slate-200 rounded-md shadow-2xs">
            ⌘K
          </kbd>
        </button>

        <!-- Mobile Search Icon Button -->
        <button 
          @click="emit('openSearch')"
          class="sm:hidden p-1.5 rounded-lg text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors"
          title="Search"
        >
          <Search class="w-4 h-4" />
        </button>

        <div class="h-4 w-px bg-slate-200 mx-0.5 hidden sm:block"></div>

        <!-- User Profile Avatar / Auth -->
        <template v-if="hasUser">
          <div class="flex items-center gap-2">
            <button 
              @click="handleRouterNavigate('/dashboard')"
              class="flex items-center gap-2 p-1 pl-2 pr-2.5 rounded-xl border border-slate-200 hover:border-slate-300 hover:bg-slate-50 transition-all text-left"
            >
              <div class="w-6 h-6 rounded-lg bg-slate-900 text-white font-bold text-[10px] flex items-center justify-center">
                {{ userInitials }}
              </div>
              <div class="hidden sm:block">
                <span class="text-xs font-bold text-slate-900 block leading-none">{{ userName }}</span>
                <span class="text-[9px] font-semibold text-blue-600 block leading-none mt-0.5 uppercase">{{ userRole }}</span>
              </div>
            </button>

            <button 
              @click="handleLogout"
              class="p-1.5 rounded-lg text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors"
              title="Sign out"
            >
              <LogOut class="w-4 h-4" />
            </button>
          </div>
        </template>

        <template v-else>
          <div class="flex items-center gap-1.5">
            <button 
              @click="handleRouterNavigate('/auth?tab=login')"
              class="text-slate-700 hover:text-slate-900 font-semibold text-xs px-3 py-1.5 rounded-lg hover:bg-slate-100 transition-colors"
            >
              Sign in
            </button>
            <button 
              @click="handleRouterNavigate('/auth?tab=signup')"
              class="bg-blue-600 hover:bg-blue-700 text-white px-3.5 py-1.5 rounded-lg text-xs font-semibold shadow-xs transition-colors"
            >
              Sign up
            </button>
          </div>
        </template>

        <!-- Mobile Hamburger -->
        <button 
          @click="mobileMenuOpen = !mobileMenuOpen"
          class="md:hidden p-1.5 rounded-lg text-slate-700 hover:bg-slate-100 transition-colors"
        >
          <X v-if="mobileMenuOpen" class="w-5 h-5" />
          <Menu v-else class="w-5 h-5" />
        </button>

      </div>
    </div>

    <!-- Mobile Slide-down Drawer -->
    <div 
      v-if="mobileMenuOpen"
      class="md:hidden border-t border-slate-200 bg-white/95 backdrop-blur-lg px-4 py-3 space-y-1.5 shadow-lg"
    >
      <button
        v-for="item in navItems"
        :key="item.id"
        @click="handleNavigate(item.id)"
        :class="[
          currentView === item.id ? 'text-blue-700 font-bold bg-blue-50' : 'text-slate-700 hover:bg-slate-50',
          'w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-xs font-medium transition-colors'
        ]"
      >
        <component :is="item.icon" class="w-4 h-4 text-slate-500" />
        <span>{{ item.label }}</span>
      </button>
    </div>
  </header>
</template>
