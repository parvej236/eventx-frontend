<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { 
  Calendar, MapPin, Trophy, Users, ShieldCheck, ArrowLeft, Clock, 
  Layers, Award, FileText, CheckCircle2, ChevronRight, Share2, 
  Sparkles, Building, Lock, AlertCircle, ArrowUpRight, Timer, Ticket
} from 'lucide-vue-next'

const props = defineProps({
  event: Object
})

const emit = defineEmits(['back', 'registerSegment', 'applyVolunteer'])

const activeTab = ref('segments')
const isUserLoggedIn = ref(false)

// Live Countdown Timer State
const countdown = ref({
  days: 0,
  hours: 0,
  minutes: 0,
  seconds: 0,
  isExpired: false,
  label: 'Registration Ends In'
})

let timerInterval = null

const calculateCountdown = () => {
  let targetStr = props.event?.regEnd || props.event?.reg_end || props.event?.startAt || props.event?.start_at
  let targetDate = targetStr ? new Date(targetStr) : new Date(Date.now() + 5 * 86400000)
  
  if (isNaN(targetDate.getTime())) {
    targetDate = new Date(Date.now() + 5 * 86400000)
  }

  const now = new Date().getTime()
  const distance = targetDate.getTime() - now

  if (distance <= 0) {
    countdown.value = { days: 0, hours: 0, minutes: 0, seconds: 0, isExpired: true, label: 'Registration Period Closed' }
  } else {
    const days = Math.floor(distance / (1000 * 60 * 60 * 24))
    const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((distance % (1000 * 60)) / 1000)

    const isRegTarget = !!(props.event?.regEnd || props.event?.reg_end)
    countdown.value = {
      days,
      hours,
      minutes,
      seconds,
      isExpired: false,
      label: isRegTarget ? 'Registration Closes In' : 'Event Starts In'
    }
  }
}

onMounted(() => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
  try {
    const u = localStorage.getItem('user') || localStorage.getItem('eventx_user') || localStorage.getItem('currentUser')
    isUserLoggedIn.value = !!u && u !== 'null'
  } catch (e) {
    isUserLoggedIn.value = false
  }

  calculateCountdown()
  timerInterval = setInterval(calculateCountdown, 1000)
})

onUnmounted(() => {
  if (timerInterval) clearInterval(timerInterval)
})

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-BD', { style: 'currency', currency: 'BDT', maximumFractionDigits: 0 }).format(amount || 0)
}

const formatDate = (dateStr) => {
  if (!dateStr) return 'TBA'
  return new Date(dateStr).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })
}

const getStatusBadge = (status) => {
  switch (status?.toUpperCase()) {
    case 'LIVE NOW':
    case 'LIVE':
      return { class: 'bg-rose-500 text-white shadow-rose-500/30', label: '🔴 Live Now' }
    case 'REGISTRATION OPEN':
      return { class: 'bg-emerald-500 text-white shadow-emerald-500/30', label: '🟢 Registration Open' }
    case 'ENDED':
      return { class: 'bg-slate-700 text-white', label: '⚪ Completed' }
    default:
      return { class: 'bg-amber-500 text-slate-950', label: '⏳ Upcoming' }
  }
}
</script>

<template>
  <div class="pt-24 pb-16 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto space-y-8 animate-fadeIn">
    
    <!-- Top Navigation Bar -->
    <div class="flex items-center justify-between border-b border-slate-200 pb-4">
      <button 
        @click="emit('back')" 
        class="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-800 font-bold text-xs rounded-xl flex items-center justify-center gap-2 transition-all shadow-xs"
      >
        <ArrowLeft class="w-4 h-4 shrink-0" />
        <span>Back to All Competitions</span>
      </button>

      <div class="flex items-center gap-2 text-xs text-slate-500 font-semibold hidden sm:flex">
        <span>Home</span>
        <ChevronRight class="w-3.5 h-3.5 text-slate-400" />
        <span>Events</span>
        <ChevronRight class="w-3.5 h-3.5 text-slate-400" />
        <span class="text-blue-700 font-bold line-clamp-1">{{ event?.name }}</span>
      </div>
    </div>

    <!-- Login Requirement Banner (Shown if guest student is viewing) -->
    <div v-if="!isUserLoggedIn" class="p-4 rounded-2xl bg-amber-50 border border-amber-200 flex flex-col sm:flex-row items-center justify-between gap-4 shadow-sm">
      <div class="flex items-center gap-3">
        <div class="p-2.5 rounded-xl bg-amber-100 text-amber-800 shrink-0">
          <Lock class="w-5 h-5" />
        </div>
        <div>
          <h4 class="font-extrabold text-sm text-slate-900">Sign In Required to Register</h4>
          <p class="text-xs text-slate-600">You can explore competition details, but logging into your student account is required before submitting segment registrations.</p>
        </div>
      </div>
      
      <router-link 
        to="/auth?tab=login" 
        class="px-5 py-2.5 bg-blue-700 hover:bg-blue-600 text-white font-extrabold text-xs rounded-xl flex items-center justify-center gap-1.5 shrink-0 shadow-md shadow-blue-700/20"
      >
        <span>Sign In Now</span>
        <ArrowUpRight class="w-4 h-4 shrink-0" />
      </router-link>
    </div>

    <!-- Hero Event Banner Header Page Section -->
    <div class="glass-panel overflow-hidden border-slate-200 bg-slate-900 rounded-3xl shadow-xl relative">
      <div class="h-80 sm:h-96 relative overflow-hidden">
        <img
          v-if="event?.bannerUrl || event?.banner_url"
          :src="event.bannerUrl || event.banner_url"
          :alt="event.name"
          class="w-full h-full object-cover opacity-75 scale-100 hover:scale-105 transition-transform duration-700"
        />
        <div v-else class="w-full h-full bg-gradient-to-r from-blue-900 via-slate-900 to-slate-950"></div>

        <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/60 to-transparent"></div>

        <!-- Floating Badges & Top Countdown Chip -->
        <div class="absolute top-6 left-6 right-6 flex items-center justify-between z-10 flex-wrap gap-2">
          <div class="flex items-center gap-2">
            <span :class="[getStatusBadge(event?.status).class, 'px-3.5 py-1.5 rounded-xl text-xs font-black uppercase tracking-wider shadow-lg']">
              {{ getStatusBadge(event?.status).label }}
            </span>
            <span class="px-3.5 py-1.5 rounded-xl bg-slate-900/90 text-white text-xs font-extrabold backdrop-blur-md border border-white/20 shadow-md">
              {{ event?.category || 'National Competition' }}
            </span>
          </div>

          <!-- Live Timer Badge Pill -->
          <div class="px-3.5 py-1.5 rounded-xl bg-slate-950/90 border border-slate-700/80 text-amber-400 text-xs font-mono font-bold flex items-center gap-2 shadow-lg backdrop-blur-md">
            <Timer class="w-4 h-4 text-rose-400 animate-pulse" />
            <span>{{ countdown.days }}d {{ countdown.hours }}h {{ countdown.minutes }}m {{ countdown.seconds }}s</span>
          </div>
        </div>

        <!-- Banner Overlaid Details -->
        <div class="absolute bottom-8 left-6 right-6 z-10 text-white space-y-3">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/20 backdrop-blur-md border border-blue-400/30 text-amber-300 text-xs font-bold">
            <Building class="w-4 h-4 text-amber-400 shrink-0" />
            <span>Organized by {{ event?.organizerClub || 'CUET Central Executive Committee' }}</span>
          </div>

          <h1 class="text-3xl sm:text-5xl font-black text-white tracking-tight leading-tight drop-shadow-md">
            {{ event?.name }}
          </h1>

          <div class="flex flex-wrap items-center gap-6 text-xs text-slate-200 pt-2 font-medium">
            <div class="flex items-center gap-2 font-black font-mono text-amber-400 text-sm sm:text-base">
              <Trophy class="w-5 h-5 text-amber-400 shrink-0" />
              <span>Prize Pool: {{ formatCurrency(event?.prizePool || event?.prize_pool) }}</span>
            </div>

            <div class="flex items-center gap-2 text-slate-300">
              <Calendar class="w-4 h-4 text-blue-400 shrink-0" />
              <span>Date: {{ formatDate(event?.startAt || event?.start_at) }}</span>
            </div>

            <div class="flex items-center gap-2 text-slate-300">
              <MapPin class="w-4 h-4 text-rose-400 shrink-0" />
              <span>Venue: {{ event?.venueName || event?.building_name || 'CUET Auditorium & Campus' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">
      
      <!-- Left Column: Tabs Navigation & Detailed Information -->
      <div class="lg:col-span-8 space-y-6">
        
        <!-- Tab Headers Bar -->
        <div class="flex items-center gap-3 border-b border-slate-200 pb-2 overflow-x-auto text-xs font-bold">
          <button
            @click="activeTab = 'segments'"
            :class="[
              activeTab === 'segments' ? 'border-blue-700 text-blue-700 bg-blue-50/80 border-b-2' : 'text-slate-600 hover:text-slate-900 bg-slate-100',
              'px-5 py-2.5 rounded-xl flex items-center justify-center gap-2 whitespace-nowrap transition-all'
            ]"
          >
            <Layers class="w-4 h-4 shrink-0" />
            <span>Segments & Rules</span>
          </button>

          <button
            @click="activeTab = 'regulations'"
            :class="[
              activeTab === 'regulations' ? 'border-blue-700 text-blue-700 bg-blue-50/80 border-b-2' : 'text-slate-600 hover:text-slate-900 bg-slate-100',
              'px-5 py-2.5 rounded-xl flex items-center justify-center gap-2 whitespace-nowrap transition-all'
            ]"
          >
            <FileText class="w-4 h-4 shrink-0" />
            <span>General Regulations</span>
          </button>

          <button
            @click="activeTab = 'venue'"
            :class="[
              activeTab === 'venue' ? 'border-blue-700 text-blue-700 bg-blue-50/80 border-b-2' : 'text-slate-600 hover:text-slate-900 bg-slate-100',
              'px-5 py-2.5 rounded-xl flex items-center justify-center gap-2 whitespace-nowrap transition-all'
            ]"
          >
            <MapPin class="w-4 h-4 shrink-0" />
            <span>Venue & Schedule</span>
          </button>
        </div>

        <!-- Tab 1: Segments & Description -->
        <div v-if="activeTab === 'segments'" class="space-y-6">
          
          <!-- Event Description Box -->
          <div class="glass-panel p-6 bg-white border-slate-200 rounded-2xl space-y-3 shadow-xs">
            <h3 class="font-black text-slate-900 text-lg flex items-center gap-2">
              <Sparkles class="w-5 h-5 text-blue-700" />
              <span>About This Event</span>
            </h3>
            <p class="text-xs sm:text-sm text-slate-600 leading-relaxed font-normal">
              {{ event?.description }}
            </p>
          </div>

          <!-- Segments List Title -->
          <div class="flex items-center justify-between pt-2">
            <h3 class="font-black text-slate-900 text-xl flex items-center gap-2">
              <Award class="w-5 h-5 text-amber-600" />
              <span>Available Segments ({{ event?.segments?.length || 1 }})</span>
            </h3>
            <span class="text-xs text-slate-500 font-semibold">Select a segment to register</span>
          </div>

          <!-- Segment Cards -->
          <div class="space-y-4">
            <div
              v-for="seg in (event?.segments || [])"
              :key="seg.id || seg.segment_id"
              class="glass-panel p-6 bg-white border-slate-200 hover:border-blue-400 transition-all rounded-2xl space-y-4 shadow-sm group"
            >
              <div class="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                <div class="space-y-1">
                  <div class="flex items-center gap-2">
                    <h4 class="font-black text-slate-900 text-xl group-hover:text-blue-700 transition-colors">{{ seg.title }}</h4>
                    <span class="px-2.5 py-0.5 rounded-lg bg-blue-100 text-blue-800 text-xs font-bold border border-blue-200">
                      {{ seg.type }}
                    </span>
                  </div>
                  <p class="text-xs text-slate-600 leading-relaxed max-w-xl">{{ seg.description }}</p>
                </div>

                <div class="text-left sm:text-right shrink-0 bg-amber-50/80 p-3 rounded-xl border border-amber-200">
                  <div class="text-[11px] text-amber-800 font-bold uppercase tracking-wider">Segment Prize</div>
                  <div class="text-xl font-black text-amber-700 font-mono">৳ {{ (seg.prize || 0).toLocaleString() }}</div>
                </div>
              </div>

              <!-- Metrics Metadata Bar -->
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 text-xs">
                <div>
                  <span class="text-slate-500 block text-[10px] font-bold uppercase">Registration Fee</span>
                  <span class="font-black text-blue-700 font-mono text-sm">৳ {{ seg.regFee || seg.reg_fee || 0 }}</span>
                </div>
                <div>
                  <span class="text-slate-500 block text-[10px] font-bold uppercase">Team Size</span>
                  <span class="font-bold text-slate-900 font-mono">Max {{ seg.maxTeamSize || 4 }} Members</span>
                </div>
                <div>
                  <span class="text-slate-500 block text-[10px] font-bold uppercase">Status</span>
                  <span class="font-extrabold text-emerald-700 flex items-center gap-1">
                    <CheckCircle2 class="w-3.5 h-3.5" />
                    <span>Open For Registration</span>
                  </span>
                </div>
              </div>

              <!-- Register Action CTA Button -->
              <div class="pt-2 flex justify-end">
                <button
                  @click="emit('registerSegment', { event, segment: seg })"
                  class="px-6 py-2.5 bg-blue-700 hover:bg-blue-600 text-white font-extrabold text-xs rounded-xl shadow-md shadow-blue-700/20 flex items-center justify-center gap-2 whitespace-nowrap hover:scale-[1.02] transition-all"
                >
                  <span>Register for {{ seg.title }}</span>
                  <ChevronRight class="w-4 h-4 shrink-0" />
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Tab 2: General Regulations -->
        <div v-else-if="activeTab === 'regulations'" class="glass-panel p-6 bg-white border-slate-200 rounded-2xl space-y-4 shadow-xs">
          <h3 class="font-black text-slate-900 text-lg flex items-center gap-2">
            <ShieldCheck class="w-5 h-5 text-blue-700" />
            <span>Official CUET Participation Rules</span>
          </h3>
          
          <ul class="space-y-3.5 text-xs sm:text-sm text-slate-700">
            <li class="flex items-start gap-3 p-3 rounded-xl bg-slate-50 border border-slate-200/60">
              <CheckCircle2 class="w-4 h-4 text-blue-700 shrink-0 mt-0.5" />
              <span>All team members must hold valid university student ID cards upon venue entry check-in.</span>
            </li>
            <li class="flex items-start gap-3 p-3 rounded-xl bg-slate-50 border border-slate-200/60">
              <CheckCircle2 class="w-4 h-4 text-blue-700 shrink-0 mt-0.5" />
              <span>Cross-university team rosters are permitted only for specified national open hackathons.</span>
            </li>
            <li class="flex items-start gap-3 p-3 rounded-xl bg-slate-50 border border-slate-200/60">
              <CheckCircle2 class="w-4 h-4 text-blue-700 shrink-0 mt-0.5" />
              <span>Mobile banking bKash/Nagad payment transaction IDs (TrxID) will be verified by executive committee organizers.</span>
            </li>
            <li class="flex items-start gap-3 p-3 rounded-xl bg-slate-50 border border-slate-200/60">
              <CheckCircle2 class="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
              <span>Code plagiarism or unauthorized library use during live hackathons results in instant disqualification.</span>
            </li>
          </ul>
        </div>

        <!-- Tab 3: Venue Info -->
        <div v-else-if="activeTab === 'venue'" class="glass-panel p-6 bg-white border-slate-200 rounded-2xl space-y-4 shadow-xs">
          <h3 class="font-black text-slate-900 text-lg flex items-center gap-2">
            <MapPin class="w-5 h-5 text-rose-600" />
            <span>Campus Venue & Schedule</span>
          </h3>
          
          <div class="p-5 rounded-2xl bg-slate-50 border border-slate-200 space-y-3 text-xs sm:text-sm text-slate-700">
            <div class="flex justify-between items-center border-b border-slate-200/80 pb-2">
              <span class="text-slate-500 font-semibold">Assigned Venue Building:</span>
              <span class="font-extrabold text-slate-900">{{ event?.venueName || event?.building_name || 'CSE Academic Building' }}</span>
            </div>
            <div class="flex justify-between items-center border-b border-slate-200/80 pb-2">
              <span class="text-slate-500 font-semibold">Campus Address:</span>
              <span class="font-extrabold text-slate-900">CUET Campus, Raozan, Chittagong-4349</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-slate-500 font-semibold">High-Speed Wi-Fi Network:</span>
              <span class="font-extrabold text-emerald-700">Gigabit Campus Fiber Available</span>
            </div>
          </div>
        </div>

      </div>

      <!-- Right Column: Live Countdown Card & Quick Overview -->
      <div class="lg:col-span-4 space-y-6">
        
        <!-- DEDICATED LIVE COUNTDOWN TIMER CARD -->
        <div class="p-6 bg-slate-950 border border-slate-800 rounded-3xl text-white shadow-2xl space-y-4 relative overflow-hidden">
          <div class="absolute -right-10 -bottom-10 w-40 h-40 bg-blue-600/20 rounded-full blur-3xl pointer-events-none"></div>

          <div class="flex items-center justify-between border-b border-slate-800 pb-3">
            <div class="flex items-center gap-2 text-rose-400 font-extrabold text-xs uppercase tracking-wider">
              <Clock class="w-4 h-4 animate-pulse" />
              <span>{{ countdown.label }}</span>
            </div>
            <span v-if="!countdown.isExpired" class="flex h-2.5 w-2.5 relative">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-rose-400 opacity-75"></span>
              <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-rose-500"></span>
            </span>
          </div>

          <!-- Digital Clock Grid Display -->
          <div v-if="!countdown.isExpired" class="grid grid-cols-4 gap-2 text-center font-mono">
            <div class="bg-slate-900/90 p-3 rounded-2xl border border-slate-800">
              <div class="text-xl sm:text-2xl font-black text-amber-400">{{ String(countdown.days).padStart(2, '0') }}</div>
              <div class="text-[9px] text-slate-400 font-sans uppercase font-extrabold mt-0.5">Days</div>
            </div>

            <div class="bg-slate-900/90 p-3 rounded-2xl border border-slate-800">
              <div class="text-xl sm:text-2xl font-black text-amber-400">{{ String(countdown.hours).padStart(2, '0') }}</div>
              <div class="text-[9px] text-slate-400 font-sans uppercase font-extrabold mt-0.5">Hours</div>
            </div>

            <div class="bg-slate-900/90 p-3 rounded-2xl border border-slate-800">
              <div class="text-xl sm:text-2xl font-black text-amber-400">{{ String(countdown.minutes).padStart(2, '0') }}</div>
              <div class="text-[9px] text-slate-400 font-sans uppercase font-extrabold mt-0.5">Mins</div>
            </div>

            <div class="bg-slate-900/90 p-3 rounded-2xl border border-slate-800">
              <div class="text-xl sm:text-2xl font-black text-rose-400">{{ String(countdown.seconds).padStart(2, '0') }}</div>
              <div class="text-[9px] text-slate-400 font-sans uppercase font-extrabold mt-0.5">Secs</div>
            </div>
          </div>

          <div v-else class="p-3 bg-rose-950/60 border border-rose-900/80 rounded-xl text-center text-xs font-bold text-rose-300">
            Registration has ended for this competition.
          </div>
        </div>

        <!-- Quick Overview Card -->
        <div class="glass-panel p-6 bg-white border-slate-200 rounded-3xl space-y-6 shadow-md sticky top-24">
          
          <div class="p-4 rounded-2xl bg-gradient-to-br from-amber-50 to-orange-50 border border-amber-200 text-center">
            <span class="text-xs text-amber-800 font-bold uppercase tracking-wider block">Total Prize Allocation</span>
            <div class="text-3xl font-black text-amber-700 font-mono mt-1">
              {{ formatCurrency(event?.prizePool || event?.prize_pool) }}
            </div>
          </div>

          <div class="space-y-3 text-xs border-t border-b border-slate-100 py-4">
            <div class="flex justify-between items-center">
              <span class="text-slate-500 font-medium">Organizing Society:</span>
              <span class="font-bold text-slate-900">{{ event?.organizerClub || 'CUET Central' }}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-slate-500 font-medium">Event Date:</span>
              <span class="font-bold text-slate-900">{{ formatDate(event?.startAt || event?.start_at) }}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-slate-500 font-medium">Total Segments:</span>
              <span class="font-bold text-blue-700 font-mono">{{ event?.segments?.length || 1 }} Segments</span>
            </div>
          </div>

          <div class="space-y-3">
            <button
              @click="emit('registerSegment', { event, segment: event?.segments?.[0] })"
              class="w-full py-3 bg-blue-700 hover:bg-blue-600 text-white font-extrabold text-xs rounded-xl shadow-md shadow-blue-700/20 flex items-center justify-center gap-2 whitespace-nowrap"
            >
              <Ticket class="w-4 h-4 shrink-0" />
              <span>Register For Event</span>
            </button>

            <button
              @click="emit('applyVolunteer', event)"
              class="px-4 py-2.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-extrabold text-xs w-full rounded-xl border border-indigo-200 flex items-center justify-center gap-2 whitespace-nowrap transition-all"
            >
              <Users class="w-4 h-4 text-indigo-600 shrink-0" />
              <span>Apply as Event Volunteer</span>
            </button>
          </div>

        </div>
      </div>

    </div>

  </div>
</template>
