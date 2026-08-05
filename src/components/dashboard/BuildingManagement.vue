<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { 
  MapPin, 
  Search, 
  Plus, 
  Trash2, 
  Edit3, 
  CheckCircle2, 
  AlertCircle, 
  AlertTriangle, 
  X, 
  Loader2, 
  Save, 
  Filter, 
  ChevronLeft, 
  ChevronRight,
  Building2,
  Globe,
  ExternalLink,
  Navigation
} from 'lucide-vue-next'

const buildingsList = ref([])
const searchBuildingQuery = ref('')
const selectedStatusFilter = ref('ALL')
const isLoading = ref(true)

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

// Delete Confirmation Modal State
const showDeleteModal = ref(false)
const buildingToDelete = ref(null)
const isDeleting = ref(false)

// Form Modal State (Add / Edit)
const showFormModal = ref(false)
const isEditing = ref(false)
const editingBuildingId = ref(null)
const isSubmitting = ref(false)

const buildingForm = ref({
  name: '',
  location: '',
  liveUrl: '',
  status: 'ACTIVE'
})

// Pagination State
const currentPage = ref(1)
const itemsPerPage = ref(6)

const fetchBuildings = async () => {
  isLoading.value = true
  try {
    const res = await fetch('http://localhost:8080/api/buildings')
    if (res.ok) {
      buildingsList.value = await res.json()
    } else {
      showToast('Failed to fetch campus buildings from backend', 'error')
    }
  } catch (err) {
    showToast('Network error while connecting to buildings API', 'error')
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  fetchBuildings()
})

// Filtered Buildings Computed
const filteredBuildings = computed(() => {
  return buildingsList.value.filter(b => {
    const nameMatch = (b.name || '').toLowerCase().includes(searchBuildingQuery.value.toLowerCase()) ||
                      (b.location || '').toLowerCase().includes(searchBuildingQuery.value.toLowerCase())
    const statusMatch = selectedStatusFilter.value === 'ALL' || (b.status || 'ACTIVE').toUpperCase() === selectedStatusFilter.value
    return nameMatch && statusMatch
  })
})

// Reset pagination when search query or filter changes
watch([searchBuildingQuery, selectedStatusFilter], () => {
  currentPage.value = 1
})

const totalPages = computed(() => {
  return Math.ceil(filteredBuildings.value.length / itemsPerPage.value) || 1
})

const paginatedBuildings = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filteredBuildings.value.slice(start, end)
})

const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

// Form Handlers
const openAddModal = () => {
  isEditing.value = false
  editingBuildingId.value = null
  buildingForm.value = {
    name: '',
    location: 'CUET Academic Zone',
    liveUrl: '',
    status: 'ACTIVE'
  }
  showFormModal.value = true
}

const openEditModal = (b) => {
  isEditing.value = true
  editingBuildingId.value = b.buildingId || b.id
  buildingForm.value = {
    name: b.name || '',
    location: b.location || '',
    liveUrl: b.liveUrl || '',
    status: b.status || 'ACTIVE'
  }
  showFormModal.value = true
}

const handleSaveBuilding = async () => {
  if (!buildingForm.value.name.trim()) {
    showToast('Building name is required', 'error')
    return
  }

  isSubmitting.value = true
  try {
    const payload = {
      name: buildingForm.value.name.trim(),
      location: buildingForm.value.location.trim(),
      liveUrl: buildingForm.value.liveUrl.trim(),
      status: buildingForm.value.status
    }

    let res
    if (isEditing.value) {
      res = await fetch(`http://localhost:8080/api/buildings/${editingBuildingId.value}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })
    } else {
      res = await fetch('http://localhost:8080/api/buildings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })
    }

    if (res.ok) {
      showToast(isEditing.value ? 'Venue updated successfully' : 'Campus venue added successfully', 'success')
      showFormModal.value = false
      fetchBuildings()
    } else {
      showToast('Failed to save building information', 'error')
    }
  } catch (err) {
    showToast('Error saving building to database', 'error')
  } finally {
    isSubmitting.value = false
  }
}

// Delete Handlers
const confirmDelete = (b) => {
  buildingToDelete.value = b
  showDeleteModal.value = true
}

const handleDeleteBuilding = async () => {
  if (!buildingToDelete.value) return
  isDeleting.value = true

  const id = buildingToDelete.value.buildingId || buildingToDelete.value.id
  try {
    const res = await fetch(`http://localhost:8080/api/buildings/${id}`, {
      method: 'DELETE'
    })

    if (res.ok) {
      showToast('Building venue removed successfully', 'success')
      showDeleteModal.value = false
      buildingToDelete.value = null
      fetchBuildings()
    } else {
      showToast('Failed to delete building venue', 'error')
    }
  } catch (err) {
    showToast('Error deleting venue from database', 'error')
  } finally {
    isDeleting.value = false
  }
}
</script>

<template>
  <div class="space-y-6">
    <!-- Header with Stats -->
    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4 bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
      <div class="flex items-center gap-3">
        <div class="p-3 bg-blue-50 text-blue-600 rounded-xl border border-blue-100">
          <Building2 class="w-6 h-6" />
        </div>
        <div>
          <h2 class="text-xl font-bold text-slate-900">Campus Venue & Buildings</h2>
          <p class="text-xs text-slate-500 font-medium">Manage CUET auditoriums, halls, and academic buildings used for events</p>
        </div>
      </div>

      <div class="flex items-center gap-3">
        <div class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-center">
          <span class="block text-xs font-bold text-slate-400 uppercase">Total Venues</span>
          <span class="text-base font-extrabold text-slate-800">{{ buildingsList.length }}</span>
        </div>
        <div class="px-4 py-2 bg-emerald-50 border border-emerald-200 rounded-xl text-center">
          <span class="block text-xs font-bold text-emerald-600 uppercase">Active</span>
          <span class="text-base font-extrabold text-emerald-700">{{ buildingsList.filter(b => (b.status || 'ACTIVE') === 'ACTIVE').length }}</span>
        </div>
        <button 
          @click="openAddModal"
          class="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-4 py-3 rounded-xl shadow-md transition-all active:scale-95"
        >
          <Plus class="w-4 h-4" />
          Add Venue Building
        </button>
      </div>
    </div>

    <!-- Search & Filter Controls -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
      <div class="relative w-full sm:w-80">
        <Search class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
        <input 
          v-model="searchBuildingQuery" 
          type="text" 
          placeholder="Search by venue name or location..." 
          class="w-full pl-9 pr-4 py-2 text-xs rounded-xl border border-slate-200 bg-slate-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all"
        />
      </div>

      <div class="flex items-center gap-2 w-full sm:w-auto justify-end">
        <div class="flex items-center gap-2 bg-slate-50 border border-slate-200 px-3 py-1.5 rounded-xl text-xs">
          <Filter class="w-3.5 h-3.5 text-slate-400" />
          <select v-model="selectedStatusFilter" class="bg-transparent text-xs font-semibold text-slate-700 focus:outline-none">
            <option value="ALL">All Status</option>
            <option value="ACTIVE">Active Only</option>

            <option value="INACTIVE">Inactive / Closed</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
    <div 
      v-if="toast.show" 
      :class="[
        toast.type === 'success' ? 'bg-emerald-600 text-white' : 'bg-rose-600 text-white',
        'fixed bottom-6 right-6 z-50 px-4 py-3 rounded-xl shadow-xl flex items-center gap-3 transition-all duration-300'
      ]"
    >
      <CheckCircle2 v-if="toast.type === 'success'" class="w-5 h-5" />
      <AlertCircle v-else class="w-5 h-5" />
      <span class="text-xs font-bold">{{ toast.message }}</span>
    </div>

    <!-- Buildings Table Card -->
    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
      <div v-if="isLoading" class="p-12 text-center text-slate-400 flex flex-col items-center gap-3">
        <Loader2 class="w-8 h-8 animate-spin text-blue-600" />
        <span class="text-xs font-semibold">Loading CUET campus building locations...</span>
      </div>

      <div v-else-if="filteredBuildings.length === 0" class="p-12 text-center text-slate-500 flex flex-col items-center gap-2">
        <MapPin class="w-10 h-10 text-slate-300 mb-1" />
        <h4 class="text-sm font-bold text-slate-700">No Building Venues Found</h4>
        <p class="text-xs text-slate-400">Try adjusting your search criteria or add a new building.</p>
      </div>

      <div v-else class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-slate-50 text-slate-500 font-bold uppercase tracking-wider border-b border-slate-200">
            <tr>
              <th class="py-3.5 px-4">Building Name</th>
              <th class="py-3.5 px-4">Campus Location</th>
              <th class="py-3.5 px-4">Virtual Tour / Map</th>
              <th class="py-3.5 px-4">Status</th>
              <th class="py-3.5 px-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100 font-medium">
            <tr 
              v-for="b in paginatedBuildings" 
              :key="b.buildingId || b.id"
              class="hover:bg-slate-50/80 transition-colors"
            >
              <td class="py-4 px-4 font-bold text-slate-900 flex items-center gap-3">
                <div class="w-9 h-9 rounded-xl bg-blue-50 text-blue-600 flex items-center gap-1.5 justify-center font-bold border border-blue-100">
                  <MapPin class="w-4 h-4" />
                </div>
                <div>
                  <span class="block text-slate-900 font-bold text-xs">{{ b.name }}</span>
                  <span class="text-[10px] text-slate-400 font-mono">ID: #{{ b.buildingId || b.id }}</span>
                </div>
              </td>

              <td class="py-4 px-4 text-slate-600">
                <div class="flex items-center gap-1.5">
                  <Navigation class="w-3.5 h-3.5 text-slate-400" />
                  <span>{{ b.location || 'CUET Campus' }}</span>
                </div>
              </td>

              <td class="py-4 px-4">
                <a 
                  v-if="b.liveUrl" 
                  :href="b.liveUrl" 
                  target="_blank" 
                  class="inline-flex items-center gap-1 text-blue-600 hover:text-blue-700 font-semibold underline text-xs"
                >
                  <Globe class="w-3.5 h-3.5" />
                  View Map
                  <ExternalLink class="w-3 h-3 ml-0.5" />
                </a>
                <span v-else class="text-slate-400 italic">No URL linked</span>
              </td>

              <td class="py-4 px-4">
                <span 
                  :class="[
                    (b.status || 'ACTIVE').toUpperCase() === 'ACTIVE' 
                      ? 'bg-emerald-100 text-emerald-700 border-emerald-200' 
                      : 'bg-rose-100 text-rose-700 border-rose-200',
                    'px-2.5 py-1 rounded-full text-[10px] font-bold border inline-block uppercase'
                  ]"
                >
                  {{ b.status || 'ACTIVE' }}
                </span>
              </td>

              <td class="py-4 px-4 text-right space-x-1">
                <button 
                  @click="openEditModal(b)"
                  class="p-1.5 text-slate-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                  title="Edit Venue"
                >
                  <Edit3 class="w-4 h-4" />
                </button>

                <button 
                  @click="confirmDelete(b)"
                  class="p-1.5 text-slate-500 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors"
                  title="Delete Venue"
                >
                  <Trash2 class="w-4 h-4" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Table Footer / Pagination -->
      <div v-if="filteredBuildings.length > 0" class="p-4 bg-slate-50 border-t border-slate-200 flex items-center justify-between">
        <span class="text-xs text-slate-500 font-semibold">
          Showing {{ ((currentPage - 1) * itemsPerPage) + 1 }} to {{ Math.min(currentPage * itemsPerPage, filteredBuildings.length) }} of {{ filteredBuildings.length }} venues
        </span>

        <div class="flex items-center gap-2">
          <button 
            @click="prevPage" 
            :disabled="currentPage === 1"
            class="p-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed text-slate-600"
          >
            <ChevronLeft class="w-4 h-4" />
          </button>
          <span class="text-xs font-bold text-slate-700 px-2">Page {{ currentPage }} of {{ totalPages }}</span>
          <button 
            @click="nextPage" 
            :disabled="currentPage >= totalPages"
            class="p-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed text-slate-600"
          >
            <ChevronRight class="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>

    <!-- Add / Edit Modal -->
    <div v-if="showFormModal" class="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="bg-white border border-slate-200 w-full max-w-md rounded-2xl shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-150">
        <div class="p-5 border-b border-slate-100 flex items-center justify-between bg-slate-50">
          <div class="flex items-center gap-2.5">
            <div class="p-2 rounded-xl bg-blue-100 text-blue-700">
              <Building2 class="w-5 h-5" />
            </div>
            <h3 class="font-extrabold text-base text-slate-900">
              {{ isEditing ? 'Edit Building Venue' : 'Add Campus Venue Building' }}
            </h3>
          </div>
          <button @click="showFormModal = false" class="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg">
            <X class="w-5 h-5" />
          </button>
        </div>

        <form @submit.prevent="handleSaveBuilding" class="p-6 space-y-4">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Building / Venue Name *</label>
            <input 
              v-model="buildingForm.name"
              type="text"
              placeholder="e.g. CSE Multipurpose Building or Central Auditorium"
              class="w-full text-xs px-3.5 py-2.5 rounded-xl border border-slate-200 bg-slate-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all font-semibold"
              required
            />
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Campus Location / Zone</label>
            <input 
              v-model="buildingForm.location"
              type="text"
              placeholder="e.g. Academic Zone, North Campus"
              class="w-full text-xs px-3.5 py-2.5 rounded-xl border border-slate-200 bg-slate-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all"
            />
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Virtual Map / Directions URL</label>
            <input 
              v-model="buildingForm.liveUrl"
              type="url"
              placeholder="https://maps.google.com/..."
              class="w-full text-xs px-3.5 py-2.5 rounded-xl border border-slate-200 bg-slate-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all"
            />
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Operating Status</label>
            <select 
              v-model="buildingForm.status"
              class="w-full text-xs px-3.5 py-2.5 rounded-xl border border-slate-200 bg-slate-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all font-semibold"
            >
              <option value="ACTIVE font-bold">Active / Available</option>
              <option value="INACTIVE">Inactive / Under Maintenance</option>
            </select>
          </div>

          <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
            <button 
              type="button" 
              @click="showFormModal = false"
              class="px-4 py-2.5 text-xs font-bold text-slate-600 hover:bg-slate-100 rounded-xl transition-all"
            >
              Cancel
            </button>

            <button 
              type="submit" 
              :disabled="isSubmitting"
              class="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-5 py-2.5 rounded-xl shadow-md transition-all active:scale-95 disabled:opacity-50"
            >
              <Loader2 v-if="isSubmitting" class="w-4 h-4 animate-spin" />
              <Save v-else class="w-4 h-4" />
              {{ isEditing ? 'Update Building' : 'Create Venue' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="bg-white border border-slate-200 w-full max-w-sm rounded-2xl shadow-2xl p-6 text-center space-y-4">
        <div class="w-12 h-12 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center mx-auto border border-rose-100">
          <AlertTriangle class="w-6 h-6" />
        </div>

        <div>
          <h3 class="font-extrabold text-base text-slate-900">Remove Building Venue?</h3>
          <p class="text-xs text-slate-500 mt-1">
            Are you sure you want to remove <span class="font-bold text-slate-800">{{ buildingToDelete?.name }}</span>?
          </p>
        </div>

        <div class="flex items-center justify-center gap-3 pt-2">
          <button 
            @click="showDeleteModal = false"
            class="px-4 py-2.5 text-xs font-bold text-slate-600 hover:bg-slate-100 rounded-xl transition-all w-1/2"
          >
            Cancel
          </button>
          <button 
            @click="handleDeleteBuilding"
            :disabled="isDeleting"
            class="flex items-center justify-center gap-2 bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold px-4 py-2.5 rounded-xl shadow-md transition-all w-1/2 active:scale-95 disabled:opacity-50"
          >
            <Loader2 v-if="isDeleting" class="w-4 h-4 animate-spin" />
            <Trash2 v-else class="w-4 h-4" />
            Delete
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
