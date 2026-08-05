<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { 
  Search, Trophy, Users, Calendar, Award, PlusCircle, Filter, 
  ArrowRight, Zap, ShieldCheck, QrCode, MapPin, Building, Clock, 
  Sparkles, ChevronLeft, ChevronRight, CheckCircle2, Ticket
} from 'lucide-vue-next'

const props = defineProps({
  searchQuery: String,
  selectedCategory: String,
  selectedStatus: String,
  totalEventsCount: Number,
  totalPrizePool: Number,
  events: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits([
  'update:searchQuery', 
  'update:selectedCategory', 
  'update:selectedStatus',
  'openCreateModal', 
  'selectEvent', 
  'registerEvent'
])

const categories = [
  { id: 'ALL', label: 'All Categories' },
  { id: 'Hackathon', label: 'Hackathons' },
  { id: 'Robotics', label: 'Robotics' },
  { id: 'Cultural', label: 'Cultural' },
  { id: 'Gaming', label: 'Gaming' }
]

const statusTabs = [
  { id: 'ALL', label: 'All Competitions', badgeClass: 'bg-slate-200 text-slate-800' },
  { id: 'LIVE NOW', label: 'LIVE NOW', badgeClass: 'bg-rose-500 text-white animate-pulse' },
  { id: 'REGISTRATION OPEN', label: 'Registration Open', badgeClass: 'bg-emerald-500 text-white' },
  { id: 'UPCOMING', label: 'Upcoming', badgeClass: 'bg-blue-500 text-white' }
]

// Ongoing / Active events carousel state
const activeSlideIndex = ref(0)
let autoplayTimer = null

const featuredEvents = computed(() => {
  if (props.events && props.events.length > 0) {
    return props.events
  }
  return [
    {
      id: 1,
      name: 'CUET TechFest & National Hackathon 2026',
      description: 'Flagship national technology festival featuring 24-hour AI hackathon, IUPC competitive programming, and software exhibition.',
      prizePool: 100000,
      bannerUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=80',
      status: 'REGISTRATION OPEN',
      organizerClub: 'CUET Computer Club',
      buildingName: 'CSE Building, CUET'
    },
    {
      id: 2,
      name: 'RoboClash & MechaWars Arena 2026',
      description: 'High-adrenaline autonomous line follower (LFR), wireless bot soccer battles, and heavyweight sumo warfare.',
      prizePool: 65000,
      bannerUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=1200&q=80',
      status: 'REGISTRATION OPEN',
      organizerClub: 'CUET Robotics Society',
      buildingName: 'Electrical & Electronics Building'
    },
    {
      id: 5,
      name: 'Inter-Dept Esports Championship 2026',
      description: 'Competitive LAN gaming tournament across Valorant 5v5, PUBG Mobile, and FC 25.',
      prizePool: 50000,
      bannerUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=1200&q=80',
      status: 'LIVE NOW',
      organizerClub: 'CUET Gaming Guild',
      buildingName: 'Student Recreation Center'
    }
  ]
})

const currentSlide = computed(() => {
  const list = featuredEvents.value
  if (list.length === 0) return null
  return list[activeSlideIndex.value % list.length]
})

const nextSlide = () => {
  if (featuredEvents.value.length === 0) return
  activeSlideIndex.value = (activeSlideIndex.value + 1) % featuredEvents.value.length
}

const prevSlide = () => {
  if (featuredEvents.value.length === 0) return
  activeSlideIndex.value = (activeSlideIndex.value - 1 + featuredEvents.value.length) % featuredEvents.value.length
}

const goToSlide = (idx) => {
  activeSlideIndex.value = idx
}

const startAutoplay = () => {
  stopAutoplay()
  autoplayTimer = setInterval(() => {
    nextSlide()
  }, 4500)
}

const stopAutoplay = () => {
  if (autoplayTimer) {
    clearInterval(autoplayTimer)
    autoplayTimer = null
  }
}

onMounted(() => {
  startAutoplay()
})

onUnmounted(() => {
  stopAutoplay()
})

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-BD', { style: 'currency', currency: 'BDT', maximumFractionDigits: 0 }).format(amount || 100000)
}
</script>

<template>
  <section class="pt-24 pb-3 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto space-y-4">
    
    <!-- Hero Banner Layout -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
      
      <!-- Left Column: Copy & CTAs -->
      <div class="lg:col-span-7 space-y-6 text-left">
        
        <!-- Campus Badge -->
        <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-blue-50 border border-blue-200 text-blue-800 text-xs font-bold shadow-xs">
          <Building class="w-4 h-4 text-blue-700" />
          <span>Chittagong University of Engineering & Technology</span>
        </div>

        <!-- Main Headline -->
        <h1 class="text-3xl sm:text-5xl font-black text-slate-900 tracking-tight leading-tight">
          <span class="text-blue-700 block">EventX CUET</span>
          <span>Event Management System</span>
        </h1>

        <!-- Subtitle -->
        <p class="text-slate-600 text-sm sm:text-base leading-relaxed max-w-xl">
          Empowering national hackathons, robotics championships, and cultural festivals. Browse live events, submit team rosters, pay via bKash/Nagad, and receive instant digital QR passes.
        </p>

        <!-- Action CTAs -->
        <div class="flex flex-wrap items-center gap-3 pt-1">
          <a 
            href="#explore-events"
            class="px-6 py-3 bg-blue-700 hover:bg-blue-600 text-white font-extrabold text-xs sm:text-sm rounded-2xl shadow-lg shadow-blue-700/30 transition-all flex items-center justify-center gap-2 whitespace-nowrap"
          >
            <span>Explore Events</span>
            <ArrowRight class="w-4 h-4 shrink-0" />
          </a>

          <button 
            @click="emit('openCreateModal')"
            class="px-6 py-3 bg-white hover:bg-slate-100 text-slate-800 border border-slate-300 font-extrabold text-xs sm:text-sm rounded-2xl shadow-sm transition-all flex items-center justify-center gap-2 whitespace-nowrap"
          >
            <PlusCircle class="w-4 h-4 shrink-0 text-blue-700" />
            <span>Host New Event</span>
          </button>
        </div>

        <!-- Key Feature Indicators -->
        <div class="grid grid-cols-3 gap-3 pt-3 border-t border-slate-200 text-xs text-slate-600 font-semibold">
          <div class="flex items-center gap-1.5">
            <Zap class="w-4 h-4 text-blue-700 shrink-0" />
            <span>bKash/Nagad Payment</span>
          </div>
          <div class="flex items-center gap-1.5">
            <QrCode class="w-4 h-4 text-emerald-700 shrink-0" />
            <span>Digital QR Passes</span>
          </div>
          <div class="flex items-center gap-1.5">
            <ShieldCheck class="w-4 h-4 text-indigo-700 shrink-0" />
            <span>Verified CUET Clubs</span>
          </div>
        </div>

      </div>

      <!-- Right Column: AUTO-ROTATING ONGOING EVENT CAROUSEL -->
      <div class="lg:col-span-5">
        <div 
          @mouseenter="stopAutoplay"
          @mouseleave="startAutoplay"
          class="relative bg-slate-900 border border-slate-800 rounded-3xl overflow-hidden shadow-2xl group transition-all"
        >
          
          <div v-if="currentSlide" class="relative h-96 flex flex-col justify-between p-6">
            
            <!-- Background Image with Dark Overlay -->
            <img 
              :key="currentSlide.id"
              :src="currentSlide.bannerUrl || currentSlide.banner_url || 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=80'" 
              :alt="currentSlide.name"
              class="absolute inset-0 w-full h-full object-cover transition-opacity duration-700 opacity-55 group-hover:scale-105 transition-transform"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/60 to-slate-900/30"></div>

            <!-- Top Header Badge & Navigation Controls -->
            <div class="relative z-10 flex items-center justify-between">
              <span :class="[
                (currentSlide.status || '').toUpperCase() === 'LIVE NOW' ? 'bg-rose-600 text-white animate-pulse' :
                (currentSlide.status || '').toUpperCase() === 'REGISTRATION OPEN' ? 'bg-emerald-600 text-white' :
                'bg-blue-600 text-white',
                'px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider shadow-md flex items-center gap-1.5'
              ]">
                <Sparkles class="w-3 h-3" />
                <span>{{ currentSlide.status || 'FEATURED EVENT' }}</span>
              </span>

              <!-- Prev / Next Controls -->
              <div class="flex items-center gap-1.5 bg-slate-950/70 backdrop-blur-md p-1 rounded-full border border-slate-700/60">
                <button 
                  @click="prevSlide" 
                  class="p-1.5 rounded-full hover:bg-slate-800 text-slate-300 hover:text-white transition-colors"
                  title="Previous Event"
                >
                  <ChevronLeft class="w-4 h-4" />
                </button>
                <button 
                  @click="nextSlide" 
                  class="p-1.5 rounded-full hover:bg-slate-800 text-slate-300 hover:text-white transition-colors"
                  title="Next Event"
                >
                  <ChevronRight class="w-4 h-4" />
                </button>
              </div>
            </div>

            <!-- Middle Content: Details & Prize -->
            <div class="relative z-10 space-y-2 mt-auto">
              <div class="text-[11px] text-blue-400 font-mono font-bold flex items-center gap-1.5">
                <Building class="w-3.5 h-3.5" />
                <span>{{ currentSlide.organizerClub || currentSlide.clubName || 'CUET Campus Society' }}</span>
              </div>

              <h3 class="text-xl sm:text-2xl font-black text-white leading-tight line-clamp-2">
                {{ currentSlide.name }}
              </h3>

              <p class="text-xs text-slate-300 line-clamp-2 leading-relaxed">
                {{ currentSlide.description }}
              </p>

              <div class="flex items-center justify-between pt-2 border-t border-slate-800/80 text-xs">
                <div class="flex items-center gap-1.5 text-amber-400 font-mono font-bold">
                  <Trophy class="w-4 h-4 text-amber-400" />
                  <span>Prize Pool: ৳ {{ (currentSlide.prizePool || currentSlide.prize_pool || 50000).toLocaleString() }}</span>
                </div>

                <div class="flex items-center gap-1 text-slate-400 text-[11px]">
                  <MapPin class="w-3.5 h-3.5 text-rose-400 shrink-0" />
                  <span class="line-clamp-1">{{ currentSlide.buildingName || currentSlide.building_name || 'CUET Campus' }}</span>
                </div>
              </div>

              <!-- Action Buttons directly on Slide -->
              <div class="flex items-center gap-2 pt-2">
                <button 
                  @click="emit('registerEvent', currentSlide)"
                  class="flex-1 py-2.5 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-extrabold text-xs rounded-xl shadow-lg transition-all flex items-center justify-center gap-1.5"
                >
                  <Ticket class="w-4 h-4" />
                  <span>Register Now</span>
                </button>

                <button 
                  @click="emit('selectEvent', currentSlide)"
                  class="px-4 py-2.5 bg-slate-800/90 hover:bg-slate-700 text-white font-extrabold text-xs rounded-xl border border-slate-700 transition-all flex items-center gap-1"
                >
                  <span>Details</span>
                  <ArrowRight class="w-3.5 h-3.5" />
                </button>
              </div>
            </div>

            <!-- Slide Indicator Dots -->
            <div class="relative z-10 flex items-center justify-center gap-1.5 pt-3">
              <button 
                v-for="(evt, idx) in featuredEvents" 
                :key="evt.id || idx"
                @click="goToSlide(idx)"
                :class="[
                  idx === activeSlideIndex % featuredEvents.length
                    ? 'w-6 bg-blue-500' 
                    : 'w-2 bg-slate-700 hover:bg-slate-500',
                  'h-2 rounded-full transition-all duration-300'
                ]"
              ></button>
            </div>

          </div>

        </div>
      </div>

    </div>

    <!-- Metric Stat Cards Bar -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-left">
      <div class="glass-panel p-4 flex items-center gap-3 border-l-4 border-l-amber-600 bg-white">
        <div class="p-2.5 rounded-xl bg-amber-50 text-amber-800 border border-amber-200">
          <Trophy class="w-5 h-5" />
        </div>
        <div>
          <div class="text-xs font-semibold text-slate-500">Total Prize Pool</div>
          <div class="text-base font-bold text-slate-900 font-mono">{{ formatCurrency(totalPrizePool) }}</div>
        </div>
      </div>

      <div class="glass-panel p-4 flex items-center gap-3 border-l-4 border-l-blue-700 bg-white">
        <div class="p-2.5 rounded-xl bg-blue-50 text-blue-800 border border-blue-200">
          <Users class="w-5 h-5" />
        </div>
        <div>
          <div class="text-xs font-semibold text-slate-500">Registered Students</div>
          <div class="text-base font-bold text-slate-900 font-mono">1,450+</div>
        </div>
      </div>

      <div class="glass-panel p-4 flex items-center gap-3 border-l-4 border-l-indigo-700 bg-white">
        <div class="p-2.5 rounded-xl bg-indigo-50 text-indigo-800 border border-indigo-200">
          <Calendar class="w-5 h-5" />
        </div>
        <div>
          <div class="text-xs font-semibold text-slate-500">Active Competitions</div>
          <div class="text-base font-bold text-slate-900 font-mono">{{ totalEventsCount || 6 }} Events</div>
        </div>
      </div>

      <div class="glass-panel p-4 flex items-center gap-3 border-l-4 border-l-emerald-700 bg-white">
        <div class="p-2.5 rounded-xl bg-emerald-50 text-emerald-800 border border-emerald-200">
          <Award class="w-5 h-5" />
        </div>
        <div>
          <div class="text-xs font-semibold text-slate-500">Societies & Clubs</div>
          <div class="text-base font-bold text-slate-900 font-mono">6 Societies</div>
        </div>
      </div>
    </div>

    <!-- Search Bar & STATUS-WISE Tabs Filter Panel -->
    <div id="explore-events" class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm space-y-4">
      
      <!-- Top Row: Search Input & Host Event CTA -->
      <div class="flex flex-col sm:flex-row items-center gap-3">
        <div class="relative w-full flex-1">
          <Search class="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            :value="searchQuery"
            @input="emit('update:searchQuery', $event.target.value)"
            type="text"
            placeholder="Search competitions by name, segment, or organizing club..."
            class="w-full bg-slate-50 border border-slate-200 rounded-xl pl-10 pr-4 py-2.5 text-xs sm:text-sm text-slate-900 placeholder-slate-400 focus:outline-none focus:border-blue-600 focus:bg-white focus:ring-2 focus:ring-blue-600/10 transition-all"
          />
        </div>

        <button 
          @click="emit('openCreateModal')"
          class="w-full sm:w-auto px-5 py-2.5 bg-blue-700 hover:bg-blue-600 text-white font-extrabold text-xs sm:text-sm rounded-xl shrink-0 shadow-md shadow-blue-700/20 flex items-center justify-center gap-2"
        >
          <PlusCircle class="w-4 h-4" />
          <span>Host Competition</span>
        </button>
      </div>

      <!-- Bottom Row: STATUS-WISE FILTER TABS -->
      <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 pt-3 border-t border-slate-100">
        <div class="flex items-center gap-2 overflow-x-auto pb-1 text-xs w-full sm:w-auto">
          <span class="font-bold text-slate-500 mr-1 shrink-0 flex items-center gap-1">
            <Filter class="w-3.5 h-3.5 text-slate-400" /> Filter Status:
          </span>

          <button
            v-for="st in statusTabs"
            :key="st.id"
            @click="emit('update:selectedStatus', st.id)"
            :class="[
              selectedStatus === st.id
                ? 'bg-blue-700 text-white font-bold shadow-md shadow-blue-700/20'
                : 'bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold',
              'px-3.5 py-1.5 rounded-xl text-xs whitespace-nowrap transition-all flex items-center gap-1.5'
            ]"
          >
            <span v-if="st.id === 'LIVE NOW'" class="w-2 h-2 rounded-full bg-rose-400 animate-ping"></span>
            <span v-else-if="st.id === 'REGISTRATION OPEN'" class="w-2 h-2 rounded-full bg-emerald-400"></span>
            <span>{{ st.label }}</span>
          </button>
        </div>

        <!-- Category Dropdown / Selector -->
        <div class="flex items-center gap-2 self-end sm:self-auto">
          <span class="text-xs text-slate-400 font-medium">Category:</span>
          <select
            :value="selectedCategory"
            @change="emit('update:selectedCategory', $event.target.value)"
            class="px-3 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">
              {{ cat.label }}
            </option>
          </select>
        </div>
      </div>

    </div>

  </section>
</template>
