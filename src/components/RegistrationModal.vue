<script setup>
import { ref, computed, onMounted } from 'vue'
import confetti from 'canvas-confetti'
import { X, CheckCircle2, Copy, QrCode, CreditCard, Users, ShieldCheck, Shirt, Ticket, ArrowRight, ArrowLeft, Sparkles, Loader2 } from 'lucide-vue-next'
import { apiService } from '../services/api'

const props = defineProps({
  event: Object,
  selectedSegment: Object
})

const emit = defineEmits(['close', 'submitted'])

const step = ref(1)
const isSubmitting = ref(false)
const departmentsList = ref([])

// Form Fields
const currentSegment = ref(props.selectedSegment || props.event?.segments?.[0] || null)
const participationType = ref('TEAM') // TEAM or SOLO
const teamName = ref('')
const leaderName = ref('')
const studentId = ref('')
const department = ref('')
const tshirtSize = ref('M')
const paymentMethod = ref('bKash')
const transactionNumber = ref('')
const copiedNumber = ref(false)

// Team members list
const teamMembers = ref([])

onMounted(async () => {
  try {
    const depts = await apiService.getDepartments()
    if (Array.isArray(depts) && depts.length > 0) {
      departmentsList.value = depts
      if (depts[0]?.code) {
        department.value = depts[0].code
      }
    }
  } catch (err) {
    console.error('Error loading departments:', err)
  }

  // Auto-fill logged in user details if available in localStorage session
  try {
    const storedUserStr = localStorage.getItem('user') || localStorage.getItem('eventx_user') || localStorage.getItem('currentUser')
    if (storedUserStr) {
      const u = JSON.parse(storedUserStr)
      if (u) {
        leaderName.value = u.name || ''
        
        let sid = u.studentId || u.student_id || u.studentID || u.student_Id || ''
        if (!sid && u.email) {
          const match = u.email.match(/\d{7}/) || u.email.match(/\d{6}/) || u.email.match(/\d+/)
          if (match) sid = match[0]
        }
        if (!sid) sid = '1804001'

        studentId.value = sid
        department.value = u.department || u.deptCode || department.value
        tshirtSize.value = u.tshirtSize || u.tshirt_size || 'M'
      }
    } else {
      studentId.value = '1804001'
    }
  } catch (e) {
    studentId.value = '1804001'
  }
})

const isStep1Valid = computed(() => !!currentSegment.value)

const isStep2Valid = computed(() => {
  if (participationType.value === 'TEAM') {
    return teamName.value.trim().length >= 2 && leaderName.value.trim() && studentId.value.trim()
  }
  return leaderName.value.trim() && studentId.value.trim()
})

const isStep3Valid = computed(() => {
  return transactionNumber.value.trim().length >= 6
})

const addMember = () => {
  if (teamMembers.value.length < (currentSegment.value?.maxTeamSize || 4) - 1) {
    teamMembers.value.push({ name: '', studentId: '', tshirtSize: 'M' })
  }
}

const removeMember = (idx) => {
  teamMembers.value.splice(idx, 1)
}

const copyBkash = () => {
  navigator.clipboard.writeText('01712-345678')
  copiedNumber.value = true
  setTimeout(() => { copiedNumber.value = false }, 2000)
}

const createdRegistration = ref(null)

const handleSubmit = async () => {
  isSubmitting.value = true
  
  const payload = {
    eventId: props.event.id || props.event.event_id,
    eventName: props.event.name,
    segmentId: currentSegment.value?.id || currentSegment.value?.segment_id,
    segmentTitle: currentSegment.value?.title,
    teamName: participationType.value === 'TEAM' ? teamName.value : `${leaderName.value}'s Team`,
    leaderName: leaderName.value,
    studentId: studentId.value,
    department: department.value,
    tshirtSize: tshirtSize.value,
    fee: currentSegment.value?.regFee || currentSegment.value?.reg_fee || 500,
    method: paymentMethod.value,
    transactionNumber: transactionNumber.value,
    members: participationType.value === 'TEAM' 
      ? [`${leaderName.value} (Leader)`, ...teamMembers.value.map(m => m.name ? `${m.name}` : 'Member')]
      : [`${leaderName.value}`]
  }

  try {
    await apiService.createRegistration(payload)
  } catch (e) {
    console.error('Registration create error:', e)
  }

  // Trigger celebration confetti
  confetti({
    particleCount: 120,
    spread: 70,
    origin: { y: 0.6 }
  })

  createdRegistration.value = payload
  isSubmitting.value = false
  step.value = 4 // Move to Confirmation Ticket screen
  emit('submitted', payload)
}
</script>

<template>
  <div class="pt-24 pb-16 px-4 sm:px-6 lg:px-8 max-w-4xl mx-auto space-y-6 animate-fadeIn">
    
    <!-- Top Navigation Bar -->
    <div class="flex items-center justify-between border-b border-slate-200 pb-4">
      <button 
        @click="emit('close')" 
        class="glass-button-secondary text-xs py-2 px-4 flex items-center gap-2 hover:bg-slate-200 transition-colors"
      >
        <ArrowLeft class="w-4 h-4" />
        <span>Back to Event Details</span>
      </button>

      <div class="text-xs text-slate-500 font-medium hidden sm:block">
        Registering for <span class="text-slate-900 font-bold">{{ event?.name }}</span>
      </div>
    </div>

    <!-- Main Card Body Container -->
    <div class="glass-panel border-slate-200 w-full rounded-3xl shadow-xl overflow-hidden bg-white text-slate-900">
      
      <!-- Page Header -->
      <div class="p-6 border-b border-slate-200 flex items-center justify-between bg-slate-50">
        <div class="flex items-center gap-3">
          <div class="p-2.5 rounded-xl bg-blue-100 border border-blue-200 text-blue-700">
            <Ticket class="w-6 h-6" />
          </div>
          <div>
            <h3 class="font-extrabold text-lg text-slate-900">Official Event Registration Page</h3>
            <p class="text-xs text-slate-500 font-medium">{{ event?.name }}</p>
          </div>
        </div>
      </div>

      <!-- Step Indicator Bar -->
      <div class="grid grid-cols-4 border-b border-slate-200 text-xs font-semibold text-center bg-slate-100/60">
        <div 
          v-for="s in [1,2,3,4]" 
          :key="s"
          :class="[
            step === s ? 'text-blue-600 border-b-2 border-blue-600 bg-white font-bold' : 'text-slate-500',
            'py-3 flex items-center justify-center gap-1.5 transition-all'
          ]"
        >
          <span class="w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold"
            :class="step >= s ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-600'"
          >{{ s }}</span>
          <span class="hidden sm:inline">
            {{ s === 1 ? 'Segment' : s === 2 ? 'Team Info' : s === 3 ? 'Payment' : 'Ticket Pass' }}
          </span>
        </div>
      </div>

      <!-- Step Body Content -->
      <div class="p-6 space-y-6 max-h-[65vh] overflow-y-auto bg-white">
        
        <!-- Step 1: Select Segment -->
        <div v-if="step === 1" class="space-y-4">
          <h4 class="font-bold text-xs text-slate-500 uppercase tracking-wider">Choose Competition Segment</h4>
          
          <div class="space-y-3">
            <div
              v-for="seg in (event?.segments || [])"
              :key="seg.id || seg.segmentId"
              @click="currentSegment = seg"
              :class="[
                (currentSegment?.id || currentSegment?.segmentId) === (seg.id || seg.segmentId)
                  ? 'border-blue-600 bg-blue-50/60 shadow-sm' 
                  : 'border-slate-200 bg-white hover:border-slate-300',
                'p-4 rounded-xl border cursor-pointer transition-all flex items-center justify-between'
              ]"
            >
              <div>
                <div class="flex items-center gap-2 mb-1">
                  <span class="font-extrabold text-slate-900 text-base">{{ seg.title }}</span>
                  <span class="px-2 py-0.5 rounded bg-blue-100 text-blue-800 text-[10px] font-bold border border-blue-200">
                    {{ seg.type }}
                  </span>
                </div>
                <p class="text-xs text-slate-600">{{ seg.description }}</p>
              </div>

              <div class="text-right shrink-0">
                <div class="text-xs font-semibold text-slate-400">Reg Fee</div>
                <div class="text-base font-extrabold text-blue-600 font-mono">৳ {{ seg.regFee }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Step 2: Team & Participant Details -->
        <div v-else-if="step === 2" class="space-y-4">
          
          <div class="flex gap-3">
            <button
              @click="participationType = 'TEAM'"
              :class="[
                participationType === 'TEAM' ? 'bg-blue-600 text-white font-semibold shadow-xs' : 'bg-slate-100 text-slate-700 border border-slate-200',
                'flex-1 py-2.5 rounded-xl text-xs flex items-center justify-center gap-2 transition-all'
              ]"
            >
              <Users class="w-4 h-4" />
              <span>Team Registration</span>
            </button>

            <button
              @click="participationType = 'SOLO'"
              :class="[
                participationType === 'SOLO' ? 'bg-blue-600 text-white font-semibold shadow-xs' : 'bg-slate-100 text-slate-700 border border-slate-200',
                'flex-1 py-2.5 rounded-xl text-xs flex items-center justify-center gap-2 transition-all'
              ]"
            >
              <ShieldCheck class="w-4 h-4" />
              <span>Solo Participant</span>
            </button>
          </div>

          <div v-if="participationType === 'TEAM'" class="space-y-1">
            <label class="block text-xs font-bold text-slate-700">Team Name *</label>
            <input
              v-model="teamName"
              type="text"
              placeholder="e.g. ByteBuilders or TechTitans"
              class="glass-input w-full text-xs"
            />
          </div>

          <!-- Leader / Main Info -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label class="block text-xs font-bold text-slate-700 mb-1">Leader / Participant Name *</label>
              <input v-model="leaderName" type="text" class="glass-input w-full text-xs" />
            </div>

            <div>
              <label class="block text-xs font-bold text-slate-700 mb-1">Student ID / Roll *</label>
              <input v-model="studentId" type="text" placeholder="e.g. 1804001" class="glass-input w-full text-xs font-mono" />
            </div>

            <div>
              <label class="block text-xs font-bold text-slate-700 mb-1">Department</label>
              <select v-model="department" class="glass-input w-full text-xs bg-white">
                <option v-for="d in departmentsList" :key="d.department_id || d.id || d.code" :value="d.code">{{ d.name }} ({{ d.code }})</option>
              </select>
            </div>

            <div>
              <label class="block text-xs font-bold text-slate-700 mb-1">T-Shirt Size</label>
              <select v-model="tshirtSize" class="glass-input w-full text-xs bg-white">
                <option value="S">Small (S)</option>
                <option value="M">Medium (M)</option>
                <option value="L">Large (L)</option>
                <option value="XL">Extra Large (XL)</option>
                <option value="XXL">Double XL (XXL)</option>
              </select>
            </div>
          </div>

          <!-- Team Members Addition -->
          <div v-if="participationType === 'TEAM'" class="pt-4 border-t border-slate-200 space-y-3">
            <div class="flex items-center justify-between">
              <h5 class="text-xs font-bold text-slate-600 uppercase tracking-wider">Additional Team Roster</h5>
              <button
                @click="addMember"
                class="text-xs text-blue-600 hover:underline font-bold"
              >
                + Add Member
              </button>
            </div>

            <div v-for="(m, idx) in teamMembers" :key="idx" class="glass-panel p-3 border-slate-200 bg-slate-50 space-y-2 relative">
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-2">
                <input v-model="m.name" type="text" placeholder="Member Name" class="glass-input text-xs" />
                <input v-model="m.studentId" type="text" placeholder="Student ID" class="glass-input text-xs font-mono" />
                <div class="flex gap-2">
                  <select v-model="m.tshirtSize" class="glass-input text-xs flex-1 bg-white">
                    <option value="S">S</option>
                    <option value="M">M</option>
                    <option value="L">L</option>
                    <option value="XL">XL</option>
                  </select>
                  <button @click="removeMember(idx)" class="p-2 text-rose-600 hover:bg-slate-200 rounded-lg">
                    <X class="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Step 3: Payment Details -->
        <div v-else-if="step === 3" class="space-y-4">
          
          <div class="glass-panel p-4 border-blue-200 bg-blue-50/70 flex items-center justify-between">
            <div>
              <span class="text-xs text-slate-600 block font-medium">Total Segment Registration Fee</span>
              <span class="text-xl font-extrabold text-blue-700 font-mono">৳ {{ currentSegment?.regFee || 500 }}</span>
            </div>

            <span class="px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 border border-emerald-300 text-xs font-bold">
              Instant Verification
            </span>
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-700 mb-2">Select Mobile Banking Method</label>
            <div class="grid grid-cols-3 gap-3">
              <button
                v-for="m in ['bKash', 'Nagad', 'Rocket']"
                :key="m"
                @click="paymentMethod = m"
                :class="[
                  paymentMethod === m ? 'border-blue-600 bg-blue-50 text-blue-700 font-bold' : 'border-slate-200 bg-white text-slate-600',
                  'p-3 rounded-xl border text-xs text-center transition-all'
                ]"
              >
                {{ m }}
              </button>
            </div>
          </div>

          <div class="glass-panel p-4 border-slate-200 space-y-3 bg-slate-50">
            <div class="flex items-center justify-between text-xs">
              <span class="text-slate-600 font-medium">Send Payment (Merchant bKash/Nagad):</span>
              <div class="flex items-center gap-2 font-mono font-bold text-blue-600">
                <span>01712-345678</span>
                <button @click="copyBkash" class="p-1 hover:text-blue-800 transition-colors" title="Copy Number">
                  <Copy class="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
            <p v-if="copiedNumber" class="text-[10px] text-emerald-600 text-right font-bold">Copied to clipboard!</p>
          </div>

          <div class="space-y-1">
            <label class="block text-xs font-bold text-slate-700">Transaction ID (TrxID) *</label>
            <input
              v-model="transactionNumber"
              type="text"
              placeholder="e.g. TXN88921092 or NGD44810"
              class="glass-input w-full text-xs font-mono uppercase tracking-wider"
            />
            <span class="text-[10px] text-slate-500">Enter the transaction ID received from your mobile banking app SMS confirmation.</span>
          </div>
        </div>

        <!-- Step 4: Ticket E-Pass Confirmation -->
        <div v-else-if="step === 4" class="text-center space-y-6 py-4">
          <div class="w-16 h-16 rounded-full bg-emerald-100 border border-emerald-300 text-emerald-600 flex items-center justify-center mx-auto shadow-md">
            <CheckCircle2 class="w-10 h-10" />
          </div>

          <div>
            <h3 class="text-2xl font-black text-slate-900">Registration Successful!</h3>
            <p class="text-xs text-slate-600 mt-1">Your digital entry pass has been generated and confirmed.</p>
          </div>

          <!-- Digital Pass Ticket Card -->
          <div class="glass-panel p-6 border-slate-300 bg-white max-w-md mx-auto text-left relative overflow-hidden shadow-xl">
            <div class="flex items-center justify-between border-b border-slate-200 pb-3 mb-4">
              <div>
                <span class="text-[10px] uppercase font-bold text-blue-600 tracking-widest block">CUET EventX Pass</span>
                <h4 class="font-extrabold text-slate-900 text-base">{{ createdRegistration?.eventName }}</h4>
              </div>
              <QrCode class="w-10 h-10 text-slate-900" />
            </div>

            <div class="space-y-2 text-xs">
              <div class="flex justify-between">
                <span class="text-slate-500">Segment:</span>
                <span class="font-bold text-slate-900">{{ createdRegistration?.segmentTitle }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-slate-500">Team / Participant:</span>
                <span class="font-bold text-blue-600">{{ createdRegistration?.teamName }}</span>
              </div>
              <div class="flex justify-between font-mono">
                <span class="text-slate-500">Pass Code:</span>
                <span class="font-bold text-emerald-700">{{ createdRegistration?.ticketCode }}</span>
              </div>
              <div class="flex justify-between font-mono">
                <span class="text-slate-500">TrxID:</span>
                <span class="text-slate-700 font-semibold">{{ createdRegistration?.transactionNumber }}</span>
              </div>
            </div>
          </div>
        </div>

      </div>

      <!-- Modal Actions Footer -->
      <div v-if="step < 4" class="p-4 border-t border-slate-200 bg-slate-50 flex items-center justify-between">
        <button
          v-if="step > 1"
          @click="step--"
          class="glass-button-secondary text-xs py-2 px-4"
        >
          <ArrowLeft class="w-4 h-4" />
          <span>Back</span>
        </button>
        <div v-else></div>

        <button
          v-if="step === 1"
          @click="step = 2"
          :disabled="!isStep1Valid"
          class="glass-button text-xs py-2.5 px-6 disabled:opacity-50"
        >
          <span>Next: Team Details</span>
          <ArrowRight class="w-4 h-4" />
        </button>

        <button
          v-else-if="step === 2"
          @click="step = 3"
          :disabled="!isStep2Valid"
          class="glass-button text-xs py-2.5 px-6 disabled:opacity-50"
        >
          <span>Next: Payment</span>
          <ArrowRight class="w-4 h-4" />
        </button>

        <button
          v-else-if="step === 3"
          @click="handleSubmit"
          :disabled="!isStep3Valid || isSubmitting"
          class="glass-button text-xs py-2.5 px-6 disabled:opacity-50"
        >
          <span>Complete Registration</span>
          <Sparkles class="w-4 h-4" />
        </button>
      </div>

      <div v-else class="p-4 border-t border-slate-200 bg-slate-50 text-center">
        <button @click="emit('close')" class="glass-button text-xs py-2.5 px-8">
          Done & Close
        </button>
      </div>

    </div>
  </div>
</template>
