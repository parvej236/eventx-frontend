<script setup>
import { ref, computed, onMounted } from 'vue'
import { 
  Calendar, Plus, Search, Filter, Edit3, Trash2, MapPin, 
  Clock, DollarSign, Users, Award, ShieldCheck, CheckCircle2, 
  XCircle, AlertCircle, Image as ImageIcon, ChevronDown, ChevronUp, Layers,
  ArrowLeft, Save, Sparkles, Building, Loader2, Ticket, CreditCard, X
} from 'lucide-vue-next'
import { apiService } from '../../services/api'

const eventQueries = [
  {
    name: '1. Multi-Table Aggregation (SUM & COUNT)',
    concepts: ['INNER JOIN', 'LEFT JOIN', 'SUM', 'COUNT', 'GROUP BY'],
    purpose: 'Shows the list of campus competitions, host clubs, segment counts, and aggregate prize pools where status is REGISTRATION OPEN or UPCOMING',
    query: `SELECT e.event_id, e.name AS event_title, c.name AS host_club, b.name AS venue_building, COUNT(DISTINCT s.segment_id) AS total_segments, COALESCE(SUM(s.prize_pool), 0) AS aggregate_prize_pool, e.status FROM events e INNER JOIN clubs c ON e.club_id = c.club_id LEFT JOIN buildings b ON e.building_id = b.building_id LEFT JOIN event_segments s ON e.event_id = s.event_id GROUP BY e.event_id, e.name, c.name, b.name, e.status ORDER BY e.event_id DESC;`,
    explanation: 'Executes a complex MySQL JOIN aggregating events with host clubs and venue buildings. Calculates distinct segment count and cumulative monetary prize pool using SUM() and GROUP BY.',
    columns: ['Event ID', 'Event Title', 'Host Club', 'Venue Building', 'Segments', 'Prize Pool', 'Status'],
    rows: [
      [1, 'CUET TechFest 2026', 'CUET Computer Club', 'CSE Building', 3, '৳ 100,000', 'REGISTRATION OPEN'],
      [2, 'RoboClash Arena 2026', 'CUET Robotics Society', 'Electrical & Electronics Building', 3, '৳ 65,000', 'REGISTRATION OPEN'],
      [3, 'CUET National Cultural Gala', 'CUET Cultural Club', 'CUET Central Auditorium', 2, '৳ 35,000', 'UPCOMING']
    ]
  },
  {
    name: '2. Subquery with EXISTS & ALL',
    concepts: ['EXISTS', 'ALL', 'SUBQUERY', 'HAVING'],
    purpose: 'Shows the list of events where EXISTS at least 1 segment with prize_pool > ALL default segments (> ৳ 20,000)',
    query: `SELECT e.event_id, e.name AS event_title, c.name AS host_club FROM events e INNER JOIN clubs c ON e.club_id = c.club_id WHERE EXISTS (SELECT 1 FROM event_segments s WHERE s.event_id = e.event_id AND s.prize_pool > ALL (SELECT 20000)) ORDER BY e.event_id DESC;`,
    explanation: 'Uses a correlated subquery with EXISTS and ALL operator to filter top-tier competitions hosting high-reward prize pools.',
    columns: ['Event ID', 'Event Title', 'Host Club'],
    rows: [
      [1, 'CUET TechFest 2026', 'CUET Computer Club'],
      [2, 'RoboClash Arena 2026', 'CUET Robotics Society']
    ]
  },
  {
    name: '3. Building Allocation & HAVING',
    concepts: ['LEFT JOIN', 'GROUP BY', 'HAVING', 'COUNT'],
    purpose: 'Shows the list of campus venues and allocated event counts where total events > 1',
    query: `SELECT b.building_id, b.name AS building_name, b.location, COUNT(e.event_id) AS allocated_events FROM buildings b LEFT JOIN events e ON b.building_id = e.building_id GROUP BY b.building_id, b.name, b.location HAVING allocated_events > 1 ORDER BY allocated_events DESC;`,
    explanation: 'Groups physical campus venue structures and filters out low-frequency locations using the HAVING clause.',
    columns: ['Building ID', 'Building Name', 'Location Zone', 'Allocated Events'],
    rows: [
      [1, 'CSE Building', 'Academic Complex - Block A', 5],
      [2, 'Electrical & Electronics Building', 'Academic Complex - Block B', 4]
    ]
  }
]
const searchQuery = ref('')
const selectedStatusFilter = ref('ALL')
const viewMode = ref('list') // 'list', 'create', 'edit'
const showVolunteerModal = ref(false)
const activeEventForVolunteers = ref(null)

const showRegistrationsModal = ref(false)
const activeEventForRegistrations = ref(null)
const registrationsList = ref([])
const isLoading = ref(false)

// Toast System
const toast = ref({ show: false, message: '', type: 'success' })
const showToast = (msg, type = 'success') => {
  toast.value = { show: true, message: msg, type }
  setTimeout(() => { toast.value.show = false }, 3500)
}

// Delete Confirmation Modal State
const deleteModal = ref({ show: false, eventId: null, eventName: '', isDeleting: false })

// Buildings list matching buildings table in schema.sql
const buildingsList = ref([
  { building_id: 1, name: 'CSE Building', location: 'Academic Complex - Block A', status: 'ACTIVE' },
  { building_id: 2, name: 'Electrical & Electronics Building', location: 'Academic Complex - Block B', status: 'ACTIVE' },
  { building_id: 3, name: 'CUET Central Auditorium', location: 'Administrative Square', status: 'ACTIVE' },
  { building_id: 4, name: 'Student Recreation Center', location: 'Sports Ground West', status: 'ACTIVE' }
])

const eventsList = ref([])

const fetchEvents = async () => {
  isLoading.value = true
  try {
    const data = await apiService.getEvents()
    if (Array.isArray(data) && data.length > 0) {
      eventsList.value = data.map(e => ({
        event_id: e.id || e.eventId,
        name: e.name,
        description: e.description,
        prize_pool: e.prizePool != null ? e.prizePool : 50000,
        reg_start: e.regStart || '2026-08-01 00:00:00',
        reg_end: e.regEnd || '2026-08-20 23:59:00',
        start_at: e.startAt || '2026-08-25 09:00:00',
        end_at: e.endAt || '2026-08-27 18:00:00',
        banner_url: e.bannerUrl || 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80',
        status: e.status || 'UPCOMING',
        building_name: e.buildingName || 'CSE Building',
        organizer_name: e.hostName ? `${e.hostName} (${e.clubName || 'Organizer'})` : (e.organizerClub || 'CUET Central Society'),
        segments: Array.isArray(e.segments) ? e.segments.map(s => ({
          segment_id: s.id || s.segmentId,
          title: s.title,
          description: s.description,
          type: s.type || 'Team',
          start_time: s.startTime || '2026-08-25 10:00:00',
          end_time: s.endTime || '2026-08-25 17:00:00',
          prize: s.prize || 0,
          reg_fee: s.regFee || 0,
          building_name: s.buildingName || e.buildingName || 'CSE Building'
        })) : []
      }))
    }
  } catch (err) {
    showToast('Failed to fetch events from backend', 'error')
  } finally {
    isLoading.value = false
  }
}

const fetchBuildings = async () => {
  try {
    const res = await fetch('http://localhost:8080/api/buildings')
    if (res.ok) {
      const data = await res.json()
      if (Array.isArray(data) && data.length > 0) {
        buildingsList.value = data
      }
    }
  } catch (e) {}
}

const volunteersList = ref([])

const fetchVolunteers = async () => {
  try {
    const data = await apiService.getVolunteers()
    if (Array.isArray(data)) {
      volunteersList.value = data
    }
  } catch (e) {
    console.error('Failed to fetch volunteers', e)
  }
}

const fetchRegistrations = async () => {
  try {
    const data = await apiService.getRegistrations()
    if (Array.isArray(data)) {
      registrationsList.value = data
    }
  } catch (e) {
    console.error('Failed to fetch registrations', e)
  }
}

onMounted(() => {
  fetchEvents()
  fetchBuildings()
  fetchVolunteers()
  fetchRegistrations()
})

// Event Form State matching events & event_segments schema
const eventForm = ref({
  event_id: null,
  name: '',
  description: '',
  prize_pool: 30000,
  reg_start: '2026-08-01T09:00',
  reg_end: '2026-08-20T23:59',
  start_at: '2026-08-25T09:00',
  end_at: '2026-08-27T18:00',
  banner_url: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80',
  status: 'UPCOMING',
  building_id: 1,
  segments: [
    {
      segment_id: Date.now(),
      title: 'Main Championship Segment',
      description: 'Primary competitive segment',
      type: 'Team',
      start_time: '2026-08-25T10:00',
      end_time: '2026-08-25T17:00',
      prize: 20000,
      reg_fee: 500,
      building_id: 1
    }
  ]
})

const expandedEvents = ref({ 1: true, 2: true })

const toggleExpand = (id) => {
  expandedEvents.value[id] = !expandedEvents.value[id]
}

const filteredEvents = computed(() => {
  let list = eventsList.value
  if (selectedStatusFilter.value !== 'ALL') {
    list = list.filter(e => e.status === selectedStatusFilter.value)
  }
  if (searchQuery.value.trim()) {
    const q = searchQuery.value.toLowerCase()
    list = list.filter(e => 
      e.name.toLowerCase().includes(q) ||
      e.description?.toLowerCase().includes(q) ||
      e.organizer_name?.toLowerCase().includes(q)
    )
  }
  return list
})

const openCreatePage = () => {
  viewMode.value = 'create'
  eventForm.value = {
    event_id: null,
    name: '',
    description: '',
    prize_pool: 50000,
    reg_start: new Date().toISOString().slice(0, 16),
    reg_end: new Date(Date.now() + 864000000).toISOString().slice(0, 16),
    start_at: new Date(Date.now() + 1000000000).toISOString().slice(0, 16),
    end_at: new Date(Date.now() + 1200000000).toISOString().slice(0, 16),
    banner_url: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80',
    status: 'UPCOMING',
    building_id: 1,
    segments: [
      {
        segment_id: Date.now() + 1,
        title: 'Main Championship Track',
        description: 'Primary segment competition',
        type: 'Team',
        start_time: new Date(Date.now() + 1000000000).toISOString().slice(0, 16),
        end_time: new Date(Date.now() + 1100000000).toISOString().slice(0, 16),
        prize: 30000,
        reg_fee: 500,
        building_id: 1
      }
    ]
  }
}

const openEditPage = (evt) => {
  viewMode.value = 'edit'
  eventForm.value = JSON.parse(JSON.stringify(evt))
}

const addSegmentForm = () => {
  eventForm.value.segments.push({
    segment_id: Date.now(),
    title: 'New Sub-Segment',
    description: 'Segment details',
    type: 'Individual',
    start_time: new Date().toISOString().slice(0, 16),
    end_time: new Date(Date.now() + 36000000).toISOString().slice(0, 16),
    prize: 10000,
    reg_fee: 300,
    building_id: 1
  })
}

const removeSegmentForm = (idx) => {
  if (eventForm.value.segments.length > 1) {
    eventForm.value.segments.splice(idx, 1)
  }
}

const saveEvent = async () => {
  if (!eventForm.value.name.trim()) {
    showToast('Event title is required', 'error')
    return
  }
  
  const bldg = buildingsList.value.find(b => b.building_id === Number(eventForm.value.building_id))
  const buildingName = bldg ? bldg.name : 'CSE Building'

  const formattedSegments = eventForm.value.segments.map(seg => {
    const sBldg = buildingsList.value.find(b => b.building_id === Number(seg.building_id))
    return {
      ...seg,
      building_name: sBldg ? `${sBldg.name} (${sBldg.location})` : buildingName
    }
  })

  const payload = {
    name: eventForm.value.name,
    description: eventForm.value.description,
    prizePool: eventForm.value.prize_pool,
    bannerUrl: eventForm.value.banner_url,
    status: eventForm.value.status,
    buildingName: buildingName,
    segments: formattedSegments
  }

  try {
    if (viewMode.value === 'edit' && eventForm.value.event_id) {
      await apiService.updateEvent(eventForm.value.event_id, payload)
      showToast('Event updated successfully', 'success')
    } else {
      await apiService.createEvent(payload)
      showToast('New event created and published!', 'success')
    }
    await fetchEvents()
    viewMode.value = 'list'
  } catch (err) {
    showToast('Error saving event to database', 'error')
  }
}

const promptDeleteEvent = (evt) => {
  deleteModal.value = {
    show: true,
    eventId: evt.event_id,
    eventName: evt.name,
    isDeleting: false
  }
}

const confirmDeleteEvent = async () => {
  deleteModal.value.isDeleting = true
  try {
    await apiService.deleteEvent(deleteModal.value.eventId)
    eventsList.value = eventsList.value.filter(e => e.event_id !== deleteModal.value.eventId)
    showToast('Event deleted successfully', 'success')
  } catch (err) {
    showToast('Failed to delete event', 'error')
  } finally {
    deleteModal.value.show = false
    deleteModal.value.isDeleting = false
  }
}

const openVolunteers = (evt) => {
  activeEventForVolunteers.value = evt
  showVolunteerModal.value = true
}

const updateVolunteerStatus = (vol, newStatus) => {
  vol.status = newStatus
  if (newStatus === 'CHECKED_IN') {
    vol.check_in_time = new Date().toISOString().replace('T', ' ').slice(0, 19)
  }
}

const openRegistrations = (evt) => {
  activeEventForRegistrations.value = evt
  showRegistrationsModal.value = true
  fetchRegistrations()
}

const currentEventRegistrations = computed(() => {
  if (!activeEventForRegistrations.value) return registrationsList.value
  const segmentIds = (activeEventForRegistrations.value.segments || []).map(s => s.segment_id || s.segmentId)
  if (segmentIds.length === 0) return registrationsList.value
  return registrationsList.value.filter(r => segmentIds.includes(Number(r.segment_id || r.segmentId)))
})

const updateRegistrationStatus = async (reg, newStatus) => {
  try {
    const regId = reg.regId || reg.reg_id
    await apiService.updateRegistrationStatus(regId, newStatus)
    reg.paymentStatus = newStatus
    reg.payment_status = newStatus
    showToast(`Registration #${regId} status updated to ${newStatus}`, 'success')
  } catch (e) {
    showToast('Failed to update registration status', 'error')
  }
}
</script>

<template>
  <div class="space-y-6 w-full">

    <!-- PAGE VIEW 1: EVENTS OVERVIEW LIST -->
    <template v-if="viewMode === 'list'">
      <!-- Top Header Banner -->
      <div class="bg-gradient-to-r from-blue-900 via-indigo-900 to-slate-900 text-white p-6 sm:p-8 rounded-3xl shadow-xl flex flex-col md:flex-row items-start md:items-center justify-between gap-6 relative overflow-hidden">
        <div class="absolute -right-10 -bottom-10 w-64 h-64 bg-blue-500/20 rounded-full blur-3xl pointer-events-none"></div>
        
        <div class="space-y-2 relative z-10">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/20 border border-blue-400/30 text-blue-300 text-xs font-bold uppercase tracking-wider">
            <Calendar class="w-3.5 h-3.5" />
            <span>CUET Event Management Domain</span>
          </div>
          <h2 class="text-2xl sm:text-3xl font-black tracking-tight">Event Creation & Segment Orchestration</h2>
          <p class="text-slate-300 text-xs sm:text-sm max-w-2xl">
            Full schema compliance with <code class="bg-slate-800 px-1.5 py-0.5 rounded text-blue-300 font-mono">events</code>, <code class="bg-slate-800 px-1.5 py-0.5 rounded text-blue-300 font-mono">event_segments</code>, <code class="bg-slate-800 px-1.5 py-0.5 rounded text-blue-300 font-mono">contains</code>, and <code class="bg-slate-800 px-1.5 py-0.5 rounded text-blue-300 font-mono">arranged_in</code>.
          </p>
        </div>

        <div class="flex items-center gap-2 shrink-0 relative z-10">
          <button @click="openCreatePage" class="px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white text-xs font-extrabold rounded-2xl shadow-lg shadow-blue-600/30 transition-all flex items-center gap-2">
            <Plus class="w-4 h-4" />
            <span>Create New Event</span>
          </button>
        </div>
      </div>

      <!-- Filters & Search Toolbar -->
      <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="relative w-full sm:w-80">
          <Search class="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search by event title, organizer or keywords..."
            class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs focus:ring-2 focus:ring-blue-500 focus:bg-white outline-none transition-all"
          />
        </div>

        <div class="flex items-center gap-3 w-full sm:w-auto justify-end">
          <div class="flex items-center gap-2 text-xs text-slate-500 font-medium">
            <Filter class="w-4 h-4 text-slate-400" />
            <span>Status:</span>
          </div>
          <select v-model="selectedStatusFilter" class="px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 outline-none focus:ring-2 focus:ring-blue-500">
            <option value="ALL">All Statuses</option>
            <option value="UPCOMING">UPCOMING</option>
            <option value="REGISTRATION OPEN">REGISTRATION OPEN</option>
            <option value="ONGOING">ONGOING</option>
            <option value="COMPLETED">COMPLETED</option>
          </select>
        </div>
      </div>

      <!-- Events List Grid -->
      <div class="space-y-6">
        <div 
          v-for="evt in filteredEvents" 
          :key="evt.event_id"
          class="bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-all space-y-0"
        >
          <!-- Main Event Card Row Header -->
          <div class="p-6 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6 bg-white border-b border-slate-100">
            <div class="flex items-start gap-4">
              <img 
                :src="evt.banner_url" 
                alt="Banner" 
                class="w-24 h-24 sm:w-28 sm:h-28 rounded-2xl object-cover border border-slate-200 shadow-sm shrink-0"
              />

              <div class="space-y-2">
                <div class="flex items-center gap-2 flex-wrap">
                  <span :class="[
                    evt.status === 'UPCOMING' ? 'bg-blue-100 text-blue-800 border-blue-300' :
                    evt.status === 'REGISTRATION OPEN' ? 'bg-emerald-100 text-emerald-800 border-emerald-300' :
                    'bg-purple-100 text-purple-800 border-purple-300',
                    'px-3 py-0.5 rounded-full text-[10px] font-extrabold uppercase border'
                  ]">
                    {{ evt.status }}
                  </span>
                  <span class="text-xs text-slate-400 font-mono">Event ID: #{{ evt.event_id }}</span>
                </div>

                <h3 class="text-xl font-extrabold text-slate-900">{{ evt.name }}</h3>
                <p class="text-xs text-slate-600 line-clamp-2 max-w-xl">{{ evt.description }}</p>

                <div class="flex items-center gap-4 text-xs text-slate-500 font-medium flex-wrap pt-1">
                  <div class="flex items-center gap-1.5">
                    <MapPin class="w-3.5 h-3.5 text-blue-600" />
                    <span>{{ evt.building_name }}</span>
                  </div>
                  <div class="flex items-center gap-1.5 font-mono text-emerald-700 font-bold">
                    <Award class="w-3.5 h-3.5 text-emerald-600" />
                    <span>Prize Pool: ৳ {{ evt.prize_pool.toLocaleString() }}</span>
                  </div>
                  <div class="flex items-center gap-1.5 text-slate-500">
                    <Users class="w-3.5 h-3.5 text-slate-400" />
                    <span>Organizer: {{ evt.organizer_name }}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Actions Toolbar for Event Card -->
            <div class="flex items-center gap-2 self-end lg:self-center shrink-0">
              <button 
                @click="toggleExpand(evt.event_id)"
                class="px-3.5 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5"
              >
                <Layers class="w-3.5 h-3.5 text-slate-500" />
                <span>{{ evt.segments?.length || 0 }} Segments</span>
                <ChevronUp v-if="expandedEvents[evt.event_id]" class="w-3.5 h-3.5" />
                <ChevronDown v-else class="w-3.5 h-3.5" />
              </button>

              <button 
                @click="openVolunteers(evt)"
                class="px-3.5 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 rounded-xl text-xs font-bold border border-indigo-200 transition-all flex items-center gap-1.5"
              >
                <Users class="w-3.5 h-3.5 text-indigo-600" />
                <span>Volunteers</span>
              </button>

              <button 
                @click="openRegistrations(evt)"
                class="px-3.5 py-2 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 rounded-xl text-xs font-bold border border-emerald-200 transition-all flex items-center gap-1.5"
              >
                <Ticket class="w-3.5 h-3.5 text-emerald-600" />
                <span>Registrations</span>
              </button>

              <button 
                @click="openEditPage(evt)"
                class="px-3.5 py-2 bg-blue-50 hover:bg-blue-100 text-blue-700 rounded-xl text-xs font-bold border border-blue-200 transition-all flex items-center gap-1.5"
              >
                <Edit3 class="w-3.5 h-3.5" />
                <span>Edit Event</span>
              </button>

              <button 
                @click="promptDeleteEvent(evt)"
                class="p-2 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-all"
              >
                <Trash2 class="w-4 h-4" />
              </button>
            </div>
          </div>

          <!-- Nested Event Segments Table (contains & event_segments relationship) -->
          <div v-if="expandedEvents[evt.event_id]" class="bg-slate-50/70 p-6 border-t border-slate-100 space-y-3">
            <div class="flex items-center justify-between">
              <h4 class="text-xs font-bold uppercase tracking-wider text-slate-500 flex items-center gap-2">
                <Layers class="w-4 h-4 text-blue-600" />
                <span>Event Sub-Segments (<code class="font-mono text-blue-600">event_segments</code> schema)</span>
              </h4>
            </div>

            <div class="overflow-x-auto rounded-xl border border-slate-200 bg-white">
              <table class="w-full text-left text-xs text-slate-700">
                <thead class="bg-slate-100/80 text-slate-500 font-bold uppercase text-[10px] tracking-wider border-b border-slate-200">
                  <tr>
                    <th class="p-3">Segment Title & Description</th>
                    <th class="p-3">Type</th>
                    <th class="p-3">Reg Fee</th>
                    <th class="p-3">Segment Prize</th>
                    <th class="p-3">Building Venue (<code class="font-mono text-purple-600">arranged_in</code>)</th>
                    <th class="p-3">Schedule</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                  <tr v-for="seg in evt.segments" :key="seg.segment_id" class="hover:bg-slate-50">
                    <td class="p-3">
                      <div class="font-bold text-slate-900">{{ seg.title }}</div>
                      <div class="text-[11px] text-slate-500">{{ seg.description }}</div>
                    </td>
                    <td class="p-3">
                      <span :class="[
                        seg.type === 'Team' ? 'bg-indigo-100 text-indigo-800' : 'bg-amber-100 text-amber-800',
                        'px-2.5 py-0.5 rounded-md text-[10px] font-bold'
                      ]">
                        {{ seg.type }}
                      </span>
                    </td>
                    <td class="p-3 font-mono font-bold text-slate-900">
                      ৳ {{ seg.reg_fee }}
                    </td>
                    <td class="p-3 font-mono font-bold text-emerald-700">
                      ৳ {{ seg.prize?.toLocaleString() || 0 }}
                    </td>
                    <td class="p-3">
                      <div class="flex items-center gap-1 text-slate-700">
                        <MapPin class="w-3 h-3 text-purple-600 shrink-0" />
                        <span>{{ seg.building_name || evt.building_name }}</span>
                      </div>
                    </td>
                    <td class="p-3 text-[11px] font-mono text-slate-500">
                      <div>Start: {{ seg.start_time }}</div>
                      <div>End: {{ seg.end_time }}</div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- PAGE VIEW 2: DEDICATED FULL-PAGE EVENT CREATION & EDITING STUDIO -->
    <template v-else-if="viewMode === 'create' || viewMode === 'edit'">
      <!-- Back Navigation Header -->
      <div class="flex items-center justify-between bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <div class="flex items-center gap-4">
          <button 
            @click="viewMode = 'list'"
            class="p-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 transition-all"
          >
            <ArrowLeft class="w-5 h-5" />
          </button>
          <div>
            <h2 class="text-2xl font-black text-slate-900">
              {{ viewMode === 'edit' ? 'Edit Campus Event' : 'Create & Publish Campus Event' }}
            </h2>
            <p class="text-xs text-slate-500">Full-page event configuration desk mapped to MySQL entity tables.</p>
          </div>
        </div>

        <div class="flex items-center gap-3">
          <button @click="viewMode = 'list'" class="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold">
            Cancel
          </button>
          <button @click="saveEvent" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-extrabold shadow-md shadow-blue-600/30 flex items-center gap-2">
            <Save class="w-4 h-4" />
            <span>{{ viewMode === 'edit' ? 'Save Changes' : 'Publish Event' }}</span>
          </button>
        </div>
      </div>

      <!-- Main Creation Form Studio -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <!-- Left 2 Columns: Core Event Details Form -->
        <div class="lg:col-span-2 space-y-6">
          <div class="bg-white p-6 sm:p-8 rounded-3xl border border-slate-200 shadow-sm space-y-6">
            <div class="flex items-center justify-between border-b border-slate-100 pb-4">
              <h3 class="text-lg font-black text-slate-900 flex items-center gap-2">
                <Sparkles class="w-5 h-5 text-blue-600" />
                <span>Event Core Specification (<code class="font-mono text-blue-600">events</code> table)</span>
              </h3>
            </div>

            <div class="space-y-4">
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Event Title *</label>
                <input 
                  v-model="eventForm.name" 
                  type="text" 
                  placeholder="e.g. CUET National HackFest 2026" 
                  class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-900 focus:ring-2 focus:ring-blue-500 focus:bg-white outline-none transition-all"
                />
              </div>

              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Detailed Event Highlights & Overview</label>
                <textarea 
                  v-model="eventForm.description" 
                  rows="4" 
                  placeholder="Describe main competitive challenges, eligibility rules, and schedule..."
                  class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:ring-2 focus:ring-blue-500 focus:bg-white outline-none transition-all"
                ></textarea>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">Total Prize Pool (BDT)</label>
                  <input 
                    v-model.number="eventForm.prize_pool" 
                    type="number" 
                    class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono font-bold text-emerald-700 focus:ring-2 focus:ring-blue-500 focus:bg-white outline-none transition-all"
                  />
                </div>

                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">Event Status</label>
                  <select v-model="eventForm.status" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:ring-2 focus:ring-blue-500 outline-none">
                    <option value="UPCOMING">UPCOMING</option>
                    <option value="REGISTRATION OPEN">REGISTRATION OPEN</option>
                    <option value="ONGOING">ONGOING</option>
                    <option value="COMPLETED">COMPLETED</option>
                  </select>
                </div>

                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">Primary Venue (<code class="font-mono text-purple-600">buildings</code>)</label>
                  <select v-model="eventForm.building_id" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-800 focus:ring-2 focus:ring-blue-500 outline-none">
                    <option v-for="b in buildingsList" :key="b.building_id" :value="b.building_id">
                      {{ b.name }} ({{ b.location }})
                    </option>
                  </select>
                </div>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">Registration Start Datetime</label>
                  <input 
                    v-model="eventForm.reg_start" 
                    type="datetime-local" 
                    class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono text-slate-700 focus:ring-2 focus:ring-blue-500 outline-none"
                  />
                </div>
                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">Registration End Datetime</label>
                  <input 
                    v-model="eventForm.reg_end" 
                    type="datetime-local" 
                    class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono text-slate-700 focus:ring-2 focus:ring-blue-500 outline-none"
                  />
                </div>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">Event Start Datetime</label>
                  <input 
                    v-model="eventForm.start_at" 
                    type="datetime-local" 
                    class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono text-slate-700 focus:ring-2 focus:ring-blue-500 outline-none"
                  />
                </div>
                <div>
                  <label class="block text-xs font-bold text-slate-700 mb-1">Event End Datetime</label>
                  <input 
                    v-model="eventForm.end_at" 
                    type="datetime-local" 
                    class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono text-slate-700 focus:ring-2 focus:ring-blue-500 outline-none"
                  />
                </div>
              </div>

              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Event Banner Image URL</label>
                <input 
                  v-model="eventForm.banner_url" 
                  type="text" 
                  placeholder="https://images.unsplash.com/photo-..." 
                  class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono text-slate-700 focus:ring-2 focus:ring-blue-500 outline-none"
                />
              </div>
            </div>
          </div>

          <!-- Sub-Segments Builder Panel -->
          <div class="bg-white p-6 sm:p-8 rounded-3xl border border-slate-200 shadow-sm space-y-6">
            <div class="flex items-center justify-between border-b border-slate-100 pb-4">
              <div>
                <h3 class="text-lg font-black text-slate-900 flex items-center gap-2">
                  <Layers class="w-5 h-5 text-indigo-600" />
                  <span>Sub-Segments Builder (<code class="font-mono text-indigo-600">event_segments</code> & <code class="font-mono text-indigo-600">contains</code>)</span>
                </h3>
                <p class="text-xs text-slate-500">Define tracks, fees, prizes, and specific building venues for each segment.</p>
              </div>

              <button @click="addSegmentForm" class="px-4 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 rounded-xl text-xs font-extrabold border border-indigo-200 flex items-center gap-1.5">
                <Plus class="w-4 h-4" />
                <span>Add Segment</span>
              </button>
            </div>

            <div class="space-y-4">
              <div 
                v-for="(seg, idx) in eventForm.segments" 
                :key="seg.segment_id"
                class="p-5 bg-slate-50/80 border border-slate-200 rounded-2xl space-y-4 relative hover:border-indigo-300 transition-all"
              >
                <div class="flex items-center justify-between">
                  <span class="text-xs font-extrabold uppercase tracking-wider text-indigo-700 bg-indigo-50 px-2.5 py-1 rounded-lg border border-indigo-200">
                    Segment Track #{{ idx + 1 }}
                  </span>
                  <button 
                    v-if="eventForm.segments.length > 1" 
                    @click="removeSegmentForm(idx)" 
                    class="text-rose-500 hover:text-rose-700 text-xs font-bold p-1"
                  >
                    Remove Track
                  </button>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-[11px] font-bold text-slate-600 mb-1">Segment Title</label>
                    <input v-model="seg.title" type="text" placeholder="e.g. AI Model Showdown" class="w-full px-3.5 py-2.5 bg-white border border-slate-200 rounded-xl text-xs font-bold" />
                  </div>
                  <div>
                    <label class="block text-[11px] font-bold text-slate-600 mb-1">Short Description</label>
                    <input v-model="seg.description" type="text" placeholder="Competitor track summary" class="w-full px-3.5 py-2.5 bg-white border border-slate-200 rounded-xl text-xs" />
                  </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <div>
                    <label class="block text-[11px] font-bold text-slate-600 mb-1">Participation Type</label>
                    <select v-model="seg.type" class="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold text-slate-800">
                      <option value="Team">Team Competition</option>
                      <option value="Individual">Individual Competition</option>
                    </select>
                  </div>

                  <div>
                    <label class="block text-[11px] font-bold text-slate-600 mb-1">Registration Fee (BDT)</label>
                    <input v-model.number="seg.reg_fee" type="number" class="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs font-mono font-bold" />
                  </div>

                  <div>
                    <label class="block text-[11px] font-bold text-slate-600 mb-1">Segment Prize (BDT)</label>
                    <input v-model.number="seg.prize" type="number" class="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs font-mono font-bold text-emerald-700" />
                  </div>
                </div>

                <div>
                  <label class="block text-[11px] font-bold text-slate-600 mb-1">Segment Venue (<code class="font-mono text-purple-600">arranged_in</code>)</label>
                  <select v-model="seg.building_id" class="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs font-medium text-slate-800">
                    <option v-for="b in buildingsList" :key="b.building_id" :value="b.building_id">
                      {{ b.name }} ({{ b.location }})
                    </option>
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Right Column: Live Event Card Preview -->
        <div class="space-y-6">
          <div class="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm space-y-4 sticky top-6">
            <h4 class="text-xs font-extrabold uppercase tracking-wider text-slate-500">Live Campus Banner Preview</h4>
            
            <div class="border border-slate-200 rounded-2xl overflow-hidden shadow-md bg-white">
              <img :src="eventForm.banner_url || 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80'" alt="Banner Preview" class="w-full h-44 object-cover" />
              
              <div class="p-5 space-y-3">
                <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase bg-blue-100 text-blue-800 border border-blue-300">
                  {{ eventForm.status }}
                </span>

                <h3 class="text-lg font-black text-slate-900">{{ eventForm.name || 'Untitled Event' }}</h3>
                <p class="text-xs text-slate-600 line-clamp-3">{{ eventForm.description || 'Event highlights and details will appear here...' }}</p>

                <div class="pt-3 border-t border-slate-100 flex items-center justify-between text-xs font-bold">
                  <span class="text-slate-500">Prize Pool:</span>
                  <span class="text-emerald-700 font-mono">৳ {{ (eventForm.prize_pool || 0).toLocaleString() }}</span>
                </div>
              </div>
            </div>

            <div class="p-4 bg-blue-50 border border-blue-200 rounded-2xl text-xs text-blue-900 space-y-1">
              <div class="font-bold">✓ Database Synchronization</div>
              <p class="text-[11px] text-blue-700">Submitting will populate records across <code class="font-mono font-bold">events</code>, <code class="font-mono font-bold">event_segments</code>, and <code class="font-mono font-bold">contains</code> junction tables.</p>
            </div>
          </div>
        </div>

      </div>
    </template>

    <!-- Volunteer Management Modal (`volunteers_in` schema) -->
    <div v-if="showVolunteerModal" class="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="bg-white border border-slate-200 max-w-xl w-full rounded-3xl p-6 space-y-4 shadow-2xl">
        <div class="flex items-center justify-between border-b border-slate-100 pb-3">
          <div>
            <h3 class="text-lg font-black text-slate-900">Volunteer Assignments</h3>
            <p class="text-xs text-slate-500"><code class="font-mono text-indigo-600">volunteers_in</code> schema status check-in</p>
          </div>
          <button @click="showVolunteerModal = false" class="text-slate-400 hover:text-slate-900"><XCircle class="w-5 h-5" /></button>
        </div>

        <div class="space-y-3 max-h-60 overflow-y-auto">
          <div 
            v-for="vol in volunteersList" 
            :key="vol.user_id"
            class="p-3 bg-slate-50 border border-slate-200 rounded-xl flex items-center justify-between"
          >
            <div>
              <div class="font-bold text-xs text-slate-900">{{ vol.name }}</div>
              <div class="text-[11px] text-slate-500">{{ vol.email }}</div>
              <div class="text-[10px] text-indigo-600 font-bold mt-0.5">{{ vol.segment_title }}</div>
            </div>

            <div class="flex items-center gap-2">
              <span :class="[
                vol.status === 'CHECKED_IN' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800',
                'px-2 py-0.5 rounded-full text-[10px] font-bold'
              ]">
                {{ vol.status }}
              </span>

              <button 
                v-if="vol.status !== 'CHECKED_IN'"
                @click="updateVolunteerStatus(vol, 'CHECKED_IN')"
                class="px-2.5 py-1 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-[10px] font-bold"
              >
                Mark Checked-In
              </button>
            </div>
          </div>
        </div>

        <div class="pt-2 border-t border-slate-100 flex justify-end">
          <button @click="showVolunteerModal = false" class="px-4 py-2 bg-slate-100 text-slate-700 rounded-xl text-xs font-bold">
            Done
          </button>
        </div>
      </div>
    </div>

    <!-- Glassmorphic Event Registrations Modal -->
    <div v-if="showRegistrationsModal" class="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="bg-white border border-slate-200 max-w-3xl w-full rounded-3xl p-6 space-y-4 shadow-2xl overflow-hidden">
        <div class="flex items-center justify-between border-b border-slate-100 pb-3">
          <div class="flex items-center gap-3">
            <div class="p-2.5 rounded-xl bg-emerald-100 text-emerald-700">
              <Ticket class="w-5 h-5" />
            </div>
            <div>
              <h3 class="text-lg font-black text-slate-900">Event Registrations & Payment Proofs</h3>
              <p class="text-xs text-slate-500 font-medium">
                Registrations for <span class="font-bold text-slate-800">{{ activeEventForRegistrations?.name || 'Selected Event' }}</span>
              </p>
            </div>
          </div>
          <button @click="showRegistrationsModal = false" class="text-slate-400 hover:text-slate-900 p-1 rounded-lg">
            <X class="w-5 h-5" />
          </button>
        </div>

        <div v-if="currentEventRegistrations.length === 0" class="p-8 text-center text-slate-500 flex flex-col items-center gap-2">
          <Ticket class="w-10 h-10 text-slate-300 mb-1" />
          <h4 class="text-sm font-bold text-slate-700">No Registrations Yet</h4>
          <p class="text-xs text-slate-400">There are no student registrations recorded for this event in MySQL database.</p>
        </div>

        <div v-else class="space-y-3 max-h-96 overflow-y-auto pr-1">
          <table class="w-full text-left text-xs">
            <thead class="bg-slate-50 text-slate-500 font-bold uppercase tracking-wider border-b border-slate-200 sticky top-0">
              <tr>
                <th class="py-3 px-3">Reg ID & Participant</th>
                <th class="py-3 px-3">Segment / Team</th>
                <th class="py-3 px-3">Payment Info</th>
                <th class="py-3 px-3">Status</th>
                <th class="py-3 px-3 text-right">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 font-medium">
              <tr v-for="reg in currentEventRegistrations" :key="reg.regId || reg.reg_id" class="hover:bg-slate-50/80 transition-colors">
                <td class="py-3 px-3">
                  <div class="font-bold text-slate-900">{{ reg.userName || reg.user_name || ('Student #' + (reg.userId || reg.user_id)) }}</div>
                  <div class="text-[11px] text-slate-500 font-mono">{{ reg.userEmail || reg.user_email }}</div>
                  <div class="text-[10px] text-blue-600 font-mono font-bold mt-0.5">Reg ID: #{{ reg.regId || reg.reg_id }}</div>
                </td>

                <td class="py-3 px-3">
                  <div class="font-bold text-slate-800">{{ reg.segmentTitle || reg.segment_title || ('Segment #' + (reg.segmentId || reg.segment_id)) }}</div>
                  <div v-if="reg.teamName || reg.team_name" class="text-[11px] text-purple-700 font-semibold">Team: {{ reg.teamName || reg.team_name }}</div>
                </td>

                <td class="py-3 px-3">
                  <div class="flex items-center gap-1 text-slate-700 font-semibold">
                    <CreditCard class="w-3.5 h-3.5 text-blue-600" />
                    <span>{{ reg.method || 'bKash' }}</span>
                  </div>
                  <div class="text-[10px] text-slate-500 font-mono">TXN: {{ reg.transactionNumber || reg.transaction_number || 'N/A' }}</div>
                </td>

                <td class="py-3 px-3">
                  <span :class="[
                    (reg.paymentStatus || reg.payment_status) === 'PAID' ? 'bg-emerald-100 text-emerald-800 border-emerald-200' :
                    (reg.paymentStatus || reg.payment_status) === 'PENDING' ? 'bg-amber-100 text-amber-800 border-amber-200' : 'bg-rose-100 text-rose-800 border-rose-200',
                    'px-2.5 py-1 rounded-full text-[10px] font-extrabold uppercase border inline-block'
                  ]">
                    {{ reg.paymentStatus || reg.payment_status || 'PAID' }}
                  </span>
                </td>

                <td class="py-3 px-3 text-right space-x-1">
                  <button 
                    v-if="(reg.paymentStatus || reg.payment_status) !== 'PAID'"
                    @click="updateRegistrationStatus(reg, 'PAID')"
                    class="px-2.5 py-1 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-[10px] font-bold shadow-sm transition-all"
                  >
                    Approve Payment
                  </button>
                  <button 
                    v-if="(reg.paymentStatus || reg.payment_status) === 'PAID'"
                    @click="updateRegistrationStatus(reg, 'REJECTED')"
                    class="px-2.5 py-1 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 rounded-lg text-[10px] font-bold transition-all"
                  >
                    Mark Rejected
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="pt-3 border-t border-slate-100 flex items-center justify-between">
          <span class="text-xs text-slate-500 font-semibold">
            Total Registrations: <span class="font-bold text-slate-900">{{ currentEventRegistrations.length }}</span>
          </span>
          <button @click="showRegistrationsModal = false" class="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition-all">
            Close
          </button>
        </div>
      </div>
    </div>

    <!-- Glassmorphic Delete Confirmation Modal -->
    <div v-if="deleteModal.show" class="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="bg-white border border-slate-200 max-w-md w-full rounded-3xl p-6 space-y-4 shadow-2xl">
        <div class="w-12 h-12 rounded-full bg-rose-100 border border-rose-200 text-rose-600 flex items-center justify-center mx-auto">
          <Trash2 class="w-6 h-6" />
        </div>
        <div class="text-center space-y-1">
          <h3 class="text-lg font-black text-slate-900">Delete Campus Event?</h3>
          <p class="text-xs text-slate-600">
            Are you sure you want to delete <span class="font-bold text-slate-900">"{{ deleteModal.eventName }}"</span>? This will permanently purge its associated segments from the MySQL database.
          </p>
        </div>
        <div class="flex items-center gap-3 pt-2">
          <button 
            @click="deleteModal.show = false" 
            :disabled="deleteModal.isDeleting"
            class="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition-all"
          >
            Cancel
          </button>
          <button 
            @click="confirmDeleteEvent" 
            :disabled="deleteModal.isDeleting"
            class="flex-1 py-2.5 bg-rose-600 hover:bg-rose-700 text-white rounded-xl text-xs font-bold shadow-md shadow-rose-600/30 flex items-center justify-center gap-2 transition-all"
          >
            <Loader2 v-if="deleteModal.isDeleting" class="w-4 h-4 animate-spin" />
            <span>{{ deleteModal.isDeleting ? 'Deleting...' : 'Confirm Delete' }}</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notification Banner -->
    <div 
      v-if="toast.show" 
      :class="[
        toast.type === 'error' ? 'bg-rose-900 border-rose-700 text-rose-100' : 'bg-slate-900 border-slate-700 text-white',
        'fixed bottom-6 right-6 z-50 px-4 py-3 rounded-2xl border shadow-2xl flex items-center gap-3 transition-all animate-bounce'
      ]"
    >
      <CheckCircle2 v-if="toast.type !== 'error'" class="w-5 h-5 text-emerald-400 shrink-0" />
      <AlertCircle v-else class="w-5 h-5 text-rose-400 shrink-0" />
      <span class="text-xs font-bold">{{ toast.message }}</span>
    </div>

  </div>
</template>
