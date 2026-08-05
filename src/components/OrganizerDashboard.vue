<script setup>
import { ref, computed } from 'vue'
import { ShieldCheck, Plus, DollarSign, Users, Calendar, CheckCircle2, Clock, XCircle, Search, Filter, QrCode, Sparkles, Layers } from 'lucide-vue-next'
import EventManagement from './dashboard/EventManagement.vue'

const organizerQueries = [
  {
    name: '1. 4-Way Relational JOIN & TrxID',
    concepts: ['INNER JOIN', '4-WAY JOIN', 'WHERE', 'ORDER BY'],
    purpose: 'Shows the list of student event registrations, team leaders, and bKash transaction numbers where payment_status is PAID or PENDING',
    query: `SELECT r.registration_id, r.team_name, u.name AS team_leader, u.student_id, e.name AS event_name, s.title AS segment_title, r.transaction_number, r.payment_status, r.fee FROM registrations r INNER JOIN users u ON r.user_id = u.user_id INNER JOIN event_segments s ON r.segment_id = s.segment_id INNER JOIN events e ON s.event_id = e.event_id WHERE r.payment_status IN ('PAID', 'PENDING') ORDER BY r.registered_at DESC;`,
    explanation: 'Performs a 4-Way INNER JOIN linking student registrations, user credentials, event segments, and competition entries to verify bKash/Nagad TrxIDs.',
    columns: ['Reg ID', 'Team Name', 'Leader', 'Student ID', 'Event', 'Segment', 'TrxID', 'Status', 'Fee'],
    rows: [
      [101, 'Binary Beasts', 'Alice Mahmud', '2304001', 'CUET TechFest 2026', 'AI Hackathon 24H', 'TRX99201482', 'PAID', '৳ 500'],
      [102, 'Electro Botics', 'Tanvir Hossain', '2302044', 'RoboClash Arena 2026', 'Line Follower (LFR)', 'TRX88291044', 'PAID', '৳ 400'],
      [103, 'Mecha Warriors', 'Adnan Chowdhury', '2408012', 'RoboClash Arena 2026', 'Sumo Wrestling Bot', 'TRX77391022', 'PENDING', '৳ 500']
    ]
  },
  {
    name: '2. Payment Verification EXISTS Subquery',
    concepts: ['EXISTS', 'SUBQUERY', 'IN', 'INNER JOIN'],
    purpose: 'Shows the list of event segments where EXISTS at least 1 verified paid team registration',
    query: `SELECT s.segment_id, s.title AS segment_title, e.name AS event_name FROM event_segments s INNER JOIN events e ON s.event_id = e.event_id WHERE EXISTS (SELECT 1 FROM registrations r WHERE r.segment_id = s.segment_id AND r.payment_status = 'PAID') ORDER BY s.segment_id ASC;`,
    explanation: 'Uses a correlated EXISTS subquery to highlight active event segments receiving confirmed student participation payments.',
    columns: ['Segment ID', 'Segment Title', 'Event Name'],
    rows: [
      [1, 'AI Hackathon 24H', 'CUET TechFest 2026'],
      [2, 'Line Follower (LFR)', 'RoboClash Arena 2026'],
      [3, 'IUPC Programming Contest', 'CUET TechFest 2026']
    ]
  },
  {
    name: '3. Total Revenue Aggregation by Segment',
    concepts: ['GROUP BY', 'SUM', 'COUNT', 'HAVING'],
    purpose: 'Shows the list of event segments and total collected revenue where total_fee > 0',
    query: `SELECT s.title AS segment_title, COUNT(r.registration_id) AS total_teams, SUM(r.fee) AS total_collected_revenue FROM event_segments s INNER JOIN registrations r ON s.segment_id = r.segment_id WHERE r.payment_status = 'PAID' GROUP BY s.segment_id, s.title HAVING total_collected_revenue > 0 ORDER BY total_collected_revenue DESC;`,
    explanation: 'Aggregates team counts and calculates total collected entrance fees per event segment using SUM() and HAVING filters.',
    columns: ['Segment Title', 'Total Teams', 'Collected Revenue'],
    rows: [
      ['IUPC Programming Contest', 25, '৳ 15,000'],
      ['AI Hackathon 24H', 20, '৳ 10,000'],
      ['Line Follower (LFR)', 15, '৳ 6,000']
    ]
  }
]

const props = defineProps({
  events: Array,
  registrations: Array
})

const emit = defineEmits(['createEvent', 'updateRegistrationStatus'])

const storedUser = JSON.parse(localStorage.getItem('user') || '{}')
const userName = computed(() => storedUser.name || (storedUser.email ? storedUser.email.split('@')[0] : 'Organizer'))
const userEmail = computed(() => storedUser.email || 'organizer@cuet.ac.bd')

const activeTab = ref('overview') // 'overview', 'events'

const searchQuery = ref('')
const selectedStatusFilter = ref('ALL')
const showCreateModal = ref(false)

// New Event Form State
const newEvent = ref({
  name: '',
  category: 'Hackathon',
  organizerClub: 'CUET Computer Club',
  prizePool: 50000,
  description: '',
  bannerUrl: '/images/techfest_banner.png',
  venueName: 'CSE Building',
  segments: [
    { title: 'Main Championship', description: 'Primary competitive segment', type: 'Team', prize: 30000, regFee: 500, maxTeamSize: 4 }
  ]
})

const totalRevenue = computed(() => {
  return (props.registrations || []).reduce((acc, curr) => acc + (curr.fee || 500), 0)
})

const filteredRegistrations = computed(() => {
  let list = props.registrations || []
  if (selectedStatusFilter.value !== 'ALL') {
    list = list.filter(r => r.paymentStatus === selectedStatusFilter.value)
  }
  if (searchQuery.value.trim()) {
    const q = searchQuery.value.toLowerCase()
    list = list.filter(r => 
      r.teamName?.toLowerCase().includes(q) ||
      r.leaderName?.toLowerCase().includes(q) ||
      r.transactionNumber?.toLowerCase().includes(q) ||
      r.segmentTitle?.toLowerCase().includes(q)
    )
  }
  return list
})

const submitCreateEvent = () => {
  if (!newEvent.value.name.trim()) return
  emit('createEvent', { ...newEvent.value, id: Date.now(), status: 'UPCOMING' })
  showCreateModal.value = false
  newEvent.value.name = ''
}
</script>

<template>
  <div class="space-y-6 w-full">
    
    <!-- Top Header -->
    <div class="glass-panel p-5 sm:p-6 flex flex-col md:flex-row md:items-center justify-between gap-5 border-slate-200 bg-white rounded-xl shadow-xs">
      <div class="flex items-center gap-4">
        <div class="p-3 rounded-xl bg-blue-100 border border-blue-200 text-blue-700 shrink-0">
          <ShieldCheck class="w-7 h-7" />
        </div>
        <div>
          <h2 class="text-xl sm:text-2xl font-bold text-slate-900 capitalize">{{ userName }} — Organizer portal</h2>
          <p class="text-sm text-slate-600 mt-0.5">Account: <span class="font-mono font-bold text-slate-800">{{ userEmail }}</span> | Manage hosted events and verify bKash / Nagad student payments.</p>
        </div>
      </div>

      <div class="flex items-center gap-1.5 bg-slate-100 p-1.5 rounded-xl border border-slate-200 shrink-0">
        <button 
          @click="activeTab = 'overview'" 
          :class="[
            activeTab === 'overview' ? 'bg-white text-blue-700 shadow-xs font-bold' : 'text-slate-700 hover:text-slate-900 font-semibold',
            'px-4 py-2 rounded-lg text-xs sm:text-sm transition-all flex items-center gap-2'
          ]"
        >
          <ShieldCheck class="w-4 h-4" />
          <span>Overview & payments</span>
        </button>

        <button 
          @click="activeTab = 'events'" 
          :class="[
            activeTab === 'events' ? 'bg-white text-blue-700 shadow-xs font-bold' : 'text-slate-700 hover:text-slate-900 font-semibold',
            'px-4 py-2 rounded-lg text-xs sm:text-sm transition-all flex items-center gap-2'
          ]"
        >
          <Layers class="w-4 h-4" />
          <span>Event & segments desk</span>
        </button>
      </div>
    </div>

    <!-- TAB 1: OVERVIEW & PAYMENTS -->
    <template v-if="activeTab === 'overview'">

    <!-- Analytics Dashboard Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div class="glass-panel p-5 border-slate-200 bg-white border-l-4 border-l-emerald-600 rounded-xl shadow-xs">
        <div class="flex items-center justify-between text-xs sm:text-sm text-slate-600 mb-2">
          <span class="font-semibold">Collected revenue</span>
          <DollarSign class="w-5 h-5 text-emerald-600" />
        </div>
        <div class="text-3xl font-bold text-slate-900 font-mono">৳ {{ totalRevenue.toLocaleString() }}</div>
      </div>

      <div class="glass-panel p-5 border-slate-200 bg-white border-l-4 border-l-amber-500 rounded-xl shadow-xs">
        <div class="flex items-center justify-between text-xs sm:text-sm text-slate-600 mb-2">
          <span class="font-semibold">Total registrations</span>
          <Users class="w-5 h-5 text-amber-600" />
        </div>
        <div class="text-3xl font-bold text-slate-900 font-mono">{{ registrations?.length || 0 }} teams</div>
      </div>

      <div class="glass-panel p-5 border-slate-200 bg-white border-l-4 border-l-blue-600 rounded-xl shadow-xs">
        <div class="flex items-center justify-between text-xs sm:text-sm text-slate-600 mb-2">
          <span class="font-semibold">Active events</span>
          <Calendar class="w-5 h-5 text-blue-600" />
        </div>
        <div class="text-3xl font-bold text-slate-900 font-mono">{{ events?.length || 0 }} events</div>
      </div>

      <div class="glass-panel p-5 border-slate-200 bg-white border-l-4 border-l-indigo-600 rounded-xl shadow-xs">
        <div class="flex items-center justify-between text-xs sm:text-sm text-slate-600 mb-2">
          <span class="font-semibold">Volunteer check-ins</span>
          <QrCode class="w-5 h-5 text-indigo-600" />
        </div>
        <div class="text-3xl font-bold text-slate-900 font-mono">84 scanned</div>
      </div>
    </div>

    <!-- Registrations & Verification Table Section -->
    <div class="glass-panel border-slate-200 rounded-xl overflow-hidden shadow-xs space-y-4 p-5 bg-white">
      
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 class="text-lg font-bold text-slate-900">Event registrations & payment verification</h3>
          <p class="text-xs sm:text-sm text-slate-600 mt-0.5">Review bKash / Nagad transaction numbers and confirm student entry passes.</p>
        </div>

        <div class="flex items-center gap-3">
          <div class="relative">
            <Search class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Search team or TrxID..."
              class="glass-input pl-9 text-xs sm:text-sm py-2 w-48 sm:w-64"
            />
          </div>

          <select v-model="selectedStatusFilter" class="glass-input text-xs sm:text-sm py-2 bg-white font-semibold">
            <option value="ALL">All payments</option>
            <option value="PAID">Paid</option>
            <option value="PENDING">Pending</option>
          </select>
        </div>
      </div>

      <!-- Data Table -->
      <div class="overflow-x-auto border border-slate-200 rounded-lg">
        <table class="w-full text-left text-xs sm:text-sm text-slate-800">
          <thead class="bg-slate-50 text-slate-700 font-bold border-b border-slate-200">
            <tr>
              <th class="p-3.5">Team / Leader</th>
              <th class="p-3.5">Event & segment</th>
              <th class="p-3.5">Method & TrxID</th>
              <th class="p-3.5">Fee</th>
              <th class="p-3.5">Status</th>
              <th class="p-3.5 text-right">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="r in filteredRegistrations" :key="r.regId" class="hover:bg-slate-50 transition-colors">
              <td class="p-3.5">
                <div class="font-bold text-slate-900 text-sm sm:text-base">{{ r.teamName }}</div>
                <div class="text-xs text-slate-600 font-medium mt-0.5">{{ r.leaderName }} ({{ r.studentId }})</div>
              </td>
              <td class="p-3.5">
                <div class="text-slate-900 font-bold">{{ r.eventName }}</div>
                <div class="text-xs text-blue-700 font-mono font-bold mt-0.5">{{ r.segmentTitle }}</div>
              </td>
              <td class="p-3.5 font-mono">
                <span class="text-slate-600 font-medium">{{ r.method || 'bKash' }}: </span>
                <span class="text-slate-900 font-bold text-xs sm:text-sm">{{ r.transactionNumber }}</span>
              </td>
              <td class="p-3.5 font-mono font-bold text-emerald-700 text-sm">
                ৳ {{ r.fee || 500 }}
              </td>
              <td class="p-3.5">
                <span :class="[
                  r.paymentStatus === 'PAID' ? 'bg-emerald-100 text-emerald-800 border-emerald-300' : 'bg-amber-100 text-amber-800 border-amber-300',
                  'px-3 py-1 rounded-full text-xs font-bold border'
                ]">
                  {{ r.paymentStatus === 'PAID' ? '✓ Paid' : '⏳ Pending' }}
                </span>
              </td>
              <td class="p-3.5 text-right space-x-2">
                <button
                  v-if="r.paymentStatus !== 'PAID'"
                  @click="emit('updateRegistrationStatus', r.regId, 'PAID')"
                  class="px-3 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs sm:text-sm font-bold shadow-xs transition-all"
                >
                  Approve paid
                </button>
                <button
                  v-else
                  @click="emit('updateRegistrationStatus', r.regId, 'PENDING')"
                  class="px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-amber-50 hover:text-amber-800 text-slate-800 text-xs sm:text-sm font-bold border border-slate-300 transition-all"
                >
                  Set pending
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

    </div>

    <!-- Modal Create Event Wizard -->
    <div v-if="showCreateModal" class="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4">
      <div class="glass-panel p-6 border-slate-200 max-w-lg w-full rounded-2xl bg-white text-slate-900 space-y-4 shadow-xl">
        <div class="flex items-center justify-between border-b border-slate-200 pb-3">
          <h4 class="font-bold text-lg text-slate-900">Create campus event</h4>
          <button @click="showCreateModal = false" class="text-slate-400 hover:text-slate-900"><XCircle class="w-5 h-5" /></button>
        </div>

        <div class="space-y-3.5">
          <div>
            <label class="block text-xs sm:text-sm font-bold text-slate-700 mb-1">Event name *</label>
            <input v-model="newEvent.name" type="text" placeholder="e.g. CUET HackFest 2026" class="glass-input w-full text-sm" />
          </div>

          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="block text-xs sm:text-sm font-bold text-slate-700 mb-1">Category</label>
              <select v-model="newEvent.category" class="glass-input w-full text-sm bg-white font-medium">
                <option value="Hackathon">Hackathon</option>
                <option value="Robotics">Robotics</option>
                <option value="Cultural">Cultural</option>
                <option value="Gaming">Gaming</option>
              </select>
            </div>

            <div>
              <label class="block text-xs sm:text-sm font-bold text-slate-700 mb-1">Prize pool (BDT)</label>
              <input v-model.number="newEvent.prizePool" type="number" class="glass-input w-full text-sm font-mono" />
            </div>
          </div>

          <div>
            <label class="block text-xs sm:text-sm font-bold text-slate-700 mb-1">Description</label>
            <textarea v-model="newEvent.description" rows="3" class="glass-input w-full text-sm" placeholder="Detailed event highlights..."></textarea>
          </div>
        </div>

        <div class="pt-4 border-t border-slate-200 flex items-center justify-end gap-3">
          <button @click="showCreateModal = false" class="glass-button-secondary text-sm py-2 px-4">Cancel</button>
          <button @click="submitCreateEvent" class="glass-button text-sm py-2 px-6">Publish event</button>
        </div>
      </div>
    </div>
    </template>

    <!-- TAB 2: EVENT & SEGMENTS DESK -->
    <EventManagement v-else-if="activeTab === 'events'" />

  </div>
</template>
