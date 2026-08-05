<script setup>
import { ref, watch, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ArrowRight, Lock, Mail, User, Shield, CheckCircle2, GraduationCap, Building2, UploadCloud, Image, Upload, Loader2 } from 'lucide-vue-next'
import Navbar from '../components/Navbar.vue'

const router = useRouter()
const route = useRoute()
const activeTab = ref(route.query.tab || 'login') // 'login', 'signup', 'forgot', 'reset'

// Watch for route changes to update tab dynamically
watch(() => route.query.tab, (newTab) => {
  if (newTab) activeTab.value = newTab
})

const email = ref('')
const password = ref('')
const name = ref('')
const role = ref('STUDENT')
const gender = ref('Male')
const tshirtSize = ref('M')
const confirmPassword = ref('')
const resetToken = ref('')
const imageUrl = ref('')
const isUploadingPhoto = ref(false)

// Student specific fields (users + students table)
const studentId = ref('')
const batch = ref('')

// Shared & Organizer specific fields (users + organizers table)
const clubId = ref('')
const departmentId = ref('')
const clubPosition = ref('')
const documentFiles = ref([])

const clubs = ref([])
const departments = ref([])
const errorMessage = ref('')
const successMessage = ref('')
const isLoading = ref(false)

const roles = [
  { id: 'STUDENT', label: 'Student', icon: GraduationCap },
  { id: 'ORGANIZER', label: 'Organizer', icon: Building2 },
  { id: 'ADMIN', label: 'Admin', icon: Shield }
]

onMounted(async () => {
  try {
    const res = await fetch('http://localhost:8080/api/auth/clubs')
    if (res.ok) {
      const data = await res.json()
      if (Array.isArray(data) && data.length > 0) clubs.value = data
    }
  } catch (error) {
    console.info("Using local fallback data for clubs")
  }

  try {
    const resDept = await fetch('http://localhost:8080/api/auth/departments')
    if (resDept.ok) {
      const data = await resDept.json()
      if (Array.isArray(data) && data.length > 0) departments.value = data
    }
  } catch (error) {
    console.info("Using local fallback data for departments")
  }
})

// Upload Profile Photo to Server Disk (eventx/uploads/user_images/)
const handleProfilePhotoUpload = async (e) => {
  const file = e.target.files[0]
  if (!file) return

  if (file.size > 10 * 1024 * 1024) {
    alert('Photo must be less than 10MB')
    return
  }

  isUploadingPhoto.value = true
  const formData = new FormData()
  formData.append('file', file)

  try {
    const res = await fetch('http://localhost:8080/api/upload/user-image', {
      method: 'POST',
      body: formData
    })

    if (res.ok) {
      const data = await res.json()
      imageUrl.value = data.imageUrl
    } else {
      alert('Failed to upload image file.')
    }
  } catch (err) {
    alert('Upload error. Please check backend connection.')
  } finally {
    isUploadingPhoto.value = false
  }
}

const handleFileChange = (e) => {
  if (e.target.files.length > 0) {
    for (let i = 0; i < e.target.files.length; i++) {
      const file = e.target.files[i]
      documentFiles.value.push({
        file,
        previewUrl: URL.createObjectURL(file),
        name: file.name
      })
    }
    e.target.value = ''
  }
}

const removeFile = (index) => {
  URL.revokeObjectURL(documentFiles.value[index].previewUrl)
  documentFiles.value.splice(index, 1)
}

const handleSubmit = async (e) => {
  e.preventDefault()
  errorMessage.value = ''
  successMessage.value = ''
  isLoading.value = true

  try {
    let endpoint = ''
    let bodyData = null
    let headers = {}

    if (activeTab.value === 'login') {
      endpoint = 'http://localhost:8080/api/auth/login'
      bodyData = JSON.stringify({ email: email.value, password: password.value, role: role.value })
      headers['Content-Type'] = 'application/json'
    } else if (activeTab.value === 'signup') {
      if (password.value !== confirmPassword.value) {
        throw new Error('Passwords do not match.')
      }

      endpoint = 'http://localhost:8080/api/auth/signup'
      bodyData = JSON.stringify({
        email: email.value,
        password: password.value,
        name: name.value,
        role: role.value,
        gender: gender.value,
        tshirtSize: tshirtSize.value,
        imageUrl: imageUrl.value || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=250&q=80',
        studentId: studentId.value,
        batch: batch.value,
        clubId: clubId.value ? parseInt(clubId.value) : null,
        departmentId: departmentId.value ? parseInt(departmentId.value) : null,
        clubPosition: clubPosition.value,
        documentUrls: documentFiles.value.map(f => f.name)
      })
      headers['Content-Type'] = 'application/json'
    } else if (activeTab.value === 'forgot') {
      endpoint = 'http://localhost:8080/api/auth/forgot-password'
      bodyData = JSON.stringify({ email: email.value })
      headers['Content-Type'] = 'application/json'
    } else if (activeTab.value === 'reset') {
      endpoint = 'http://localhost:8080/api/auth/reset-password'
      bodyData = JSON.stringify({ resetToken: resetToken.value, newPassword: password.value })
      headers['Content-Type'] = 'application/json'
    }

    const response = await fetch(endpoint, {
      method: 'POST',
      headers: headers,
      body: bodyData
    })

    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.message || 'Authentication operation failed.')
    }

    if (activeTab.value === 'login') {
      localStorage.setItem('user', JSON.stringify(data.user || {
        email: email.value,
        role: role.value,
        name: name.value || email.value.split('@')[0]
      }))
      router.push('/dashboard')
    } else if (activeTab.value === 'signup') {
      successMessage.value = 'Account created successfully! Redirecting to login...'
      setTimeout(() => {
        activeTab.value = 'login'
        successMessage.value = ''
      }, 1500)
    } else if (activeTab.value === 'forgot') {
      successMessage.value = 'Reset link sent! Please check your email inbox.'
    } else if (activeTab.value === 'reset') {
      successMessage.value = 'Password reset successfully! Please sign in.'
      setTimeout(() => {
        activeTab.value = 'login'
        successMessage.value = ''
      }, 1500)
    }
  } catch (err) {
    errorMessage.value = err.message || 'Server connection error. Please try again.'
  } finally {
    isLoading.value = false
  }
}

const fillDemoAccount = (targetRole) => {
  role.value = targetRole
  if (targetRole === 'STUDENT') {
    email.value = 'alice@cuet.ac.bd'
    password.value = 'pass123'
  } else if (targetRole === 'ORGANIZER') {
    email.value = 'tasriful@cuet.ac.bd'
    password.value = 'pass123'
  } else if (targetRole === 'ADMIN') {
    email.value = 'admin@cuet.ac.bd'
    password.value = 'admin123'
  }
}
</script>

<template>
  <div class="min-h-screen bg-slate-50 flex flex-col pt-14 font-sans">
    <Navbar currentView="auth" @navigate="router.push('/' + ($event === 'events' ? '' : $event))" />

    <div class="flex-1 flex items-center justify-center p-2 sm:p-4">

      <!-- Ultra-Compact Card -->
      <div class="glass-panel border-slate-200/80 bg-white w-full max-w-md p-4 sm:p-5 rounded-xl shadow-md space-y-3">

        <!-- Header -->
        <div class="text-center space-y-1 flex flex-col items-center justify-center">
          <div class="w-12 h-12 rounded-xl bg-slate-900 border border-slate-700/60 p-1 shadow-md mb-1 flex items-center justify-center">
            <img src="/logo.png" alt="EventX Logo" class="w-full h-full object-contain" />
          </div>
          <h2 class="text-lg sm:text-xl font-bold tracking-tight text-slate-900">
            {{ activeTab === 'login' ? 'Welcome back' : activeTab === 'signup' ? 'Create an account' : activeTab === 'forgot' ? 'Reset password' : 'New password' }}
          </h2>
          <p class="text-xs text-slate-500">
            {{ activeTab === 'login' ? 'Select role & enter credentials.' : activeTab === 'signup' ? 'Select role & fill registration parameters.' : 'Enter registered email address.' }}
          </p>
        </div>

        <!-- Quick Fill Demo Accounts -->
        <div v-if="activeTab === 'login'" class="p-2 bg-slate-50 rounded-lg border border-slate-200 space-y-1.5">
          <div class="flex items-center justify-between text-[11px] font-bold text-slate-700">
            <span>Quick Demo Logins</span>
            <span class="text-[10px] font-mono text-slate-400 font-normal">Database Users</span>
          </div>
          <div class="grid grid-cols-3 gap-1.5">
            <button type="button" @click="fillDemoAccount('STUDENT')"
              class="p-1.5 bg-white hover:bg-blue-50 border border-slate-200 hover:border-blue-300 rounded-md text-left transition-all group">
              <div class="flex items-center gap-1">
                <GraduationCap class="w-3 h-3 text-blue-600 shrink-0" />
                <span class="text-[11px] font-bold text-slate-800 group-hover:text-blue-600">Student</span>
              </div>
              <p class="text-[9px] text-slate-500 font-mono truncate mt-0.5">alice@cuet.ac.bd</p>
            </button>

            <button type="button" @click="fillDemoAccount('ORGANIZER')"
              class="p-1.5 bg-white hover:bg-amber-50 border border-slate-200 hover:border-amber-300 rounded-md text-left transition-all group">
              <div class="flex items-center gap-1">
                <Building2 class="w-3 h-3 text-amber-600 shrink-0" />
                <span class="text-[11px] font-bold text-slate-800 group-hover:text-amber-600">Organizer</span>
              </div>
              <p class="text-[9px] text-slate-500 font-mono truncate mt-0.5">tasriful@cuet.ac.bd</p>
            </button>

            <button type="button" @click="fillDemoAccount('ADMIN')"
              class="p-1.5 bg-white hover:bg-purple-50 border border-slate-200 hover:border-purple-300 rounded-md text-left transition-all group">
              <div class="flex items-center gap-1">
                <Shield class="w-3 h-3 text-purple-600 shrink-0" />
                <span class="text-[11px] font-bold text-slate-800 group-hover:text-purple-600">Admin</span>
              </div>
              <p class="text-[9px] text-slate-500 font-mono truncate mt-0.5">admin@cuet.ac.bd</p>
            </button>
          </div>
        </div>

        <!-- Alert Banners -->
        <div v-if="errorMessage" class="p-2 rounded-lg bg-red-50 border border-red-200 flex items-center gap-2">
          <div class="w-1 h-full bg-red-500 rounded-full"></div>
          <p class="text-xs text-red-600 font-medium leading-tight">{{ errorMessage }}</p>
        </div>
        <div v-if="successMessage"
          class="p-2 rounded-lg bg-emerald-50 border border-emerald-200 flex items-center gap-2">
          <CheckCircle2 class="w-3.5 h-3.5 text-emerald-600 shrink-0" />
          <p class="text-xs text-emerald-700 font-medium leading-tight">{{ successMessage }}</p>
        </div>

        <!-- Auth Form -->
        <form @submit="handleSubmit" class="space-y-3">

          <!-- Role Selector -->
          <div v-if="activeTab === 'login' || activeTab === 'signup'" class="space-y-1">
            <label class="text-xs font-semibold text-slate-700 block">Select role</label>
            <div class="grid grid-cols-3 gap-1.5">
              <button v-for="r in roles" :key="r.id" type="button" @click="role = r.id" :class="[
                'flex items-center justify-center gap-1 py-1.5 px-2 rounded-lg border text-center transition-all',
                role === r.id ? 'border-blue-600 bg-blue-50/80 text-blue-700 font-semibold shadow-xs ring-1 ring-blue-600' : 'border-slate-200 bg-slate-50 text-slate-600 hover:border-slate-300'
              ]">
                <component :is="r.icon"
                  :class="['w-3.5 h-3.5 shrink-0', role === r.id ? 'text-blue-600' : 'text-slate-400']" />
                <span class="text-xs font-medium">{{ r.label }}</span>
              </button>
            </div>
          </div>

          <!-- SIGN UP EXTRA FIELDS (Photo Upload, Name, Gender, T-Shirt) -->
          <template v-if="activeTab === 'signup'">

            <!-- Profile Photo Server Disk Upload -->
            <div class="flex items-center gap-3 p-2.5 bg-slate-50 rounded-lg border border-slate-200">
              <div
                class="w-10 h-10 rounded-full border border-blue-600 overflow-hidden shrink-0 bg-white flex items-center justify-center relative">
                <img v-if="imageUrl" :src="imageUrl" class="w-full h-full object-cover" />
                <User v-else class="w-5 h-5 text-slate-400" />
                <Loader2 v-if="isUploadingPhoto" class="w-4 h-4 text-blue-600 animate-spin absolute" />
              </div>
              <div class="flex-1">
                <label class="block text-xs font-bold text-slate-800">Profile photo</label>
                <label
                  class="cursor-pointer text-xs font-bold text-blue-600 hover:underline inline-flex items-center gap-1 mt-0.5">
                  <Upload class="w-3 h-3" /> {{ isUploadingPhoto ? 'Uploading to disk...' : 'Upload picture' }}
                  <input type="file" accept="image/*" @change="handleProfilePhotoUpload" :disabled="isUploadingPhoto"
                    class="hidden" />
                </label>
              </div>
            </div>

            <div class="space-y-0.5">
              <label class="text-xs font-semibold text-slate-700">Full name *</label>
              <div class="relative flex items-center">
                <User class="w-3.5 h-3.5 text-slate-400 absolute left-2.5 pointer-events-none z-10" />
                <input v-model="name" type="text" required class="glass-input w-full text-xs !pl-8 py-1.5"
                  placeholder="Sharika Hossain" />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-2">
              <div class="space-y-0.5">
                <label class="text-xs font-semibold text-slate-700">Gender</label>
                <select v-model="gender" class="glass-input w-full text-xs bg-white py-1.5">
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div class="space-y-0.5">
                <label class="text-xs font-semibold text-slate-700">T-shirt size</label>
                <select v-model="tshirtSize" class="glass-input w-full text-xs bg-white py-1.5">
                  <option value="S">Small (S)</option>
                  <option value="M">Medium (M)</option>
                  <option value="L">Large (L)</option>
                  <option value="XL">Extra Large (XL)</option>
                  <option value="XXL">Double XL (XXL)</option>
                </select>
              </div>
            </div>

            <!-- Student Specific Fields -->
            <div v-if="role === 'STUDENT'" class="grid grid-cols-2 gap-2">
              <div class="space-y-0.5">
                <label class="text-xs font-semibold text-slate-700">Student ID *</label>
                <input v-model="studentId" type="text" required class="glass-input w-full text-xs font-mono py-1.5"
                  placeholder="2304086" />
              </div>
              <div class="space-y-0.5">
                <label class="text-xs font-semibold text-slate-700">Batch *</label>
                <input v-model="batch" type="text" required class="glass-input w-full text-xs py-1.5"
                  placeholder="'23" />
              </div>
            </div>

            <!-- Organizer Specific Fields -->
            <template v-if="role === 'ORGANIZER'">
              <div class="grid grid-cols-2 gap-2">
                <div class="space-y-0.5">
                  <label class="text-xs font-semibold text-slate-700">Club *</label>
                  <select v-model="clubId" required class="glass-input w-full text-xs bg-white py-1.5">
                    <option value="" disabled>Select club</option>
                    <option v-for="c in clubs" :key="c.id || c.clubId" :value="c.id || c.clubId">{{ c.name }}</option>
                  </select>
                </div>
                <div class="space-y-0.5">
                  <label class="text-xs font-semibold text-slate-700">Position *</label>
                  <input v-model="clubPosition" type="text" required class="glass-input w-full text-xs py-1.5"
                    placeholder="President" />
                </div>
              </div>
            </template>
          </template>

          <!-- Email Input -->
          <div v-if="activeTab !== 'reset'" class="space-y-0.5">
            <label class="text-xs font-semibold text-slate-700">Email address *</label>
            <div class="relative flex items-center">
              <Mail class="w-3.5 h-3.5 text-slate-400 absolute left-2.5 pointer-events-none z-10" />
              <input v-model="email" type="email" required class="glass-input w-full text-xs !pl-8 py-1.5"
                placeholder="user@cuet.ac.bd" />
            </div>
          </div>

          <!-- Password Input -->
          <div v-if="activeTab === 'login' || activeTab === 'signup' || activeTab === 'reset'" class="space-y-0.5">
            <label class="text-xs font-semibold text-slate-700">
              {{ activeTab === 'reset' ? 'New password *' : 'Password *' }}
            </label>
            <div class="relative flex items-center">
              <Lock class="w-3.5 h-3.5 text-slate-400 absolute left-2.5 pointer-events-none z-10" />
              <input v-model="password" type="password" required class="glass-input w-full text-xs !pl-8 py-1.5"
                placeholder="••••••••" />
            </div>
          </div>

          <!-- Confirm Password Input -->
          <div v-if="activeTab === 'signup'" class="space-y-0.5">
            <label class="text-xs font-semibold text-slate-700">Confirm password *</label>
            <div class="relative flex items-center">
              <Lock class="w-3.5 h-3.5 text-slate-400 absolute left-2.5 pointer-events-none z-10" />
              <input v-model="confirmPassword" type="password" required class="glass-input w-full text-xs !pl-8 py-1.5"
                placeholder="••••••••" />
            </div>
          </div>

          <!-- Submit Button -->
          <button type="submit" :disabled="isLoading || isUploadingPhoto"
            class="glass-button w-full flex items-center justify-center gap-1.5 py-2 text-xs font-semibold shadow-xs mt-2">
            <span>{{ isLoading ? 'Processing...' : activeTab === 'login' ? 'Sign in' : activeTab === 'signup' ? 'Create account' : 'Submit' }}</span>
            <ArrowRight v-if="!isLoading" class="w-3.5 h-3.5" />
          </button>

        </form>

        <!-- Footer Tab Toggle Links -->
        <div
          class="pt-2 border-t border-slate-100 flex items-center justify-between text-xs font-medium text-slate-600">
          <button v-if="activeTab === 'login'" @click="activeTab = 'signup'" class="hover:text-blue-600 underline">
            Don't have an account? Sign up
          </button>
          <button v-if="activeTab === 'signup'" @click="activeTab = 'login'" class="hover:text-blue-600 underline">
            Already have an account? Sign in
          </button>
          <button v-if="activeTab === 'login'" @click="activeTab = 'forgot'"
            class="text-slate-500 hover:text-slate-900">
            Forgot password?
          </button>
        </div>

      </div>
    </div>
  </div>
</template>
