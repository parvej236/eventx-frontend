<script setup>
import { ref, computed, onMounted } from 'vue'
import { 
  ShieldCheck, 
  ExternalLink, 
  CheckCircle2, 
  XCircle, 
  Search, 
  Filter, 
  Loader2, 
  AlertTriangle, 
  AlertCircle, 
  X, 
  Building2, 
  UserCheck, 
  Clock, 
  FileText 
} from 'lucide-vue-next'

const verificationRequests = ref([])
const searchReqQuery = ref('')
const selectedStatusFilter = ref('ALL')
const isLoading = ref(true)
const updatingUserId = ref(null)

// Toast Notification State
const toast = ref({
  show: false,
  message: '',
  type: 'success'
})

const showToast = (message, type = 'success') => {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 4000)
}

const fetchVerifications = async () => {
  isLoading.value = true
  try {
    const res = await fetch('http://localhost:8080/api/organizer-verifications')
    if (res.ok) {
      verificationRequests.value = await res.json()
    }
  } catch (err) {
    showToast('Failed to load organizer verifications', 'error')
  } finally {
    isLoading.value = false
  }
}

onMounted(fetchVerifications)

// Computed Stats
const totalRequestsCount = computed(() => verificationRequests.value.length)
const pendingRequestsCount = computed(() => verificationRequests.value.filter(r => r.status?.toUpperCase() === 'PENDING').length)
const approvedRequestsCount = computed(() => verificationRequests.value.filter(r => r.status?.toUpperCase() === 'APPROVED').length)
const rejectedRequestsCount = computed(() => verificationRequests.value.filter(r => r.status?.toUpperCase() === 'REJECTED').length)

// Filtered Verification Requests
const filteredRequests = computed(() => {
  let list = [...(verificationRequests.value || [])]

  if (selectedStatusFilter.value !== 'ALL') {
    list = list.filter(r => r.status?.toUpperCase() === selectedStatusFilter.value)
  }

  if (searchReqQuery.value.trim()) {
    const q = searchReqQuery.value.toLowerCase()
    list = list.filter(r => 
      r.name?.toLowerCase().includes(q) ||
      r.email?.toLowerCase().includes(q) ||
      r.clubName?.toLowerCase().includes(q) ||
      r.clubPosition?.toLowerCase().includes(q)
    )
  }

  return list
})

// Update Status (Approve / Reject / Reset)
const handleUpdateStatus = async (userId, newStatus) => {
  updatingUserId.value = userId

  try {
    const res = await fetch(`http://localhost:8080/api/organizer-verifications/${userId}/status`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: newStatus })
    })

    if (res.ok) {
      const updated = await res.json()
      const index = verificationRequests.value.findIndex(r => (r.userId || r.id) === userId)
      if (index !== -1) {
        verificationRequests.value[index] = updated
      } else {
        await fetchVerifications()
      }
      
      const msg = newStatus === 'APPROVED' ? 'Organizer approved successfully' : 'Organizer submission rejected'
      showToast(msg, newStatus === 'APPROVED' ? 'success' : 'warning')
    } else {
      showToast('Failed to update verification status', 'error')
    }
  } catch (err) {
    showToast('Network error while updating status', 'error')
  } finally {
    updatingUserId.value = null
  }
}
</script>

<template>
  <div class="space-y-4 w-full relative">

    <!-- Toast Notification System -->
    <Transition name="toast">
      <div 
        v-if="toast.show" 
        :class="[
          'fixed bottom-5 right-5 z-50 flex items-center gap-3 px-4 py-3 rounded-xl shadow-xl border text-xs font-semibold max-w-sm transition-all',
          toast.type === 'success' ? 'bg-emerald-950 text-emerald-100 border-emerald-800' :
          toast.type === 'warning' ? 'bg-amber-950 text-amber-100 border-amber-800' : 'bg-rose-950 text-rose-100 border-rose-800'
        ]"
      >
        <CheckCircle2 v-if="toast.type==='success'" class="w-4 h-4 text-emerald-400 shrink-0" />
        <AlertTriangle v-else-if="toast.type==='warning'" class="w-4 h-4 text-amber-400 shrink-0" />
        <AlertCircle v-else class="w-4 h-4 text-rose-400 shrink-0" />
        
        <span class="flex-1">{{ toast.message }}</span>
        
        <button @click="toast.show = false" class="text-slate-400 hover:text-white transition-colors">
          <X class="w-3.5 h-3.5" />
        </button>
      </div>
    </Transition>

    <!-- Header Controls -->
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
      <div>
        <h2 class="text-xl font-bold text-slate-900">Verify organizers</h2>
        <p class="text-xs text-slate-600 font-medium mt-0.5">Review executive authorization documents and approve club organizer access</p>
      </div>
    </div>

    <!-- Overview Stats Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
      <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
        <div class="min-w-0">
          <p class="text-xs font-medium text-slate-500 truncate">Total submissions</p>
          <h3 class="text-base sm:text-lg font-extrabold text-slate-900 leading-tight mt-0.5">{{ totalRequestsCount }}</h3>
        </div>
        <div class="w-7 h-7 rounded-md bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
          <FileText class="w-3.5 h-3.5" />
        </div>
      </div>

      <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
        <div class="min-w-0">
          <p class="text-xs font-medium text-slate-500 truncate">Pending review</p>
          <h3 class="text-base sm:text-lg font-extrabold text-amber-700 leading-tight mt-0.5">{{ pendingRequestsCount }}</h3>
        </div>
        <div class="w-7 h-7 rounded-md bg-amber-50 text-amber-600 flex items-center justify-center shrink-0">
          <Clock class="w-3.5 h-3.5" />
        </div>
      </div>

      <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
        <div class="min-w-0">
          <p class="text-xs font-medium text-slate-500 truncate">Approved</p>
          <h3 class="text-base sm:text-lg font-extrabold text-emerald-700 leading-tight mt-0.5">{{ approvedRequestsCount }}</h3>
        </div>
        <div class="w-7 h-7 rounded-md bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
          <UserCheck class="w-3.5 h-3.5" />
        </div>
      </div>

      <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
        <div class="min-w-0">
          <p class="text-xs font-medium text-slate-500 truncate">Rejected</p>
          <h3 class="text-base sm:text-lg font-extrabold text-rose-700 leading-tight mt-0.5">{{ rejectedRequestsCount }}</h3>
        </div>
        <div class="w-7 h-7 rounded-md bg-rose-50 text-rose-600 flex items-center justify-center shrink-0">
          <XCircle class="w-3.5 h-3.5" />
        </div>
      </div>
    </div>

    <!-- Filter & Search Bar -->
    <div class="glass-panel p-3 bg-white rounded-xl border border-slate-200 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-2.5">
      <div class="relative flex-1 max-w-md">
        <Search class="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
        <input 
          v-model="searchReqQuery" 
          type="text" 
          placeholder="Search organizer name, email, club, or position..." 
          class="w-full bg-white border border-slate-300 text-xs rounded-lg pl-8 pr-3 py-1.5 text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-600 shadow-2xs" 
        />
      </div>

      <div class="flex items-center gap-1">
        <label class="text-xs font-medium text-slate-600">Filter status:</label>
        <select v-model="selectedStatusFilter" class="bg-white border border-slate-300 text-xs font-semibold rounded-md px-2 py-1 text-slate-900 focus:ring-2 focus:ring-blue-600">
          <option value="ALL">All status</option>
          <option value="PENDING">Pending</option>
          <option value="APPROVED">Approved</option>
          <option value="REJECTED">Rejected</option>
        </select>
      </div>
    </div>

    <!-- Result Counter -->
    <div class="flex items-center justify-between px-1 text-xs text-slate-600 font-medium">
      <div class="flex items-center gap-2">
        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 bg-blue-50 text-blue-800 border border-blue-200 rounded-full font-semibold text-xs">
          <Filter class="w-3 h-3" />
          Found {{ filteredRequests.length }} matching {{ filteredRequests.length === 1 ? 'request' : 'requests' }}
        </span>
        <span class="text-slate-500 font-medium text-xs">out of {{ totalRequestsCount }} total submissions</span>
      </div>
    </div>

    <!-- Requests Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div 
        v-for="req in filteredRequests" 
        :key="req.userId || req.id" 
        class="bg-white rounded-xl border border-slate-200 p-4 shadow-2xs hover:shadow-md transition-all flex flex-col justify-between space-y-4"
      >
        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <span :class="[
              req.status?.toUpperCase() === 'APPROVED' ? 'bg-emerald-50 text-emerald-700 border-emerald-200' :
              req.status?.toUpperCase() === 'REJECTED' ? 'bg-rose-50 text-rose-700 border-rose-200' : 'bg-amber-50 text-amber-700 border-amber-200',
              'px-2.5 py-0.5 rounded-full text-xs font-semibold border flex items-center gap-1'
            ]">
              <ShieldCheck class="w-3.5 h-3.5" />
              {{ req.status?.toUpperCase() === 'APPROVED' ? 'Approved' : req.status?.toUpperCase() === 'REJECTED' ? 'Rejected' : 'Pending review' }}
            </span>

            <span class="text-slate-400 font-mono text-[11px]">ID: #{{ req.userId || req.id }}</span>
          </div>

          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-full bg-slate-100 border border-slate-200 overflow-hidden shrink-0 flex items-center justify-center">
              <img v-if="req.imageUrl" :src="req.imageUrl" :alt="req.name" class="w-full h-full object-cover" />
              <span v-else class="text-blue-700 font-bold text-xs">{{ req.name?.charAt(0) || 'O' }}</span>
            </div>
            <div class="min-w-0 flex-1">
              <h3 class="font-bold text-slate-900 text-sm truncate">{{ req.name }}</h3>
              <p class="text-xs text-amber-800 font-semibold truncate mt-0.5 flex items-center gap-1">
                <Building2 class="w-3 h-3 text-amber-600 shrink-0" />
                {{ req.clubPosition || 'Organizer' }} • {{ req.clubName || 'CUET Society' }}
              </p>
              <p class="text-[11px] text-slate-500 font-mono truncate mt-0.5">{{ req.email }}</p>
            </div>
          </div>

          <!-- Document Link Panel -->
          <div class="p-2.5 bg-slate-50 rounded-lg border border-slate-200 flex items-center justify-between">
            <span class="text-xs text-slate-600 font-mono truncate max-w-[200px]">
              {{ req.documentUrl?.split('/').pop() || 'proof_document.pdf' }}
            </span>
            <a :href="req.documentUrl" target="_blank" class="inline-flex items-center gap-1 text-xs font-semibold text-blue-600 hover:underline">
              View document <ExternalLink class="w-3 h-3" />
            </a>
          </div>
        </div>

        <!-- Action Controls -->
        <div class="pt-3 border-t border-slate-100 flex gap-2">
          <button 
            @click="handleUpdateStatus(req.userId || req.id, 'APPROVED')" 
            :disabled="updatingUserId === (req.userId || req.id)"
            :class="[
              'flex-1 flex items-center justify-center gap-1.5 text-xs font-semibold py-2 px-3 rounded-lg transition-all shadow-xs',
              req.status?.toUpperCase() === 'APPROVED' ? 'bg-emerald-700 text-white cursor-default' : 'bg-emerald-600 hover:bg-emerald-700 text-white'
            ]"
          >
            <Loader2 v-if="updatingUserId === (req.userId || req.id)" class="w-3.5 h-3.5 animate-spin" />
            <CheckCircle2 v-else class="w-3.5 h-3.5" /> 
            {{ req.status?.toUpperCase() === 'APPROVED' ? 'Approved' : 'Approve' }}
          </button>

          <button 
            @click="handleUpdateStatus(req.userId || req.id, 'REJECTED')" 
            :disabled="updatingUserId === (req.userId || req.id)"
            :class="[
              'flex-1 flex items-center justify-center gap-1.5 text-xs font-semibold py-2 px-3 rounded-lg border transition-all',
              req.status?.toUpperCase() === 'REJECTED' ? 'bg-rose-100 border-rose-300 text-rose-800' : 'bg-slate-50 hover:bg-rose-50 hover:text-rose-700 text-slate-700 border-slate-200'
            ]"
          >
            <Loader2 v-if="updatingUserId === (req.userId || req.id)" class="w-3.5 h-3.5 animate-spin" />
            <XCircle v-else class="w-3.5 h-3.5" /> 
            {{ req.status?.toUpperCase() === 'REJECTED' ? 'Rejected' : 'Reject' }}
          </button>
        </div>
      </div>

      <div v-if="filteredRequests.length === 0 && !isLoading" class="col-span-full py-10 bg-white rounded-xl border border-slate-200 text-center text-slate-500 font-medium text-xs">
        No matching organizer verification requests found.
      </div>
    </div>

  </div>
</template>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}
.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}
</style>
