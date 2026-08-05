<script setup>
import { ref, onMounted } from 'vue'
import confetti from 'canvas-confetti'
import { X, CheckCircle2, UserCheck, ArrowRight, Sparkles, Loader2 } from 'lucide-vue-next'
import { apiService } from '../services/api'

const props = defineProps({
  event: Object
})

const emit = defineEmits(['close', 'submitted'])

const isSubmitting = ref(false)
const isSubmitted = ref(false)
const isLoadingDepartments = ref(true)

const departmentsList = ref([])

const form = ref({
  userId: null,
  name: '',
  studentId: '',
  email: '',
  department: '',
  phone: '',
  tshirtSize: 'M',
  role: 'Venue & Check-in Management',
  notes: ''
})

const rolesList = [
  'Venue & Check-in Management',
  'Technical Support & AV Systems',
  'Registration Desk Coordinator',
  'Guest & Speaker Hospitality',
  'Media & Photography Team'
]

onMounted(async () => {
  try {
    const depts = await apiService.getDepartments()
    if (Array.isArray(depts) && depts.length > 0) {
      departmentsList.value = depts
      if (depts[0]?.code) {
        form.value.department = depts[0].code
      }
    }
  } catch (err) {
    console.error('Failed to load departments:', err)
  } finally {
    isLoadingDepartments.value = false
  }

  // Load currently logged-in user details if available in local storage session
  try {
    const storedUserStr = localStorage.getItem('user') || localStorage.getItem('eventx_user') || localStorage.getItem('currentUser')
    if (storedUserStr) {
      const u = JSON.parse(storedUserStr)
      if (u) {
        form.value.userId = u.user_id || u.id || 1
        form.value.name = u.name || ''

        let sid = u.studentId || u.student_id || u.studentID || u.student_Id || ''
        if (!sid && u.email) {
          const match = u.email.match(/\d{7}/) || u.email.match(/\d{6}/) || u.email.match(/\d+/)
          if (match) sid = match[0]
        }
        if (!sid) sid = '1804001'

        form.value.studentId = sid
        form.value.email = u.email || ''
        form.value.department = u.department || u.deptCode || form.value.department
        form.value.tshirtSize = u.tshirtSize || u.tshirt_size || 'M'
      }
    } else {
      form.value.studentId = '1804001'
    }
  } catch (e) {
    form.value.studentId = '1804001'
  }
})

const handleSubmit = async () => {
  if (!form.value.name.trim() || !form.value.studentId.trim()) return

  isSubmitting.value = true
  try {
    const payload = {
      userId: form.value.userId || 1,
      name: form.value.name,
      studentId: form.value.studentId,
      email: form.value.email,
      department: form.value.department,
      phone: form.value.phone,
      tshirtSize: form.value.tshirtSize,
      role: form.value.role,
      notes: form.value.notes,
      eventId: props.event?.id || props.event?.event_id,
      eventName: props.event?.name
    }

    await apiService.registerVolunteer(payload.eventId, payload)

    confetti({
      particleCount: 100,
      spread: 70,
      origin: { y: 0.6 }
    })

    isSubmitted.value = true
    emit('submitted', payload)
  } catch (err) {
    console.error('Volunteer application error:', err)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <div
    class="fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 sm:p-6">
    <div
      class="glass-panel border-slate-200 w-full max-w-lg rounded-3xl shadow-2xl overflow-hidden bg-white text-slate-900">

      <!-- Modal Header -->
      <div class="p-6 border-b border-slate-200 flex items-center justify-between bg-slate-50">
        <div class="flex items-center gap-3">
          <div class="p-2.5 rounded-2xl bg-indigo-100 border border-indigo-200 text-indigo-700">
            <UserCheck class="w-6 h-6" />
          </div>
          <div>
            <h3 class="font-black text-lg text-slate-900">Volunteer Application</h3>
            <p class="text-xs text-slate-500 font-medium line-clamp-1">{{ event?.name }}</p>
          </div>
        </div>

        <button @click="emit('close')"
          class="p-2 rounded-full hover:bg-slate-200 text-slate-500 hover:text-slate-900 transition-colors">
          <X class="w-5 h-5" />
        </button>
      </div>

      <!-- Form Body / Success Screen -->
      <div v-if="!isSubmitted" class="p-6 space-y-4 max-h-[70vh] overflow-y-auto">

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Full Name *</label>
            <input v-model="form.name" type="text" placeholder="e.g. Alice Mahmud"
              class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold" />
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Student ID *</label>
            <input v-model="form.studentId" type="text" placeholder="e.g. 1804001"
              class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono font-bold" />
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">CUET Email</label>
            <input v-model="form.email" type="email" placeholder="student@cuet.ac.bd"
              class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs" />
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Department</label>
            <select v-model="form.department"
              class="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold">
              <option v-for="d in departmentsList" :key="d.department_id || d.id || d.code" :value="d.code">
                {{ d.name }} ({{ d.code }})
              </option>
            </select>
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Preferred Crew Role</label>
            <select v-model="form.role"
              class="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800">
              <option v-for="r in rolesList" :key="r" :value="r">{{ r }}</option>
            </select>
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">T-Shirt Size</label>
            <select v-model="form.tshirtSize"
              class="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold">
              <option value="S">Small (S)</option>
              <option value="M">Medium (M)</option>
              <option value="L">Large (L)</option>
              <option value="XL">Extra Large (XL)</option>
              <option value="XXL">Double XL (XXL)</option>
            </select>
          </div>
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">Previous Experience / Notes</label>
          <textarea v-model="form.notes" rows="2" placeholder="Mention any past event management experience..."
            class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs"></textarea>
        </div>
      </div>

      <!-- Success Screen -->
      <div v-else class="p-8 text-center space-y-5">
        <div
          class="w-16 h-16 rounded-full bg-emerald-100 border border-emerald-300 text-emerald-600 flex items-center justify-center mx-auto shadow-lg">
          <CheckCircle2 class="w-10 h-10" />
        </div>
        <div class="space-y-1">
          <h3 class="text-xl font-black text-slate-900">Volunteer Application Submitted!</h3>
          <p class="text-xs text-slate-600">
            Thank you <span class="font-bold text-slate-900">{{ form.name }}</span>! Organizer committee will review
            your application for <span class="font-bold text-indigo-700">{{ event?.name }}</span>.
          </p>
        </div>
      </div>

      <!-- Modal Footer -->
      <div v-if="!isSubmitted" class="p-4 border-t border-slate-200 bg-slate-50 flex items-center justify-between">
        <button @click="emit('close')"
          class="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold">
          Cancel
        </button>
        <button @click="handleSubmit" :disabled="isSubmitting"
          class="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-extrabold shadow-md shadow-indigo-600/30 flex items-center gap-2">
          <Loader2 v-if="isSubmitting" class="w-4 h-4 animate-spin" />
          <span>{{ isSubmitting ? 'Submitting...' : 'Submit Application' }}</span>
          <ArrowRight v-if="!isSubmitting" class="w-4 h-4" />
        </button>
      </div>

      <div v-else class="p-4 border-t border-slate-200 bg-slate-50 text-center">
        <button @click="emit('close')"
          class="px-8 py-2.5 bg-slate-900 hover:bg-slate-800 text-white rounded-xl text-xs font-extrabold shadow-md">
          Close Window
        </button>
      </div>

    </div>
  </div>
</template>
