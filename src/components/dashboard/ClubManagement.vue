<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { 
  Building2, 
  Search, 
  Plus, 
  Trash2, 
  Edit3, 
  CheckCircle2, 
  AlertCircle, 
  AlertTriangle, 
  X, 
  Upload, 
  Loader2, 
  Save, 
  ArrowLeft, 
  Filter, 
  ChevronLeft, 
  ChevronRight,
  ShieldCheck,
  Layers,
  Sparkles,
  UserCheck,
  Mail
} from 'lucide-vue-next'

const clubQueries = [
  {
    name: '1. Multi-Table JOIN & Event Count',
    concepts: ['LEFT JOIN', 'COUNT', 'GROUP BY', 'COALESCE', 'ORDER BY'],
    purpose: 'Shows the list of official student clubs and total hosted competitions where department_id matches and status is ACTIVE',
    query: `SELECT c.club_id, c.name AS club_name, c.code, COALESCE(d.name, 'University Wide') AS department_name, COUNT(DISTINCT e.event_id) AS total_events_hosted FROM clubs c LEFT JOIN departments d ON c.department_id = d.department_id LEFT JOIN events e ON c.club_id = e.club_id GROUP BY c.club_id, c.name, c.code, d.name ORDER BY total_events_hosted DESC;`,
    explanation: 'Combines clubs, academic departments, and event logs via LEFT JOINs. Aggregates host metrics using COUNT(DISTINCT e.event_id) and GROUP BY.',
    columns: ['Club ID', 'Club Name', 'Code', 'Department', 'Events Hosted'],
    rows: [
      [1, 'CUET Computer Club', 'CCC', 'Computer Science & Engineering', 12],
      [2, 'CUET Robotics Society', 'CRS', 'Electrical & Electronic Eng.', 8],
      [3, 'CUET Debating Society', 'CDS', 'University Wide', 6]
    ]
  },
  {
    name: '2. Active Clubs EXISTS Subquery',
    concepts: ['EXISTS', 'SUBQUERY', 'WHERE', 'ORDER BY'],
    purpose: 'Shows the list of student clubs where EXISTS at least 1 upcoming event in the database',
    query: `SELECT c.club_id, c.name AS club_name, c.code FROM clubs c WHERE EXISTS (SELECT 1 FROM events e WHERE e.club_id = c.club_id AND e.status IN ('REGISTRATION OPEN', 'UPCOMING')) ORDER BY c.club_id ASC;`,
    explanation: 'Filters active university student clubs using a correlated EXISTS subquery on the events table.',
    columns: ['Club ID', 'Club Name', 'Code'],
    rows: [
      [1, 'CUET Computer Club', 'CCC'],
      [2, 'CUET Robotics Society', 'CRS'],
      [4, 'CUET Cultural Club', 'CCC-C']
    ]
  },
  {
    name: '3. Department Club Aggregation & HAVING',
    concepts: ['GROUP BY', 'HAVING', 'COUNT', 'INNER JOIN'],
    purpose: 'Shows the list of academic departments and hosted club counts where total_clubs > 0',
    query: `SELECT d.name AS department_name, COUNT(c.club_id) AS total_clubs FROM departments d INNER JOIN clubs c ON d.department_id = c.department_id GROUP BY d.department_id, d.name HAVING total_clubs > 0 ORDER BY total_clubs DESC;`,
    explanation: 'Groups departmental affiliations and counts official student chapters using GROUP BY and HAVING filters.',
    columns: ['Department Name', 'Hosted Student Clubs'],
    rows: [
      ['Computer Science & Engineering', 3],
      ['Electrical & Electronic Eng.', 2],
      ['Mechanical Engineering', 1]
    ]
  }
]
const clubsList = ref([])
const searchClubQuery = ref('')
const selectedStatusFilter = ref('ALL')
const isLoading = ref(true)
const isUploadingLogo = ref(false)
const fileInputRef = ref(null)
const previewLogo = ref('')

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

// Delete Modal State
const showDeleteModal = ref(false)
const clubToDelete = ref(null)
const isDeleting = ref(false)

// View & Form state: 'LIST' or 'FORM'
const viewMode = ref('LIST')
const isEditing = ref(false)
const editingClubId = ref(null)

// Pagination state
const currentPage = ref(1)
const itemsPerPage = ref(6)

// Form Model
const clubForm = ref({
  name: '',
  description: '',
  logoUrl: '',
  status: 'ACTIVE'
})

const defaultClubLogo = 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=300&q=80'

const fetchClubs = async () => {
  isLoading.value = true
  try {
    const res = await fetch('http://localhost:8080/api/clubs')
    if (res.ok) {
      clubsList.value = await res.json()
    }
  } catch (err) {
    showToast('Failed to fetch clubs from server', 'error')
  } finally {
    isLoading.value = false
  }
}

onMounted(fetchClubs)

// Computed Stats Cards
const totalClubsCount = computed(() => clubsList.value.length)
const activeClubsCount = computed(() => clubsList.value.filter(c => c.status?.toUpperCase() === 'ACTIVE').length)
const inactiveClubsCount = computed(() => clubsList.value.filter(c => c.status?.toUpperCase() !== 'ACTIVE').length)

// Format status badge text
const formatStatus = (status) => {
  if (!status) return 'Active'
  return status.toUpperCase() === 'ACTIVE' ? 'Active' : 'Inactive'
}

const triggerFileInput = () => {
  if (fileInputRef.value) {
    fileInputRef.value.click()
  }
}

// Upload Club Logo File to Server Disk (file/eventx/club/)
const handleLogoFileUpload = async (e) => {
  const file = e.target.files && e.target.files[0]
  if (!file) return

  if (file.size > 10 * 1024 * 1024) {
    showToast('Logo image size must be under 10MB', 'warning')
    return
  }

  // 1. Local preview while uploading
  const reader = new FileReader()
  reader.onload = (event) => {
    previewLogo.value = event.target.result
  }
  reader.readAsDataURL(file)

  // 2. Upload to server disk (/file/eventx/club/)
  isUploadingLogo.value = true
  const formData = new FormData()
  formData.append('file', file)

  try {
    const res = await fetch('http://localhost:8080/api/upload/club-logo', {
      method: 'POST',
      body: formData
    })

    if (res.ok) {
      const data = await res.json()
      if (data.logoUrl) {
        clubForm.value.logoUrl = data.logoUrl
        previewLogo.value = data.logoUrl
        showToast('Club logo uploaded successfully to server disk', 'success')
      }
    } else {
      showToast('Failed to upload club logo to backend server', 'error')
    }
  } catch (err) {
    showToast('Server upload connection error', 'error')
  } finally {
    isUploadingLogo.value = false
  }
}

// Open Form to Add New Club
const openAddPage = () => {
  isEditing.value = false
  editingClubId.value = null
  previewLogo.value = defaultClubLogo
  clubForm.value = {
    name: '',
    description: '',
    logoUrl: defaultClubLogo,
    status: 'ACTIVE'
  }
  viewMode.value = 'FORM'
}

// Open Form to Edit Existing Club
const openEditPage = (club) => {
  isEditing.value = true
  editingClubId.value = club.clubId || club.id
  previewLogo.value = club.logoUrl || defaultClubLogo
  clubForm.value = {
    name: club.name || '',
    description: club.description || '',
    logoUrl: club.logoUrl || defaultClubLogo,
    status: (club.status || 'ACTIVE').toUpperCase()
  }
  viewMode.value = 'FORM'
}

const backToList = () => {
  viewMode.value = 'LIST'
}

// Filtered & Sorted Clubs Computed (Descending Order - Newest First)
const filteredClubs = computed(() => {
  let list = [...(clubsList.value || [])]

  if (selectedStatusFilter.value !== 'ALL') {
    list = list.filter(c => c.status?.toUpperCase() === selectedStatusFilter.value)
  }

  if (searchClubQuery.value.trim()) {
    const q = searchClubQuery.value.toLowerCase()
    list = list.filter(c => 
      c.name?.toLowerCase().includes(q) ||
      c.description?.toLowerCase().includes(q) ||
      (c.organizers && c.organizers.some(o => o.name?.toLowerCase().includes(q) || o.email?.toLowerCase().includes(q)))
    )
  }

  // Sort descending by ID (newest clubs first)
  list.sort((a, b) => {
    const idA = Number(a.clubId || a.id || 0)
    const idB = Number(b.clubId || b.id || 0)
    return idB - idA
  })

  return list
})

watch([searchClubQuery, selectedStatusFilter, itemsPerPage], () => {
  currentPage.value = 1
})

const totalPages = computed(() => {
  return Math.ceil(filteredClubs.value.length / itemsPerPage.value) || 1
})

const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage.value)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage.value, filteredClubs.value.length))

const paginatedClubs = computed(() => {
  return filteredClubs.value.slice(startIndex.value, endIndex.value)
})

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

// Save or Update Club
const handleSaveClub = async () => {
  if (!clubForm.value.name.trim()) {
    showToast('Please provide a club name', 'warning')
    return
  }

  const payload = {
    name: clubForm.value.name,
    description: clubForm.value.description,
    logoUrl: clubForm.value.logoUrl || defaultClubLogo,
    status: clubForm.value.status
  }

  try {
    if (isEditing.value) {
      // PUT UPDATE
      const res = await fetch(`http://localhost:8080/api/clubs/${editingClubId.value}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })

      if (res.ok) {
        const updated = await res.json()
        const index = clubsList.value.findIndex(c => (c.clubId || c.id) === editingClubId.value)
        if (index !== -1) {
          clubsList.value[index] = updated
        } else {
          await fetchClubs()
        }
        showToast('Club details updated successfully', 'success')
        viewMode.value = 'LIST'
      } else {
        showToast('Failed to update club details', 'error')
      }
    } else {
      // POST CREATE
      const res = await fetch('http://localhost:8080/api/clubs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })

      if (res.ok) {
        const added = await res.json()
        clubsList.value.unshift(added)
        showToast('New club registered successfully', 'success')
        viewMode.value = 'LIST'
      } else {
        showToast('Failed to register new club', 'error')
      }
    }
  } catch (err) {
    showToast('Operation failed. Check server connection', 'error')
  }
}

// Delete Confirmation Modal Handler
const confirmDeleteClub = (club) => {
  clubToDelete.value = club
  showDeleteModal.value = true
}

const executeDeleteClub = async () => {
  if (!clubToDelete.value) return
  const id = clubToDelete.value.clubId || clubToDelete.value.id
  isDeleting.value = true

  try {
    const res = await fetch(`http://localhost:8080/api/clubs/${id}`, { method: 'DELETE' })
    if (res.ok) {
      clubsList.value = clubsList.value.filter(c => (c.clubId || c.id) !== id)
      showToast('Club removed successfully', 'success')
    } else {
      showToast('Failed to remove club', 'error')
    }
  } catch (err) {
    showToast('Network error while removing club', 'error')
  } finally {
    isDeleting.value = false
    showDeleteModal.value = false
    clubToDelete.value = null
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

    <!-- Delete Confirmation Modal Pop-Up -->
    <div v-if="showDeleteModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs">
      <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl max-w-md w-full p-6 space-y-4 animate-in fade-in zoom-in-95 duration-200">
        <div class="flex items-center gap-3 text-rose-600">
          <div class="w-10 h-10 rounded-full bg-rose-100 border border-rose-200 flex items-center justify-center shrink-0">
            <AlertTriangle class="w-5 h-5 text-rose-600" />
          </div>
          <div>
            <h3 class="text-base font-bold text-slate-900">Remove official club?</h3>
            <p class="text-xs text-slate-500 font-medium mt-0.5">This action cannot be undone.</p>
          </div>
        </div>

        <div v-if="clubToDelete" class="p-3 bg-slate-50 rounded-xl border border-slate-200 flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-white border border-slate-200 overflow-hidden shrink-0 flex items-center justify-center">
            <img v-if="clubToDelete.logoUrl" :src="clubToDelete.logoUrl" class="w-full h-full object-cover" />
            <Building2 v-else class="w-5 h-5 text-slate-400" />
          </div>
          <div class="min-w-0 flex-1">
            <h4 class="text-xs font-bold text-slate-900 truncate">{{ clubToDelete.name }}</h4>
            <p class="text-[11px] text-slate-500 truncate">Club ID: #{{ clubToDelete.clubId || clubToDelete.id }}</p>
          </div>
        </div>

        <div class="flex items-center justify-end gap-2.5 pt-2">
          <button 
            @click="showDeleteModal = false" 
            :disabled="isDeleting"
            class="px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-100 font-semibold text-xs transition-colors"
          >
            Cancel
          </button>
          <button 
            @click="executeDeleteClub" 
            :disabled="isDeleting"
            class="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-rose-600 hover:bg-rose-700 text-white font-semibold text-xs shadow-xs transition-colors"
          >
            <Loader2 v-if="isDeleting" class="w-3.5 h-3.5 animate-spin" />
            <Trash2 v-else class="w-3.5 h-3.5" />
            {{ isDeleting ? 'Removing...' : 'Confirm removal' }}
          </button>
        </div>
      </div>
    </div>

    <!-- MODE 1: CLUBS LIST PAGE -->
    <template v-if="viewMode === 'LIST'">
      <!-- Header Controls -->
      <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div>
          <h2 class="text-xl font-bold text-slate-900">Club management</h2>
          <p class="text-xs text-slate-600 font-medium mt-0.5">Manage official student chapters, campus societies, and assigned club organizers</p>
        </div>
        <div class="flex items-center gap-2">
          <button @click="openAddPage" class="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold px-3.5 py-1.5 rounded-lg transition-all shadow-xs">
            <Plus class="w-4 h-4" />
            Add club
          </button>
        </div>
      </div>

      <!-- Compact Overview Stats Cards -->
      <div class="grid grid-cols-2 sm:grid-cols-3 gap-2.5">
        <!-- Total Clubs -->
        <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
          <div class="min-w-0">
            <p class="text-xs font-medium text-slate-500 truncate">Total clubs</p>
            <h3 class="text-base sm:text-lg font-extrabold text-slate-900 leading-tight mt-0.5">{{ totalClubsCount }}</h3>
          </div>
          <div class="w-7 h-7 rounded-md bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
            <Building2 class="w-3.5 h-3.5" />
          </div>
        </div>

        <!-- Active Clubs -->
        <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
          <div class="min-w-0">
            <p class="text-xs font-medium text-slate-500 truncate">Active chapters</p>
            <h3 class="text-base sm:text-lg font-extrabold text-emerald-700 leading-tight mt-0.5">{{ activeClubsCount }}</h3>
          </div>
          <div class="w-7 h-7 rounded-md bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
            <ShieldCheck class="w-3.5 h-3.5" />
          </div>
        </div>

        <!-- Inactive Clubs -->
        <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
          <div class="min-w-0">
            <p class="text-xs font-medium text-slate-500 truncate">Inactive societies</p>
            <h3 class="text-base sm:text-lg font-extrabold text-amber-700 leading-tight mt-0.5">{{ inactiveClubsCount }}</h3>
          </div>
          <div class="w-7 h-7 rounded-md bg-amber-50 text-amber-600 flex items-center justify-center shrink-0">
            <Layers class="w-3.5 h-3.5" />
          </div>
        </div>
      </div>

      <!-- Filter & Search Controls Bar -->
      <div class="glass-panel p-3 bg-white rounded-xl border border-slate-200 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-2.5">
        <div class="relative flex-1 max-w-md">
          <Search class="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input 
            v-model="searchClubQuery" 
            type="text" 
            placeholder="Search club name, description, or organizer..." 
            class="w-full bg-white border border-slate-300 text-xs rounded-lg pl-8 pr-3 py-1.5 text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-600 shadow-2xs" 
          />
        </div>

        <div class="flex flex-wrap items-center gap-2">
          <div class="flex items-center gap-1">
            <label class="text-xs font-medium text-slate-600">Status:</label>
            <select v-model="selectedStatusFilter" class="bg-white border border-slate-300 text-xs font-semibold rounded-md px-2 py-1 text-slate-900 focus:ring-2 focus:ring-emerald-600">
              <option value="ALL">All status</option>
              <option value="ACTIVE">Active</option>
              <option value="INACTIVE">Inactive</option>
            </select>
          </div>

          <div class="flex items-center gap-1">
            <label class="text-xs font-medium text-slate-600">Per page:</label>
            <select v-model.number="itemsPerPage" class="bg-white border border-slate-300 text-xs font-semibold rounded-md px-1.5 py-1 text-slate-900 focus:ring-2 focus:ring-emerald-600">
              <option :value="6">6</option>
              <option :value="12">12</option>
              <option :value="24">24</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Result Counter -->
      <div class="flex items-center justify-between px-1 text-xs text-slate-600 font-medium">
        <div class="flex items-center gap-2">
          <span class="inline-flex items-center gap-1 px-2.5 py-0.5 bg-emerald-50 text-emerald-800 border border-emerald-200 rounded-full font-semibold text-xs">
            <Filter class="w-3 h-3" />
            Found {{ filteredClubs.length }} matching {{ filteredClubs.length === 1 ? 'club' : 'clubs' }}
          </span>
          <span class="text-slate-500 font-medium text-xs">out of {{ totalClubsCount }} total organizations</span>
        </div>
      </div>

      <!-- Clubs Grid Layout with Organizers List -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div 
          v-for="c in paginatedClubs" 
          :key="c.clubId || c.id" 
          class="bg-white rounded-xl border border-slate-200 p-4 shadow-2xs hover:shadow-md transition-all flex flex-col justify-between group"
        >
          <div class="space-y-3">
            <div class="flex items-start justify-between gap-3">
              <div class="w-11 h-11 rounded-xl bg-slate-50 border border-slate-200 overflow-hidden flex items-center justify-center shrink-0 shadow-2xs">
                <img v-if="c.logoUrl" :src="c.logoUrl" :alt="c.name" class="w-full h-full object-cover" />
                <Building2 v-else class="w-5 h-5 text-slate-400" />
              </div>
              <span :class="[
                'px-2.5 py-0.5 rounded text-xs font-semibold inline-flex items-center gap-1',
                c.status?.toUpperCase() === 'ACTIVE' ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-slate-100 text-slate-600 border border-slate-200'
              ]">
                {{ formatStatus(c.status) }}
              </span>
            </div>
            
            <div>
              <h3 class="font-bold text-slate-900 text-sm mb-1 group-hover:text-emerald-600 transition-colors">{{ c.name }}</h3>
              <p class="text-xs text-slate-500 line-clamp-2 leading-relaxed font-medium">{{ c.description || 'No description provided.' }}</p>
            </div>

            <!-- Organizers List for this Club -->
            <div class="pt-2 border-t border-slate-100 space-y-2">
              <div class="flex items-center justify-between text-xs">
                <span class="font-bold text-slate-800 flex items-center gap-1">
                  <Users class="w-3.5 h-3.5 text-amber-600" /> Organizers
                </span>
                <span class="px-2 py-0.2 bg-amber-50 text-amber-800 border border-amber-200 rounded-full font-bold text-[10px]">
                  {{ c.organizers ? c.organizers.length : 0 }} joined
                </span>
              </div>

              <!-- List of Organizers -->
              <div v-if="c.organizers && c.organizers.length > 0" class="space-y-1.5 max-h-36 overflow-y-auto pr-1">
                <div 
                  v-for="org in c.organizers" 
                  :key="org.userId || org.id"
                  class="flex items-center justify-between p-1.5 bg-slate-50 rounded-lg border border-slate-150 text-xs"
                >
                  <div class="flex items-center gap-2 min-w-0">
                    <div class="w-6 h-6 rounded-full bg-slate-200 border border-slate-300 overflow-hidden shrink-0 flex items-center justify-center">
                      <img v-if="org.imageUrl" :src="org.imageUrl" class="w-full h-full object-cover" />
                      <span v-else class="text-amber-800 font-bold text-[10px]">{{ org.name?.charAt(0) || 'O' }}</span>
                    </div>
                    <div class="min-w-0">
                      <span class="block font-semibold text-slate-900 truncate leading-tight">{{ org.name }}</span>
                      <span class="block text-[10px] text-slate-500 font-mono truncate leading-tight">{{ org.email }}</span>
                    </div>
                  </div>

                  <span class="px-1.5 py-0.5 bg-amber-100 text-amber-800 font-bold text-[10px] rounded shrink-0">
                    {{ org.clubPosition || 'Organizer' }}
                  </span>
                </div>
              </div>

              <div v-else class="py-2 px-3 bg-slate-50 rounded-lg border border-slate-100 text-center text-[11px] text-slate-400 font-medium italic">
                No organizers joined this club yet.
              </div>
            </div>

          </div>

          <div class="pt-3 border-t border-slate-100 mt-3 flex justify-between items-center text-xs">
            <span class="text-slate-400 font-mono text-[11px]">ID: #{{ c.clubId || c.id }}</span>
            <div class="flex items-center gap-1">
              <button @click="openEditPage(c)" class="p-1.5 text-slate-600 hover:text-emerald-600 hover:bg-emerald-50 rounded-md transition-colors" title="Edit club">
                <Edit3 class="w-3.5 h-3.5" />
              </button>
              <button @click="confirmDeleteClub(c)" class="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors" title="Remove club">
                <Trash2 class="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        </div>

        <div v-if="paginatedClubs.length === 0 && !isLoading" class="col-span-full py-10 bg-white rounded-xl border border-slate-200 text-center text-slate-500 font-medium text-xs">
          No matching campus clubs found.
        </div>
      </div>

      <!-- Pagination Footer Controls -->
      <div v-if="filteredClubs.length > 0" class="p-3 bg-slate-50/80 rounded-xl border border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-2.5 text-xs text-slate-700 font-medium">
        <div>
          Showing <span class="font-bold text-slate-900">{{ startIndex + 1 }}</span> to <span class="font-bold text-slate-900">{{ endIndex }}</span> of <span class="font-bold text-slate-900">{{ filteredClubs.length }}</span> clubs
        </div>

        <div class="flex items-center gap-1.5">
          <button 
            @click="prevPage" 
            :disabled="currentPage === 1"
            :class="[
              'px-2.5 py-1 rounded-md border text-xs font-semibold transition-all flex items-center gap-1',
              currentPage === 1 ? 'bg-slate-100 text-slate-400 border-slate-200 cursor-not-allowed' : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-50 hover:text-slate-900 shadow-2xs'
            ]"
          >
            <ChevronLeft class="w-3.5 h-3.5" /> Previous
          </button>

          <span class="px-2.5 py-0.5 bg-white border border-slate-300 rounded-md font-semibold text-slate-900 text-xs shadow-2xs">
            Page {{ currentPage }} of {{ totalPages }}
          </span>

          <button 
            @click="nextPage" 
            :disabled="currentPage >= totalPages"
            :class="[
              'px-2.5 py-1 rounded-md border text-xs font-semibold transition-all flex items-center gap-1',
              currentPage >= totalPages ? 'bg-slate-100 text-slate-400 border-slate-200 cursor-not-allowed' : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-50 hover:text-slate-900 shadow-2xs'
            ]"
          >
            Next <ChevronRight class="w-3.5 h-3.5" />
          </button>
        </div>
      </div>
    </template>

    <!-- MODE 2: FORM PAGE (ADD/EDIT CLUB) -->
    <template v-else-if="viewMode === 'FORM'">
      <!-- Form Header -->
      <div class="flex items-center justify-between border-b border-slate-200 pb-3">
        <div class="flex items-center gap-3">
          <button @click="backToList" class="p-1.5 rounded-lg bg-white border border-slate-300 hover:bg-slate-100 text-slate-700 transition-colors">
            <ArrowLeft class="w-4 h-4" />
          </button>
          <div>
            <h2 class="text-lg font-bold text-slate-900">{{ isEditing ? 'Edit club profile' : 'Register new campus club' }}</h2>
            <p class="text-xs text-slate-600 font-medium mt-0.5">
              {{ isEditing ? 'Update club profile, logo, and active state' : 'Register an official CUET student society and upload logo to Ubuntu server disk' }}
            </p>
          </div>
        </div>
      </div>

      <!-- Main Form Card -->
      <div class="glass-panel p-5 bg-white rounded-xl border border-slate-200 shadow-xs max-w-2xl">
        <form @submit.prevent="handleSaveClub" class="space-y-5">
          
          <!-- Server Disk Logo Upload Zone -->
          <div class="flex flex-col sm:flex-row items-center gap-4 p-3 bg-slate-50 rounded-lg border border-slate-200">
            <div class="w-16 h-16 rounded-xl border-2 border-emerald-600 shadow-xs overflow-hidden shrink-0 bg-white flex items-center justify-center relative">
              <img v-if="previewLogo || clubForm.logoUrl" :src="previewLogo || clubForm.logoUrl" class="w-full h-full object-cover" />
              <Building2 v-else class="w-8 h-8 text-slate-400" />
              
              <div v-if="isUploadingLogo" class="absolute inset-0 bg-slate-900/60 flex items-center justify-center text-white">
                <Loader2 class="w-5 h-5 animate-spin" />
              </div>
            </div>

            <div class="space-y-1 text-center sm:text-left flex-1">
              <label class="block text-xs font-semibold text-slate-900">Upload club logo image</label>
              <p class="text-xs text-slate-500 font-medium">Saves file under <code class="bg-slate-200 px-1 py-0.5 rounded text-slate-800">file/eventx/club/</code></p>
              
              <div class="flex flex-wrap items-center gap-2 justify-center sm:justify-start pt-0.5">
                <button type="button" @click="triggerFileInput" class="inline-flex items-center gap-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold px-3 py-1.5 rounded-md transition-all shadow-xs">
                  <Upload class="w-3.5 h-3.5" />
                  {{ isUploadingLogo ? 'Uploading...' : 'Choose logo file' }}
                </button>
                <input ref="fileInputRef" type="file" accept="image/*" @change="handleLogoFileUpload" :disabled="isUploadingLogo" class="hidden" />
              </div>
            </div>
          </div>

          <!-- Section 1: Club Identity -->
          <div class="space-y-3 border-b border-slate-100 pb-3">
            <h3 class="text-xs font-semibold text-slate-900 flex items-center gap-1.5">
              <Building2 class="w-3.5 h-3.5 text-emerald-600" /> Club details
            </h3>

            <div>
              <label class="text-xs font-semibold text-slate-800">Club name *</label>
              <input 
                v-model="clubForm.name" 
                type="text" 
                required 
                class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-emerald-600 font-medium" 
                placeholder="e.g. IEEE CUET Student Branch" 
              />
            </div>

            <div>
              <label class="text-xs font-semibold text-slate-800">Description</label>
              <textarea 
                v-model="clubForm.description" 
                rows="3" 
                class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-emerald-600 font-medium leading-relaxed" 
                placeholder="Provide an overview of the club's mission and activities..."
              ></textarea>
            </div>
          </div>

          <!-- Section 2: Logo URL & Status -->
          <div class="space-y-3">
            <h3 class="text-xs font-semibold text-slate-900 flex items-center gap-1.5">
              <Sparkles class="w-3.5 h-3.5 text-blue-600" /> Image URL & parameters
            </h3>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div class="sm:col-span-2">
                <label class="text-xs font-semibold text-slate-800">Saved logo URL</label>
                <input 
                  v-model="clubForm.logoUrl" 
                  type="text" 
                  class="w-full bg-slate-50 border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-emerald-600 font-mono" 
                  placeholder="http://localhost:8080/uploads/club/..." 
                />
              </div>

              <div>
                <label class="text-xs font-semibold text-slate-800">Status</label>
                <select v-model="clubForm.status" class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-emerald-600 font-semibold">
                  <option value="ACTIVE">Active</option>
                  <option value="INACTIVE">Inactive</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Form Action Buttons -->
          <div class="flex items-center justify-end gap-2.5 pt-4 border-t border-slate-200">
            <button type="button" @click="backToList" class="px-4 py-2 rounded-md border border-slate-300 text-slate-700 hover:bg-slate-100 font-semibold text-xs">
              Cancel
            </button>
            <button type="submit" class="flex items-center gap-1.5 px-5 py-2 rounded-md bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-xs shadow-xs transition-all">
              <Save class="w-3.5 h-3.5" />
              {{ isEditing ? 'Update club' : 'Save club' }}
            </button>
          </div>

        </form>
      </div>
    </template>

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
