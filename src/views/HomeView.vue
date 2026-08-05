<script setup>
import { ref, computed, onMounted } from 'vue'
import Navbar from '../components/Navbar.vue'
import HeroSection from '../components/HeroSection.vue'
import EventCard from '../components/EventCard.vue'
import EventDetailView from '../components/EventDetailView.vue'
import RegistrationModal from '../components/RegistrationModal.vue'
import VolunteerModal from '../components/VolunteerModal.vue'
import StudentDashboard from '../components/StudentDashboard.vue'
import OrganizerDashboard from '../components/OrganizerDashboard.vue'
import CampusVenuesView from '../components/CampusVenuesView.vue'
import ClubsView from '../components/ClubsView.vue'
import Toast from '../components/Toast.vue'
import Footer from '../components/Footer.vue'
import { apiService } from '../services/api'
import { Calendar, Search, Trophy, Sparkles, Zap, QrCode, ShieldCheck, Video, Users, ArrowRight, CheckCircle2, UserPlus, CreditCard } from 'lucide-vue-next'

const currentView = ref('events')
const currentRole = ref('STUDENT')

const events = ref([])
const registrations = ref([])
const clubs = ref([])
const buildings = ref([])

const searchQuery = ref('')
const selectedCategory = ref('ALL')
const selectedStatus = ref('ALL')

const selectedEventForDetail = ref(null)
const selectedEventForRegistration = ref(null)
const selectedSegmentForRegistration = ref(null)
const selectedEventForVolunteer = ref(null)

const toast = ref(null)

const showToast = (title, message, type = 'success') => {
  toast.value = { title, message, type }
  setTimeout(() => {
    toast.value = null
  }, 4000)
}

// Load data on mount
onMounted(async () => {
  try {
    events.value = await apiService.getEvents()
    registrations.value = await apiService.getRegistrations()
    clubs.value = await apiService.getClubs()
    buildings.value = await apiService.getBuildings()
  } catch (err) {
    console.error('Initialization error:', err)
  }
})

// Filtered Events Computed
const filteredEvents = computed(() => {
  let list = events.value || []

  if (selectedStatus.value !== 'ALL') {
    list = list.filter(e => (e.status || '').toUpperCase() === selectedStatus.value.toUpperCase())
  }

  if (selectedCategory.value !== 'ALL') {
    list = list.filter(e => e.category === selectedCategory.value)
  }

  if (searchQuery.value.trim()) {
    const q = searchQuery.value.toLowerCase()
    list = list.filter(e =>
      e.name?.toLowerCase().includes(q) ||
      e.description?.toLowerCase().includes(q) ||
      e.organizerClub?.toLowerCase().includes(q) ||
      e.segments?.some(s => s.title.toLowerCase().includes(q))
    )
  }

  return list
})

const totalPrizePool = computed(() => {
  return (events.value || []).reduce((acc, curr) => acc + (curr.prizePool || 0), 0)
})

import { useRouter } from 'vue-router'

const router = useRouter()

const isUserLoggedIn = () => {
  try {
    const u = localStorage.getItem('user') || localStorage.getItem('eventx_user') || localStorage.getItem('currentUser')
    return !!u && u !== 'null'
  } catch (e) {
    return false
  }
}

// Handlers
const handleSelectEvent = (event) => {
  selectedEventForDetail.value = event
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleRegisterEvent = (event) => {
  if (!isUserLoggedIn()) {
    showToast('Authentication Required', 'Please sign in or create an account to register for campus events.', 'error')
    router.push('/auth?tab=login')
    return
  }
  selectedEventForDetail.value = null
  selectedEventForRegistration.value = event
  selectedSegmentForRegistration.value = event.segments?.[0] || null
}

const handleRegisterSegment = ({ event, segment }) => {
  if (!isUserLoggedIn()) {
    showToast('Authentication Required', 'Please sign in or create an account to register for event segments.', 'error')
    router.push('/auth?tab=login')
    return
  }
  selectedEventForDetail.value = null
  selectedEventForRegistration.value = event
  selectedSegmentForRegistration.value = segment || event.segments?.[0] || null
}

const handleRegistrationSubmitted = async (regPayload) => {
  const newReg = await apiService.createRegistration(regPayload)
  registrations.value = await apiService.getRegistrations()
  showToast('Registration Confirmed', `You have registered for ${regPayload.eventName}!`, 'success')
}

const handleCreateEvent = async (newEventData) => {
  const created = await apiService.createEvent(newEventData)
  events.value = await apiService.getEvents()
  showToast('Event Published', `${created.name} is now live on the campus hub!`, 'success')
}

const handleUpdateRegistrationStatus = async (regId, status) => {
  await apiService.updateRegistrationStatus(regId, status)
  registrations.value = await apiService.getRegistrations()
  showToast('Status Updated', `Registration #${regId} status changed to ${status}`, 'info')
}

const handleSelectClubEvents = (clubName) => {
  selectedEventForDetail.value = null
  currentView.value = 'events'
  searchQuery.value = clubName
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleNavigateView = (view) => {
  selectedEventForDetail.value = null
  currentView.value = view
  window.scrollTo({ top: 0, behavior: 'smooth' })
}
</script>

<template>
  <div class="min-h-screen bg-slate-50 text-slate-900 relative selection:bg-blue-600 selection:text-white font-sans flex flex-col justify-between">
    
    <!-- Toast Notifications -->
    <Toast :toast="toast" @close="toast = null" />

    <!-- Top Navigation Bar -->
    <Navbar
      :currentView="selectedEventForDetail ? '' : currentView"
      :currentRole="currentRole"
      @navigate="handleNavigateView($event)"
      @switchRole="currentRole = $event"
      @openSearch="handleNavigateView('events')"
    />

    <!-- Dynamic Main Views -->
    <main class="flex-1">
      
      <!-- Full Page Registration Page View -->
      <RegistrationModal
        v-if="selectedEventForRegistration"
        :event="selectedEventForRegistration"
        :selectedSegment="selectedSegmentForRegistration"
        @close="selectedEventForRegistration = null"
        @submitted="handleRegistrationSubmitted"
      />

      <!-- Full Page Event Detail View (When an Event is selected) -->
      <EventDetailView
        v-else-if="selectedEventForDetail"
        :event="selectedEventForDetail"
        @back="handleNavigateView('events')"
        @registerSegment="handleRegisterSegment"
        @applyVolunteer="selectedEventForVolunteer = $event"
      />

      <!-- View 1: Explore Events (Structured Homepage Layout) -->
      <div v-else-if="currentView === 'events'" class="space-y-5">
        
        <!-- Hero Spotlight Section with Auto-Rotating Carousel -->
        <HeroSection
          v-model:searchQuery="searchQuery"
          v-model:selectedCategory="selectedCategory"
          v-model:selectedStatus="selectedStatus"
          :totalEventsCount="events.length"
          :totalPrizePool="totalPrizePool"
          :events="events"
          @selectEvent="handleSelectEvent"
          @registerEvent="handleRegisterEvent"
          @openCreateModal="currentView = 'organizer'"
        />

        <!-- Section 1: Active Events Grid -->
        <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12">
          <div class="flex items-center justify-between mb-6 border-b border-slate-200 pb-3">
            <div>
              <h2 class="text-xl sm:text-2xl font-black text-slate-900 flex items-center gap-2">
                <Calendar class="w-5 h-5 text-blue-700" />
                <span>Featured Events</span>
              </h2>
              <p class="text-xs text-slate-500 mt-0.5">Showing {{ filteredEvents.length }} active competitions on CUET campus</p>
            </div>

            <div v-if="searchQuery || selectedCategory !== 'ALL' || selectedStatus !== 'ALL'" class="flex items-center gap-2">
              <button 
                @click="searchQuery = ''; selectedCategory = 'ALL'; selectedStatus = 'ALL'"
                class="text-xs text-blue-700 hover:underline font-bold"
              >
                Clear Filters
              </button>
            </div>
          </div>

          <!-- Events Grid -->
          <div v-if="filteredEvents.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <EventCard
              v-for="event in filteredEvents"
              :key="event.id"
              :event="event"
              @select="handleSelectEvent"
              @register="handleRegisterEvent"
            />
          </div>

          <!-- Fallback when no events match filter -->
          <div v-else class="glass-panel p-12 text-center space-y-4 bg-white">
            <Search class="w-12 h-12 text-slate-400 mx-auto" />
            <h3 class="text-lg font-bold text-slate-900">No Matching Events Found</h3>
            <p class="text-xs text-slate-500">Try adjusting your search query or switching category filters.</p>
            <button @click="searchQuery = ''; selectedCategory = 'ALL'" class="glass-button text-xs py-2 px-5">
              Reset Filters
            </button>
          </div>
        </section>

        <!-- Section 2: Visual Event Workflow Step Diagram -->
        <section class="bg-slate-100 border-y border-slate-200/80 py-12 px-4 sm:px-6 lg:px-8">
          <div class="max-w-7xl mx-auto space-y-8">
            <div class="text-center max-w-2xl mx-auto space-y-2">
              <span class="px-3 py-1 rounded-full bg-blue-100 text-blue-800 text-xs font-bold">
                Registration System Workflow
              </span>
              <h2 class="text-2xl sm:text-3xl font-extrabold text-slate-900">How EventX Works for Students</h2>
              <p class="text-xs sm:text-sm text-slate-600">Complete 4 simple steps to enter campus competitions and receive entry passes.</p>
            </div>

            <!-- Workflow Diagram Cards -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              
              <div class="glass-panel p-5 bg-white border-slate-200 space-y-3 relative">
                <div class="w-8 h-8 rounded-lg bg-blue-50 text-blue-700 font-bold text-xs flex items-center justify-center border border-blue-200">
                  01
                </div>
                <h3 class="font-bold text-sm text-slate-900">Select Event & Segment</h3>
                <p class="text-xs text-slate-600 leading-relaxed">
                  Browse active hackathons or bot wars and choose your competition segment.
                </p>
              </div>

              <div class="glass-panel p-5 bg-white border-slate-200 space-y-3 relative">
                <div class="w-8 h-8 rounded-lg bg-indigo-50 text-indigo-700 font-bold text-xs flex items-center justify-center border border-indigo-200">
                  02
                </div>
                <h3 class="font-bold text-sm text-slate-900">Submit Team Roster</h3>
                <p class="text-xs text-slate-600 leading-relaxed">
                  Enter team name, member student IDs, department, and T-shirt sizes.
                </p>
              </div>

              <div class="glass-panel p-5 bg-white border-slate-200 space-y-3 relative">
                <div class="w-8 h-8 rounded-lg bg-amber-50 text-amber-700 font-bold text-xs flex items-center justify-center border border-amber-200">
                  03
                </div>
                <h3 class="font-bold text-sm text-slate-900">Mobile TrxID Payment</h3>
                <p class="text-xs text-slate-600 leading-relaxed">
                  Pay registration fee via bKash or Nagad merchant number and provide TrxID.
                </p>
              </div>

              <div class="glass-panel p-5 bg-white border-slate-200 space-y-3 relative">
                <div class="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-700 font-bold text-xs flex items-center justify-center border border-emerald-200">
                  04
                </div>
                <h3 class="font-bold text-sm text-slate-900">Get Digital QR Pass</h3>
                <p class="text-xs text-slate-600 leading-relaxed">
                  Instantly receive digital QR ticket pass for entry check-in at auditorium gates.
                </p>
              </div>

            </div>
          </div>
        </section>

        <!-- Section 3: Registered Societies & Clubs Spotlight Grid -->
        <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16 space-y-6">
          <div class="flex items-center justify-between border-b border-slate-200 pb-3">
            <div>
              <h2 class="text-xl sm:text-2xl font-black text-slate-900 flex items-center gap-2">
                <Users class="w-5 h-5 text-blue-700" />
                <span>Recognized CUET Societies & Organizers</span>
              </h2>
              <p class="text-xs text-slate-500 mt-0.5">Official student societies managing competitions on campus</p>
            </div>

            <button @click="handleNavigateView('clubs')" class="text-xs text-blue-700 font-bold hover:underline flex items-center gap-1">
              <span>View All Societies</span>
              <ArrowRight class="w-3.5 h-3.5" />
            </button>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div
              v-for="c in clubs"
              :key="c.id"
              @click="handleSelectClubEvents(c.name)"
              class="glass-panel p-4 border-slate-200 hover:border-blue-400 cursor-pointer transition-all flex items-center gap-3 rounded-xl bg-white shadow-2xs"
            >
              <img :src="c.logoUrl" :alt="c.name" class="w-12 h-12 rounded-xl object-cover border border-slate-200" />
              <div>
                <h4 class="font-bold text-sm text-slate-900 line-clamp-1">{{ c.name }}</h4>
                <p class="text-[11px] text-slate-500 font-medium font-mono">{{ c.membersCount }}+ Members</p>
              </div>
            </div>
          </div>
        </section>

      </div>

      <!-- View 2: Campus Venues & Schedule Map -->
      <CampusVenuesView
        v-else-if="currentView === 'venues'"
        :buildings="buildings"
        :events="events"
      />

      <!-- View 3: Clubs & Societies -->
      <ClubsView
        v-else-if="currentView === 'clubs'"
        :clubs="clubs"
        @selectClubEvents="handleSelectClubEvents"
      />

      <!-- View 4: Student Dashboard -->
      <StudentDashboard
        v-else-if="currentView === 'dashboard'"
        :registrations="registrations"
        @navigate="handleNavigateView($event)"
      />

      <!-- View 5: Organizer & Admin Portal -->
      <OrganizerDashboard
        v-else-if="currentView === 'organizer'"
        :events="events"
        :registrations="registrations"
        @createEvent="handleCreateEvent"
        @updateRegistrationStatus="handleUpdateRegistrationStatus"
      />

    </main>

    <!-- Site Footer -->
    <Footer />

    <!-- Modals -->
    <VolunteerModal
      v-if="selectedEventForVolunteer"
      :event="selectedEventForVolunteer"
      @close="selectedEventForVolunteer = null"
      @submitted="showToast('Volunteer Application Received', 'Thank you for volunteering!', 'success')"
    />

  </div>
</template>
