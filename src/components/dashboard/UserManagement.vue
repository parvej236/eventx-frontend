<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { 
  Users, 
  Search, 
  Plus, 
  Trash2, 
  Edit3, 
  Shield, 
  GraduationCap, 
  Building2, 
  ChevronLeft, 
  ChevronRight, 
  ArrowLeft, 
  Save, 
  UserCheck,
  Image,
  Upload,
  Shirt,
  Lock,
  Mail,
  User as UserIcon,
  Loader2,
  Filter,
  CheckCircle2,
  AlertCircle,
  X,
  AlertTriangle,
  Award,
  Hash
} from 'lucide-vue-next'

const userQueries = [
  {
    name: '1. Multi-Table JOIN & IN Clause',
    concepts: ['LEFT JOIN', 'IN', 'COALESCE', 'ORDER BY'],
    purpose: 'Shows the list of user accounts and student profiles where user role IS IN ("STUDENT", "ORGANIZER")',
    query: `SELECT u.user_id, u.name, u.email, u.role, COALESCE(s.student_id, 'N/A') AS student_id, COALESCE(s.batch, 'N/A') AS batch, COALESCE(d.name, 'N/A') AS department_name FROM users u LEFT JOIN students s ON u.user_id = s.user_id LEFT JOIN departments d ON s.department_id = d.department_id WHERE u.role IN ('STUDENT', 'ORGANIZER') ORDER BY u.user_id ASC;`,
    explanation: 'Combines the users, students, and departments tables via LEFT JOINs. Filters records using the IN operator and formats NULL fields with COALESCE().',
    columns: ['User ID', 'Name', 'Email', 'Role', 'Student ID', 'Batch', 'Department'],
    rows: [
      [1, 'Tanvir Hossain', 'tanvir@cuet.ac.bd', 'STUDENT', '2304001', '2023', 'Computer Science & Eng.'],
      [2, 'Mahmudur Rahman', 'mahmud@cuet.ac.bd', 'ORGANIZER', '2304015', '2023', 'Computer Science & Eng.'],
      [3, 'Noshin Tarannum', 'noshin@cuet.ac.bd', 'STUDENT', '2405089', '2024', 'Electrical & Electronic Eng.'],
      [4, 'Adnan Chowdhury', 'adnan@cuet.ac.bd', 'STUDENT', '2408012', '2024', 'Mechanical Engineering']
    ]
  },
  {
    name: '2. Subquery with EXISTS',
    concepts: ['EXISTS', 'CORRELATED SUBQUERY', 'INNER JOIN', 'WHERE'],
    purpose: 'Shows the list of student accounts where EXISTS at least 1 paid event registration pass',
    query: `SELECT u.user_id, u.name, u.email, s.student_id, s.batch FROM users u INNER JOIN students s ON u.user_id = s.user_id WHERE EXISTS (SELECT 1 FROM registrations r WHERE r.user_id = u.user_id AND r.payment_status = 'PAID') ORDER BY s.student_id ASC;`,
    explanation: 'Executes a correlated subquery using EXISTS to check if each student has active paid event passes in the registrations table before including them in output.',
    columns: ['User ID', 'Student Name', 'Email', 'Student ID', 'Batch'],
    rows: [
      [1, 'Tanvir Hossain', 'tanvir@cuet.ac.bd', '2304001', '2023'],
      [3, 'Noshin Tarannum', 'noshin@cuet.ac.bd', '2405089', '2024']
    ]
  },
  {
    name: '3. Role Grouping & HAVING',
    concepts: ['GROUP BY', 'HAVING', 'COUNT', 'ORDER BY'],
    purpose: 'Shows the list of user roles and total accounts where total count IS GREATER THAN 0',
    query: `SELECT u.role, COUNT(u.user_id) AS total_users, COUNT(s.student_id) AS linked_students FROM users u LEFT JOIN students s ON u.user_id = s.user_id GROUP BY u.role HAVING total_users > 0 ORDER BY total_users DESC;`,
    explanation: 'Groups user profiles by role (STUDENT, ORGANIZER, ADMIN) and calculates aggregate user totals, enforcing minimum headcount constraints via HAVING clause.',
    columns: ['User Role', 'Total Accounts', 'Linked Student Profiles'],
    rows: [
      ['STUDENT', 140, 140],
      ['ORGANIZER', 15, 15],
      ['ADMIN', 3, 0]
    ]
  }
]
const usersList = ref([])
const clubsList = ref([])
const searchUserQuery = ref('')
const selectedRoleFilter = ref('ALL')
const selectedGenderFilter = ref('ALL')
const isLoading = ref(true)
const isUploadingImage = ref(false)
const fileInputRef = ref(null)
const previewImage = ref('')

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
const userToDelete = ref(null)
const isDeleting = ref(false)

// View state: 'LIST' or 'FORM'
const viewMode = ref('LIST') 
const isEditing = ref(false)
const editingUserId = ref(null)

// Pagination state
const currentPage = ref(1)
const itemsPerPage = ref(5)

// Form model containing all user fields matching AuthView signup parameters
const userForm = ref({
  name: '',
  email: '',
  role: 'STUDENT',
  gender: 'Male',
  tshirtSize: 'M',
  imageUrl: '',
  password: '',
  confirmPassword: '',
  // Student Specific
  studentId: '',
  batch: '',
  // Organizer Specific
  clubId: '',
  clubPosition: ''
})

const defaultAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=250&q=80'

const fetchUsers = async () => {
  isLoading.value = true
  try {
    const res = await fetch('http://localhost:8080/api/users')
    if (res.ok) {
      usersList.value = await res.json()
    }
  } catch (err) {
    showToast('Failed to load users from backend', 'error')
  } finally {
    isLoading.value = false
  }
}

const fetchClubs = async () => {
  try {
    const res = await fetch('http://localhost:8080/api/clubs')
    if (res.ok) {
      const data = await res.json()
      if (Array.isArray(data) && data.length > 0) {
        clubsList.value = data
      }
    }
  } catch (err) {
    console.info("Using local fallback clubs data")
  }
}

onMounted(() => {
  fetchUsers()
  fetchClubs()
})

// Stats Computed
const totalUsersCount = computed(() => usersList.value.length)
const totalStudentsCount = computed(() => usersList.value.filter(u => u.role?.toUpperCase() === 'STUDENT').length)
const totalOrganizersCount = computed(() => usersList.value.filter(u => u.role?.toUpperCase() === 'ORGANIZER').length)
const totalAdminsCount = computed(() => usersList.value.filter(u => u.role?.toUpperCase() === 'ADMIN').length)

// Format role text for display in title case
const formatRole = (role) => {
  if (!role) return 'Student'
  const r = role.toUpperCase()
  if (r === 'ADMIN') return 'Admin'
  if (r === 'ORGANIZER') return 'Organizer'
  return 'Student'
}

const triggerFileInput = () => {
  if (fileInputRef.value) {
    fileInputRef.value.click()
  }
}

// Upload Image File to Backend Server Disk (file/eventx/user/)
const handleImageFileUpload = async (e) => {
  const file = e.target.files && e.target.files[0]
  if (!file) return

  if (file.size > 10 * 1024 * 1024) {
    showToast('Image file size must be under 10MB', 'warning')
    return
  }

  // 1. Local preview while uploading
  const reader = new FileReader()
  reader.onload = (event) => {
    previewImage.value = event.target.result
  }
  reader.readAsDataURL(file)

  // 2. Multi-part upload to backend server disk
  isUploadingImage.value = true
  const formData = new FormData()
  formData.append('file', file)

  try {
    const res = await fetch('http://localhost:8080/api/upload/user-image', {
      method: 'POST',
      body: formData
    })

    if (res.ok) {
      const data = await res.json()
      if (data.imageUrl) {
        userForm.value.imageUrl = data.imageUrl
        previewImage.value = data.imageUrl
        showToast('Image uploaded successfully to server', 'success')
      }
    } else {
      showToast('Failed to upload image file to backend disk', 'error')
    }
  } catch (err) {
    showToast('Upload connection error. Please check server state', 'error')
  } finally {
    isUploadingImage.value = false
  }
}

// Open Add User Page
const openAddPage = () => {
  isEditing.value = false
  editingUserId.value = null
  previewImage.value = defaultAvatar
  userForm.value = {
    name: '',
    email: '',
    role: 'STUDENT',
    gender: 'Male',
    tshirtSize: 'M',
    imageUrl: defaultAvatar,
    password: '',
    confirmPassword: '',
    studentId: '',
    batch: '',
    clubId: '',
    clubPosition: ''
  }
  viewMode.value = 'FORM'
}

// Open Edit User Page
const openEditPage = (user) => {
  isEditing.value = true
  editingUserId.value = user.id || user.userId
  previewImage.value = user.imageUrl || defaultAvatar
  userForm.value = {
    name: user.name || '',
    email: user.email || '',
    role: (user.role || 'STUDENT').toUpperCase(),
    gender: user.gender || 'Male',
    tshirtSize: user.tshirtSize || 'M',
    imageUrl: user.imageUrl || defaultAvatar,
    password: '',
    confirmPassword: '',
    studentId: user.studentId || '',
    batch: user.batch || '',
    clubId: user.clubId || '',
    clubPosition: user.clubPosition || ''
  }
  viewMode.value = 'FORM'
}

const backToList = () => {
  viewMode.value = 'LIST'
}

// Filtered & Sorted Users Computed (Descending Order)
const filteredUsers = computed(() => {
  let list = [...(usersList.value || [])]

  if (selectedRoleFilter.value !== 'ALL') {
    list = list.filter(u => u.role?.toUpperCase() === selectedRoleFilter.value)
  }

  if (selectedGenderFilter.value !== 'ALL') {
    list = list.filter(u => u.gender?.toLowerCase() === selectedGenderFilter.value.toLowerCase())
  }

  if (searchUserQuery.value.trim()) {
    const q = searchUserQuery.value.toLowerCase()
    list = list.filter(u => 
      u.name?.toLowerCase().includes(q) ||
      u.email?.toLowerCase().includes(q) ||
      u.role?.toLowerCase().includes(q) ||
      u.studentId?.toLowerCase().includes(q) ||
      u.clubName?.toLowerCase().includes(q)
    )
  }

  // Sort descending by ID (newest accounts first)
  list.sort((a, b) => {
    const idA = Number(a.id || a.userId || 0)
    const idB = Number(b.id || b.userId || 0)
    return idB - idA
  })

  return list
})

watch([searchUserQuery, selectedRoleFilter, selectedGenderFilter, itemsPerPage], () => {
  currentPage.value = 1
})

const totalPages = computed(() => {
  return Math.ceil(filteredUsers.value.length / itemsPerPage.value) || 1
})

const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage.value)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage.value, filteredUsers.value.length))

const paginatedUsers = computed(() => {
  return filteredUsers.value.slice(startIndex.value, endIndex.value)
})

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

// Submit Form (Save or Update)
const handleSaveUser = async () => {
  if (!userForm.value.name.trim() || !userForm.value.email.trim()) {
    showToast('Please fill out all required fields', 'warning')
    return
  }

  if (userForm.value.role === 'ORGANIZER' && !userForm.value.clubId) {
    showToast('Please select a belonging club for the organizer', 'warning')
    return
  }

  if (!isEditing.value && userForm.value.password !== userForm.value.confirmPassword) {
    showToast('Passwords do not match', 'warning')
    return
  }

  if (isEditing.value && userForm.value.password && userForm.value.password !== userForm.value.confirmPassword) {
    showToast('Passwords do not match', 'warning')
    return
  }

  const payload = {
    name: userForm.value.name,
    email: userForm.value.email,
    role: userForm.value.role,
    gender: userForm.value.gender,
    tshirtSize: userForm.value.tshirtSize,
    imageUrl: userForm.value.imageUrl || defaultAvatar,
    ...(userForm.value.password ? { password: userForm.value.password } : {}),
    // Student specific
    studentId: userForm.value.studentId,
    batch: userForm.value.batch,
    // Organizer specific
    clubId: userForm.value.clubId ? parseInt(userForm.value.clubId) : null,
    clubPosition: userForm.value.clubPosition
  }

  try {
    if (isEditing.value) {
      // UPDATE USER (PUT)
      const res = await fetch(`http://localhost:8080/api/users/${editingUserId.value}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })
      if (res.ok) {
        const updated = await res.json()
        const index = usersList.value.findIndex(u => (u.id || u.userId) === editingUserId.value)
        if (index !== -1) {
          usersList.value[index] = updated
        } else {
          await fetchUsers()
        }
        showToast('User account updated successfully', 'success')
        viewMode.value = 'LIST'
      } else {
        showToast('Failed to update user account', 'error')
      }
    } else {
      // CREATE USER (POST)
      const res = await fetch('http://localhost:8080/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...payload, password: userForm.value.password || 'password123' })
      })
      if (res.ok) {
        const added = await res.json()
        usersList.value.unshift(added)
        showToast('New user account created successfully', 'success')
        viewMode.value = 'LIST'
      } else {
        const errData = await res.json().catch(() => ({}))
        showToast('Failed to create user: ' + (errData.message || 'Server error'), 'error')
      }
    }
  } catch (err) {
    showToast('Operation failed. Please check network connection', 'error')
  }
}

// Trigger Delete Confirmation Modal
const confirmDeleteUser = (user) => {
  userToDelete.value = user
  showDeleteModal.value = true
}

// Execute Deletion via API
const executeDeleteUser = async () => {
  if (!userToDelete.value) return
  const id = userToDelete.value.id || userToDelete.value.userId
  isDeleting.value = true

  try {
    const res = await fetch(`http://localhost:8080/api/users/${id}`, { method: 'DELETE' })
    if (res.ok) {
      usersList.value = usersList.value.filter(u => (u.id || u.userId) !== id)
      showToast('User account deleted successfully', 'success')
    } else {
      showToast('Failed to delete user account', 'error')
    }
  } catch (err) {
    showToast('Network error while deleting user', 'error')
  } finally {
    isDeleting.value = false
    showDeleteModal.value = false
    userToDelete.value = null
  }
}
</script>

<template>
  <div class="space-y-4 w-full relative">
    
    <!-- Floating Toast Notification System -->
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
            <h3 class="text-base font-bold text-slate-900">Delete user account?</h3>
            <p class="text-xs text-slate-500 font-medium mt-0.5">This action cannot be undone.</p>
          </div>
        </div>

        <div v-if="userToDelete" class="p-3 bg-slate-50 rounded-xl border border-slate-200 flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-white border border-slate-200 overflow-hidden shrink-0">
            <img v-if="userToDelete.imageUrl" :src="userToDelete.imageUrl" class="w-full h-full object-cover" />
            <div v-else class="w-full h-full flex items-center justify-center text-blue-700 font-bold text-xs">
              {{ userToDelete.name?.charAt(0) || 'U' }}
            </div>
          </div>
          <div class="min-w-0 flex-1">
            <h4 class="text-xs font-bold text-slate-900 truncate">{{ userToDelete.name }}</h4>
            <p class="text-[11px] font-mono text-slate-500 truncate">{{ userToDelete.email }}</p>
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
            @click="executeDeleteUser" 
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

    <!-- MODE 1: USER LIST PAGE -->
    <template v-if="viewMode === 'LIST'">
      <!-- Header Controls -->
      <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div>
          <h2 class="text-xl font-bold text-slate-900">User management</h2>
          <p class="text-xs text-slate-600 font-medium mt-0.5">Manage student, organizer, and admin accounts across CUET</p>
        </div>
        <div class="flex items-center gap-2">
          <button @click="openAddPage" class="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-3.5 py-1.5 rounded-lg transition-all shadow-xs">
            <Plus class="w-4 h-4" />
            Add user
          </button>
        </div>
      </div>

      <!-- Compact Overview Stats Cards -->
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
        <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
          <div class="min-w-0">
            <p class="text-xs font-medium text-slate-500 truncate">Total users</p>
            <h3 class="text-base sm:text-lg font-extrabold text-slate-900 leading-tight mt-0.5">{{ totalUsersCount }}</h3>
          </div>
          <div class="w-7 h-7 rounded-md bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
            <Users class="w-3.5 h-3.5" />
          </div>
        </div>

        <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
          <div class="min-w-0">
            <p class="text-xs font-medium text-slate-500 truncate">Students</p>
            <h3 class="text-base sm:text-lg font-extrabold text-blue-700 leading-tight mt-0.5">{{ totalStudentsCount }}</h3>
          </div>
          <div class="w-7 h-7 rounded-md bg-blue-100 text-blue-700 flex items-center justify-center shrink-0">
            <GraduationCap class="w-3.5 h-3.5" />
          </div>
        </div>

        <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
          <div class="min-w-0">
            <p class="text-xs font-medium text-slate-500 truncate">Organizers</p>
            <h3 class="text-base sm:text-lg font-extrabold text-amber-700 leading-tight mt-0.5">{{ totalOrganizersCount }}</h3>
          </div>
          <div class="w-7 h-7 rounded-md bg-amber-50 text-amber-600 flex items-center justify-center shrink-0">
            <Building2 class="w-3.5 h-3.5" />
          </div>
        </div>

        <div class="bg-white px-3 py-2 rounded-lg border border-slate-200 shadow-2xs flex items-center justify-between">
          <div class="min-w-0">
            <p class="text-xs font-medium text-slate-500 truncate">Admins</p>
            <h3 class="text-base sm:text-lg font-extrabold text-purple-700 leading-tight mt-0.5">{{ totalAdminsCount }}</h3>
          </div>
          <div class="w-7 h-7 rounded-md bg-purple-50 text-purple-600 flex items-center justify-center shrink-0">
            <Shield class="w-3.5 h-3.5" />
          </div>
        </div>
      </div>

      <!-- Filter & Search Controls Bar -->
      <div class="glass-panel p-3 bg-white rounded-xl border border-slate-200 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-2.5">
        <div class="relative flex-1 max-w-md">
          <Search class="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input 
            v-model="searchUserQuery" 
            type="text" 
            placeholder="Search name, email, student ID, club..." 
            class="w-full bg-white border border-slate-300 text-xs rounded-lg pl-8 pr-3 py-1.5 text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-600 shadow-2xs" 
          />
        </div>

        <div class="flex flex-wrap items-center gap-2">
          <div class="flex items-center gap-1">
            <label class="text-xs font-medium text-slate-600">Role:</label>
            <select v-model="selectedRoleFilter" class="bg-white border border-slate-300 text-xs font-semibold rounded-md px-2 py-1 text-slate-900 focus:ring-2 focus:ring-blue-600">
              <option value="ALL">All roles</option>
              <option value="STUDENT">Student</option>
              <option value="ORGANIZER">Organizer</option>
              <option value="ADMIN">Admin</option>
            </select>
          </div>

          <div class="flex items-center gap-1">
            <label class="text-xs font-medium text-slate-600">Gender:</label>
            <select v-model="selectedGenderFilter" class="bg-white border border-slate-300 text-xs font-semibold rounded-md px-2 py-1 text-slate-900 focus:ring-2 focus:ring-blue-600">
              <option value="ALL">All genders</option>
              <option value="Male">Male</option>
              <option value="Female">Female</option>
            </select>
          </div>

          <div class="flex items-center gap-1">
            <label class="text-xs font-medium text-slate-600">Per page:</label>
            <select v-model.number="itemsPerPage" class="bg-white border border-slate-300 text-xs font-semibold rounded-md px-1.5 py-1 text-slate-900 focus:ring-2 focus:ring-blue-600">
              <option :value="5">5</option>
              <option :value="10">10</option>
              <option :value="20">20</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Filter Result Counter Bar -->
      <div class="flex items-center justify-between px-1 text-xs text-slate-600 font-medium">
        <div class="flex items-center gap-2">
          <span class="inline-flex items-center gap-1 px-2.5 py-0.5 bg-blue-50 text-blue-800 border border-blue-200 rounded-full font-semibold text-xs">
            <Filter class="w-3 h-3" />
            Found {{ filteredUsers.length }} matching {{ filteredUsers.length === 1 ? 'user' : 'users' }}
          </span>
          <span class="text-slate-500 font-medium text-xs">out of {{ totalUsersCount }} total accounts</span>
        </div>
      </div>

      <!-- Users Table -->
      <div class="bg-white rounded-xl border border-slate-200 shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs sm:text-sm">
            <thead class="bg-slate-50 text-slate-700 font-bold border-b border-slate-200">
              <tr>
                <th class="py-3 px-4">User</th>
                <th class="py-3 px-4">Email / Details</th>
                <th class="py-3 px-4">Role</th>
                <th class="py-3 px-4">Gender</th>
                <th class="py-3 px-4">T-Shirt</th>
                <th class="py-3 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-for="u in paginatedUsers" :key="u.id || u.userId" class="hover:bg-slate-50 transition-colors">
                <td class="py-3 px-4 font-semibold text-slate-900 flex items-center gap-2.5">
                  <div class="w-8 h-8 rounded-full bg-slate-100 border border-slate-200 shadow-2xs overflow-hidden shrink-0 flex items-center justify-center">
                    <img v-if="u.imageUrl" :src="u.imageUrl" :alt="u.name" class="w-full h-full object-cover" />
                    <span v-else class="text-blue-700 font-bold text-xs">{{ u.name?.charAt(0) || 'U' }}</span>
                  </div>
                  <div>
                    <span class="block font-semibold text-slate-900">{{ u.name }}</span>
                    <span v-if="u.role?.toUpperCase() === 'STUDENT' && u.studentId" class="text-[11px] font-mono text-blue-600">ID: {{ u.studentId }} {{ u.batch ? '• Batch ' + u.batch : '' }}</span>
                  </div>
                </td>
                <td class="py-3 px-4 text-slate-700 font-mono text-xs">
                  <div>{{ u.email }}</div>
                  <div v-if="u.role?.toUpperCase() === 'ORGANIZER' && (u.clubName || u.clubPosition)" class="text-[11px] font-sans text-amber-700 font-semibold mt-0.5 flex items-center gap-1">
                    <Building2 class="w-3 h-3 shrink-0" />
                    {{ u.clubName || 'CUET Club' }} {{ u.clubPosition ? '• ' + u.clubPosition : '' }}
                  </div>
                </td>
                <td class="py-3 px-4">
                  <span :class="[
                    'px-2 py-0.5 rounded text-xs font-semibold inline-flex items-center gap-1',
                    u.role?.toUpperCase() === 'ADMIN' ? 'bg-purple-100 text-purple-800 border border-purple-200' :
                    u.role?.toUpperCase() === 'ORGANIZER' ? 'bg-amber-100 text-amber-800 border border-amber-200' : 'bg-blue-100 text-blue-800 border border-blue-200'
                  ]">
                    <Shield v-if="u.role?.toUpperCase() === 'ADMIN'" class="w-3 h-3" />
                    <Building2 v-else-if="u.role?.toUpperCase() === 'ORGANIZER'" class="w-3 h-3" />
                    <GraduationCap v-else class="w-3 h-3" />
                    {{ formatRole(u.role) }}
                  </span>
                </td>
                <td class="py-3 px-4 text-slate-700 font-medium">{{ u.gender || 'N/A' }}</td>
                <td class="py-3 px-4 text-slate-700 font-mono font-semibold">{{ u.tshirtSize || 'M' }}</td>
                <td class="py-3 px-4 text-right space-x-1">
                  <button @click="openEditPage(u)" class="p-1.5 text-slate-600 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors" title="Edit user">
                    <Edit3 class="w-3.5 h-3.5" />
                  </button>
                  <button @click="confirmDeleteUser(u)" class="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors" title="Delete account">
                    <Trash2 class="w-3.5 h-3.5" />
                  </button>
                </td>
              </tr>
              <tr v-if="paginatedUsers.length === 0 && !isLoading">
                <td colspan="6" class="py-6 text-center text-slate-500 font-medium">No matching user accounts found.</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination Footer Controls -->
        <div v-if="filteredUsers.length > 0" class="p-3 bg-slate-50/80 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-2.5 text-xs text-slate-700 font-medium">
          <div>
            Showing <span class="font-bold text-slate-900">{{ startIndex + 1 }}</span> to <span class="font-bold text-slate-900">{{ endIndex }}</span> of <span class="font-bold text-slate-900">{{ filteredUsers.length }}</span> users
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
    </template>

    <!-- MODE 2: FULL FORM PAGE (MATCHES AUTHVIEW SIGNUP FIELDS) -->
    <template v-else-if="viewMode === 'FORM'">
      <!-- Form Header -->
      <div class="flex items-center justify-between border-b border-slate-200 pb-3">
        <div class="flex items-center gap-3">
          <button @click="backToList" class="p-1.5 rounded-lg bg-white border border-slate-300 hover:bg-slate-100 text-slate-700 transition-colors">
            <ArrowLeft class="w-4 h-4" />
          </button>
          <div>
            <h2 class="text-lg font-bold text-slate-900">{{ isEditing ? 'Edit user profile' : 'Create new campus account' }}</h2>
            <p class="text-xs text-slate-600 font-medium mt-0.5">
              {{ isEditing ? 'Update user entity properties, club affiliation, and photo' : 'Fill out user parameters, select role & club affiliation, and upload profile picture' }}
            </p>
          </div>
        </div>
      </div>

      <!-- Main Form Card -->
      <div class="glass-panel p-5 bg-white rounded-xl border border-slate-200 shadow-xs max-w-2xl">
        <form @submit.prevent="handleSaveUser" class="space-y-5">
          
          <!-- Server Disk File Upload Dropzone -->
          <div class="flex flex-col sm:flex-row items-center gap-4 p-3 bg-slate-50 rounded-lg border border-slate-200">
            <div class="w-16 h-16 rounded-full border-2 border-blue-600 shadow-xs overflow-hidden shrink-0 bg-white flex items-center justify-center relative">
              <img v-if="previewImage || userForm.imageUrl" :src="previewImage || userForm.imageUrl" class="w-full h-full object-cover" />
              <UserIcon v-else class="w-8 h-8 text-slate-400" />
              
              <div v-if="isUploadingImage" class="absolute inset-0 bg-slate-900/60 flex items-center justify-center text-white">
                <Loader2 class="w-5 h-5 animate-spin" />
              </div>
            </div>

            <div class="space-y-1 text-center sm:text-left flex-1">
              <label class="block text-xs font-semibold text-slate-900">Upload profile image file</label>
              <p class="text-xs text-slate-500 font-medium">Saves file under <code class="bg-slate-200 px-1 py-0.5 rounded text-slate-800">file/eventx/user/</code></p>
              
              <div class="flex flex-wrap items-center gap-2 justify-center sm:justify-start pt-0.5">
                <button type="button" @click="triggerFileInput" class="inline-flex items-center gap-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold px-3 py-1.5 rounded-md transition-all shadow-xs">
                  <Upload class="w-3.5 h-3.5" />
                  {{ isUploadingImage ? 'Uploading...' : 'Choose image file' }}
                </button>
                <input ref="fileInputRef" type="file" accept="image/*" @change="handleImageFileUpload" :disabled="isUploadingImage" class="hidden" />
              </div>
            </div>
          </div>

          <!-- Section 1: Core Identification -->
          <div class="space-y-3 border-b border-slate-100 pb-3">
            <h3 class="text-xs font-semibold text-slate-900 flex items-center gap-1.5">
              <UserIcon class="w-3.5 h-3.5 text-blue-600" /> Account identity
            </h3>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="text-xs font-semibold text-slate-800">Full name *</label>
                <input 
                  v-model="userForm.name" 
                  type="text" 
                  required 
                  class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-medium" 
                  placeholder="e.g. Sharika Hossain" 
                />
              </div>

              <div>
                <label class="text-xs font-semibold text-slate-800">Email address *</label>
                <input 
                  v-model="userForm.email" 
                  type="email" 
                  required 
                  class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-mono" 
                  placeholder="student@cuet.ac.bd" 
                />
              </div>
            </div>
          </div>

          <!-- Section 2: Role & System Parameters -->
          <div class="space-y-3 border-b border-slate-100 pb-3">
            <h3 class="text-xs font-semibold text-slate-900 flex items-center gap-1.5">
              <Shield class="w-3.5 h-3.5 text-purple-600" /> Role & account parameters
            </h3>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div>
                <label class="text-xs font-semibold text-slate-800">System role *</label>
                <select v-model="userForm.role" class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-semibold">
                  <option value="STUDENT">Student</option>
                  <option value="ORGANIZER">Organizer</option>
                  <option value="ADMIN">Admin</option>
                </select>
              </div>

              <div>
                <label class="text-xs font-semibold text-slate-800">Gender</label>
                <select v-model="userForm.gender" class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-semibold">
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div>
                <label class="text-xs font-semibold text-slate-800">T-Shirt size</label>
                <select v-model="userForm.tshirtSize" class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-mono font-semibold">
                  <option value="S">Small (S)</option>
                  <option value="M">Medium (M)</option>
                  <option value="L">Large (L)</option>
                  <option value="XL">Extra Large (XL)</option>
                  <option value="XXL">Double XL (XXL)</option>
                </select>
              </div>
            </div>

            <!-- Student Specific Fields (Student ID & Batch) -->
            <div v-if="userForm.role === 'STUDENT'" class="p-3 bg-blue-50/60 rounded-lg border border-blue-100 space-y-2">
              <h4 class="text-xs font-bold text-blue-900 flex items-center gap-1">
                <GraduationCap class="w-3.5 h-3.5 text-blue-600" /> Student academic details
              </h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="text-xs font-semibold text-slate-800">Student ID *</label>
                  <input 
                    v-model="userForm.studentId" 
                    type="text" 
                    :required="userForm.role === 'STUDENT'"
                    class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-mono" 
                    placeholder="e.g. 2304086" 
                  />
                </div>
                <div>
                  <label class="text-xs font-semibold text-slate-800">Batch *</label>
                  <input 
                    v-model="userForm.batch" 
                    type="text" 
                    :required="userForm.role === 'STUDENT'"
                    class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600" 
                    placeholder="e.g. '23" 
                  />
                </div>
              </div>
            </div>

            <!-- Organizer Specific Fields (Belonging Club & Club Position) -->
            <div v-if="userForm.role === 'ORGANIZER'" class="p-3 bg-amber-50/60 rounded-lg border border-amber-200 space-y-2">
              <h4 class="text-xs font-bold text-amber-900 flex items-center gap-1">
                <Building2 class="w-3.5 h-3.5 text-amber-600" /> Organizer club affiliation
              </h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="text-xs font-semibold text-slate-800">Belonging club *</label>
                  <select 
                    v-model="userForm.clubId" 
                    :required="userForm.role === 'ORGANIZER'"
                    class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-semibold"
                  >
                    <option value="" disabled>Select belonging club</option>
                    <option v-for="c in clubsList" :key="c.id || c.clubId" :value="c.id || c.clubId">
                      {{ c.name }}
                    </option>
                  </select>
                </div>
                <div>
                  <label class="text-xs font-semibold text-slate-800">Club position *</label>
                  <input 
                    v-model="userForm.clubPosition" 
                    type="text" 
                    :required="userForm.role === 'ORGANIZER'"
                    class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600" 
                    placeholder="e.g. President, General Secretary, Executive Member" 
                  />
                </div>
              </div>
            </div>

          </div>

          <!-- Section 3: Profile Image URL Field -->
          <div class="space-y-3 border-b border-slate-100 pb-3">
            <h3 class="text-xs font-semibold text-slate-900 flex items-center gap-1.5">
              <Image class="w-3.5 h-3.5 text-emerald-600" /> Image URL stored in database
            </h3>
            <div>
              <label class="text-xs font-semibold text-slate-800">Saved image URL</label>
              <input 
                v-model="userForm.imageUrl" 
                type="text" 
                class="w-full bg-slate-50 border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-mono" 
                placeholder="http://localhost:8080/uploads/user/..." 
              />
            </div>
          </div>

          <!-- Section 4: Security Password -->
          <div class="space-y-3">
            <h3 class="text-xs font-semibold text-slate-900 flex items-center gap-1.5">
              <Lock class="w-3.5 h-3.5 text-amber-600" /> Security authentication
            </h3>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="text-xs font-semibold text-slate-800">Password {{ isEditing ? '(Optional)' : '*' }}</label>
                <input 
                  v-model="userForm.password" 
                  type="password" 
                  :required="!isEditing"
                  class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-medium" 
                  placeholder="••••••••" 
                />
              </div>

              <div>
                <label class="text-xs font-semibold text-slate-800">Confirm password {{ isEditing ? '' : '*' }}</label>
                <input 
                  v-model="userForm.confirmPassword" 
                  type="password" 
                  :required="!isEditing && !!userForm.password"
                  class="w-full bg-white border border-slate-300 text-xs rounded-lg px-3 py-2 text-slate-900 mt-1 focus:ring-2 focus:ring-blue-600 font-medium" 
                  placeholder="••••••••" 
                />
              </div>
            </div>
          </div>

          <!-- Form Action Buttons -->
          <div class="flex items-center justify-end gap-2.5 pt-4 border-t border-slate-200">
            <button type="button" @click="backToList" class="px-4 py-2 rounded-md border border-slate-300 text-slate-700 hover:bg-slate-100 font-semibold text-xs">
              Cancel
            </button>
            <button type="submit" class="flex items-center gap-1.5 px-5 py-2 rounded-md bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs shadow-xs transition-all">
              <Save class="w-3.5 h-3.5" />
              {{ isEditing ? 'Update user' : 'Save user' }}
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
