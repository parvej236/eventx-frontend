<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { 
  GraduationCap, 
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
  BookOpen,
  Building,
  Award
} from 'lucide-vue-next'
const departmentsList = ref([])
const searchDeptQuery = ref('')
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
const deptToDelete = ref(null)
const isDeleting = ref(false)

// Form Modal State (Add / Edit)
const showFormModal = ref(false)
const isEditing = ref(false)
const editingDeptId = ref(null)
const isSubmitting = ref(false)

const deptForm = ref({
  name: '',
  code: ''
})

// Pagination State
const currentPage = ref(1)
const itemsPerPage = ref(6)

const fetchDepartments = async () => {
  isLoading.value = true
  try {
    const res = await fetch('http://localhost:8080/api/departments')
    if (res.ok) {
      departmentsList.value = await res.json()
    }
  } catch (err) {
    showToast('Failed to load departments from server', 'error')
  } finally {
    isLoading.value = false
  }
}

onMounted(fetchDepartments)

// Stats Computed
const totalDeptsCount = computed(() => departmentsList.value.length)
const engDeptsCount = computed(() => departmentsList.value.filter(d => 
  d.name?.toLowerCase().includes('engineering') || d.code?.includes('E')
).length)
const sciDeptsCount = computed(() => totalDeptsCount.value - engDeptsCount.value)

// Filtered & Sorted Departments (Descending Order)
const filteredDepartments = computed(() => {
  let list = [...(departmentsList.value || [])]

  if (searchDeptQuery.value.trim()) {
    const q = searchDeptQuery.value.toLowerCase()
    list = list.filter(d => 
      d.name?.toLowerCase().includes(q) ||
      d.code?.toLowerCase().includes(q)
    )
  }

  // Sort descending by ID (newest first)
  list.sort((a, b) => {
    const idA = Number(a.departmentId || a.id || 0)
    const idB = Number(b.departmentId || b.id || 0)
    return idB - idA
  })

  return list
})

watch([searchDeptQuery, itemsPerPage], () => {
  currentPage.value = 1
})

const totalPages = computed(() => {
  return Math.ceil(filteredDepartments.value.length / itemsPerPage.value) || 1
})

const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage.value)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage.value, filteredDepartments.value.length))

const paginatedDepartments = computed(() => {
  return filteredDepartments.value.slice(startIndex.value, endIndex.value)
})

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

// Open Modal to Add
const openAddModal = () => {
  isEditing.value = false
  editingDeptId.value = null
  deptForm.value = { name: '', code: '' }
  showFormModal.value = true
}

// Open Modal to Edit
const openEditModal = (dept) => {
  isEditing.value = true
  editingDeptId.value = dept.departmentId || dept.id
  deptForm.value = {
    name: dept.name || '',
    code: dept.code || ''
  }
  showFormModal.value = true
}

// Submit Form (Create / Update)
const handleSaveDepartment = async () => {
  if (!deptForm.value.name.trim() || !deptForm.value.code.trim()) {
    showToast('Please provide both department name and code', 'warning')
    return
  }

  isSubmitting.value = true
  const payload = {
    name: deptForm.value.name,
    code: deptForm.value.code.toUpperCase().trim()
  }

  try {
    if (isEditing.value) {
      // PUT UPDATE
      const res = await fetch(`http://localhost:8080/api/departments/${editingDeptId.value}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })

      if (res.ok) {
        const updated = await res.json()
        const index = departmentsList.value.findIndex(d => (d.departmentId || d.id) === editingDeptId.value)
        if (index !== -1) {
          departmentsList.value[index] = updated
        } else {
          await fetchDepartments()
        }
        showToast('Department details updated successfully', 'success')
        showFormModal.value = false
      } else {
        showToast('Failed to update department details', 'error')
      }
    } else {
      // POST CREATE
      const res = await fetch('http://localhost:8080/api/departments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })

      if (res.ok) {
        const added = await res.json()
        departmentsList.value.unshift(added)
        showToast('New academic department created successfully', 'success')
        showFormModal.value = false
      } else {
        showToast('Failed to create department', 'error')
      }
    }
  } catch (err) {
    showToast('Network error while saving department', 'error')
  } finally {
    isSubmitting.value = false
  }
}

// Trigger Delete Modal
const confirmDeleteDept = (dept) => {
  deptToDelete.value = dept
  showDeleteModal.value = true
}

// Execute Delete API
const executeDeleteDept = async () => {
  if (!deptToDelete.value) return
  const id = deptToDelete.value.departmentId || deptToDelete.value.id
  isDeleting.value = true

  try {
    const res = await fetch(`http://localhost:8080/api/departments/${id}`, { method: 'DELETE' })
    if (res.ok) {
      departmentsList.value = departmentsList.value.filter(d => (d.departmentId || d.id) !== id)
      showToast('Department removed successfully', 'success')
    } else {
      showToast('Failed to remove department', 'error')
    }
  } catch (err) {
    showToast('Network error while removing department', 'error')
  } finally {
    isDeleting.value = false
    showDeleteModal.value = false
    deptToDelete.value = null
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
            <h3 class="text-base font-bold text-slate-900">Delete department?</h3>
            <p class="text-xs text-slate-500 font-medium mt-0.5">This action cannot be undone.</p>
          </div>
        </div>

        <div v-if="deptToDelete" class="p-3 bg-slate-50 rounded-xl border border-slate-200 flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-purple-100 border border-purple-200 flex items-center justify-center shrink-0 font-mono font-bold text-purple-800 text-xs">
            {{ deptToDelete.code }}
          </div>
          <div class="min-w-0 flex-1">
            <h4 class="text-xs font-bold text-slate-900 truncate">{{ deptToDelete.name }}</h4>
            <p class="text-[11px] text-slate-500 truncate">Department ID: #{{ deptToDelete.departmentId || deptToDelete.id }}</p>
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
            @click="executeDeleteDept" 
            :disabled="isDeleting"
            class="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-rose-600 hover:bg-rose-700 text-white font-semibold text-xs shadow-xs transition-colors"
          >
            <Loader2 v-if="isDeleting" class="w-3.5 h-3.5 animate-spin" />
            <Trash2 v-else class="w-3.5 h-3.5" />
            {{ isDeleting ? 'Deleting...' : 'Confirm delete' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Header Controls -->
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
      <div>
        <h2 class="text-xl font-bold text-slate-900">Academic departments</h2>
        <p class="text-xs text-slate-600 font-medium mt-0.5">Manage official faculties and department branches across CUET</p>
      </div>
      <div class="flex items-center gap-2">
        <button @click="openAddModal" class="flex items-center gap-2 bg-purple-600 hover:bg-purple-700 text-white text-xs font-bold px-3.5 py-1.5 rounded-lg transition-all shadow-xs">
          <Plus class="w-4 h-4" />
          Add department
        </button>
      </div>
    </div>


    <!-- Overview Stats Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-3 gap-2.5">
      <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
        <div class="min-w-0">
          <p class="text-xs font-medium text-slate-500 truncate">Total departments</p>
          <h3 class="text-base sm:text-lg font-extrabold text-slate-900 leading-tight mt-0.5">{{ totalDeptsCount }}</h3>
        </div>
        <div class="w-7 h-7 rounded-md bg-purple-50 text-purple-600 flex items-center justify-center shrink-0">
          <GraduationCap class="w-3.5 h-3.5" />
        </div>
      </div>

      <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
        <div class="min-w-0">
          <p class="text-xs font-medium text-slate-500 truncate">Engineering disciplines</p>
          <h3 class="text-base sm:text-lg font-extrabold text-purple-700 leading-tight mt-0.5">{{ engDeptsCount }}</h3>
        </div>
        <div class="w-7 h-7 rounded-md bg-purple-100 text-purple-700 flex items-center justify-center shrink-0">
          <Building class="w-3.5 h-3.5" />
        </div>
      </div>

      <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
        <div class="min-w-0">
          <p class="text-xs font-medium text-slate-500 truncate">Sciences & humanities</p>
          <h3 class="text-base sm:text-lg font-extrabold text-blue-700 leading-tight mt-0.5">{{ sciDeptsCount }}</h3>
        </div>
        <div class="w-7 h-7 rounded-md bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
          <BookOpen class="w-3.5 h-3.5" />
        </div>
      </div>
    </div>

    <!-- Search Bar & Filters -->
    <div class="glass-panel p-3 bg-white rounded-xl border border-slate-200 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-2.5">
      <div class="relative flex-1 max-w-md">
        <Search class="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
        <input 
          v-model="searchDeptQuery" 
          type="text" 
          placeholder="Search department code or title..." 
          class="w-full bg-white border border-slate-300 text-xs rounded-lg pl-8 pr-3 py-1.5 text-slate-900 focus:outline-none focus:ring-2 focus:ring-purple-600 shadow-2xs" 
        />
      </div>

      <div class="flex items-center gap-1.5">
        <label class="text-xs font-medium text-slate-600">Per page:</label>
        <select v-model.number="itemsPerPage" class="bg-white border border-slate-300 text-xs font-semibold rounded-md px-1.5 py-1 text-slate-900 focus:ring-2 focus:ring-purple-600">
          <option :value="6">6</option>
          <option :value="12">12</option>
          <option :value="24">24</option>
        </select>
      </div>
    </div>

    <!-- Result Counter -->
    <div class="flex items-center justify-between px-1 text-xs text-slate-600 font-medium">
      <div class="flex items-center gap-2">
        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 bg-purple-50 text-purple-800 border border-purple-200 rounded-full font-semibold text-xs">
          <Filter class="w-3 h-3" />
          Found {{ filteredDepartments.length }} matching {{ filteredDepartments.length === 1 ? 'department' : 'departments' }}
        </span>
        <span class="text-slate-500 font-medium text-xs">out of {{ totalDeptsCount }} total branches</span>
      </div>
    </div>

    <!-- Departments Table -->
    <div class="bg-white rounded-xl border border-slate-200 shadow-xs overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs sm:text-sm">
          <thead class="bg-slate-50 text-slate-700 font-bold border-b border-slate-200">
            <tr>
              <th class="py-3 px-4">Code</th>
              <th class="py-3 px-4">Department name</th>
              <th class="py-3 px-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="d in paginatedDepartments" :key="d.departmentId || d.id" class="hover:bg-slate-50 transition-colors">
              <td class="py-3 px-4">
                <span class="px-2.5 py-1 rounded-md text-xs font-mono font-bold bg-purple-50 text-purple-700 border border-purple-200 inline-block">
                  {{ d.code }}
                </span>
              </td>
              <td class="py-3 px-4 font-bold text-slate-900">
                <div class="flex items-center gap-2">
                  <GraduationCap class="w-4 h-4 text-purple-600 shrink-0" />
                  <span>{{ d.name }}</span>
                </div>
              </td>
              <td class="py-3 px-4 text-right space-x-1">
                <button @click="openEditModal(d)" class="p-1.5 text-slate-600 hover:text-purple-600 hover:bg-purple-50 rounded-md transition-colors" title="Edit department">
                  <Edit3 class="w-3.5 h-3.5" />
                </button>
                <button @click="confirmDeleteDept(d)" class="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors" title="Delete department">
                  <Trash2 class="w-3.5 h-3.5" />
                </button>
              </td>
            </tr>
            <tr v-if="paginatedDepartments.length === 0 && !isLoading">
              <td colspan="3" class="py-6 text-center text-slate-500 font-medium">No academic departments found.</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination Footer Controls -->
      <div v-if="filteredDepartments.length > 0" class="p-3 bg-slate-50/80 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-2.5 text-xs text-slate-700 font-medium">
        <div>
          Showing <span class="font-bold text-slate-900">{{ startIndex + 1 }}</span> to <span class="font-bold text-slate-900">{{ endIndex }}</span> of <span class="font-bold text-slate-900">{{ filteredDepartments.length }}</span> departments
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
    </div>

    <!-- Modal Form: Add / Edit Department -->
    <div v-if="showFormModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs">
      <div class="bg-white rounded-2xl border border-slate-200 shadow-2xl max-w-md w-full p-6 space-y-4 animate-in fade-in zoom-in-95 duration-200">
        <div class="flex items-center justify-between border-b border-slate-100 pb-3">
          <div class="flex items-center gap-2 text-purple-700 font-bold text-base">
            <GraduationCap class="w-5 h-5" />
            <span>{{ isEditing ? 'Edit department profile' : 'Add new department' }}</span>
          </div>
          <button @click="showFormModal = false" class="text-slate-400 hover:text-slate-700 transition-colors">
            <X class="w-4 h-4" />
          </button>
        </div>

        <form @submit.prevent="handleSaveDepartment" class="space-y-4">
          <div>
            <label class="text-xs font-semibold text-slate-800">Department code *</label>
            <input 
              v-model="deptForm.code" 
              type="text" 
              required 
              class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-purple-600 uppercase font-mono font-bold" 
              placeholder="e.g. CSE" 
            />
          </div>

          <div>
            <label class="text-xs font-semibold text-slate-800">Full department name *</label>
            <input 
              v-model="deptForm.name" 
              type="text" 
              required 
              class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-purple-600 font-medium" 
              placeholder="e.g. Computer Science & Engineering" 
            />
          </div>

          <div class="flex items-center justify-end gap-2.5 pt-3 border-t border-slate-100">
            <button 
              type="button" 
              @click="showFormModal = false" 
              :disabled="isSubmitting"
              class="px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-100 font-semibold text-xs transition-colors"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              :disabled="isSubmitting"
              class="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-purple-600 hover:bg-purple-700 text-white font-semibold text-xs shadow-xs transition-colors"
            >
              <Loader2 v-if="isSubmitting" class="w-3.5 h-3.5 animate-spin" />
              <Save v-else class="w-3.5 h-3.5" />
              {{ isSubmitting ? 'Saving...' : isEditing ? 'Update department' : 'Save department' }}
            </button>
          </div>
        </form>
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
