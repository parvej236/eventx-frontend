<script setup>
import { ref } from 'vue'
import { X, Trophy, Calendar, MapPin, Layers, CheckCircle2, UserCheck, Video, Phone, ShieldAlert, ArrowRight, ExternalLink } from 'lucide-vue-next'

const props = defineProps({
  event: Object
})

const emit = defineEmits(['close', 'registerSegment'])

const activeTab = ref('segments')

const tabs = [
  { id: 'segments', label: 'Segments & Schedule' },
  { id: 'rules', label: 'Rules & Guidelines' },
  { id: 'venue', label: 'Venue & Live Feed' },
  { id: 'contact', label: 'Contact & FAQ' }
]

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-BD', { style: 'currency', currency: 'BDT', maximumFractionDigits: 0 }).format(amount || 0)
}

const formatDate = (dateStr) => {
  if (!dateStr) return 'TBA'
  return new Date(dateStr).toLocaleString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}
</script>

<template>
  <div v-if="event" class="fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 sm:p-6">
    
    <div class="glass-panel border-slate-200 w-full max-w-4xl max-h-[90vh] flex flex-col rounded-2xl shadow-2xl overflow-hidden bg-white text-slate-900">
      
      <!-- Modal Header Banner -->
      <div class="relative h-64 sm:h-72 bg-slate-900 shrink-0">
        <img
          v-if="event.bannerUrl"
          :src="event.bannerUrl"
          :alt="event.name"
          class="w-full h-full object-cover"
        />
        <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/40 to-transparent"></div>

        <!-- Close Button -->
        <button
          @click="emit('close')"
          class="absolute top-4 right-4 p-2 rounded-full bg-slate-900/70 hover:bg-slate-900 border border-white/20 text-white transition-colors z-20"
        >
          <X class="w-5 h-5" />
        </button>

        <!-- Header Content -->
        <div class="absolute bottom-6 left-6 right-6 z-10 text-white">
          <div class="flex items-center gap-2 mb-2">
            <span class="px-3 py-1 rounded-full bg-amber-500/20 text-amber-300 border border-amber-500/30 text-xs font-bold uppercase tracking-wider">
              {{ event.category || 'Tech Competition' }}
            </span>
            <span class="px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 text-xs font-bold uppercase tracking-wider">
              {{ event.status || 'ACTIVE' }}
            </span>
          </div>

          <h2 class="text-2xl sm:text-4xl font-black text-white mb-2 leading-tight">
            {{ event.name }}
          </h2>

          <div class="flex flex-wrap items-center gap-4 text-xs sm:text-sm text-slate-200">
            <div class="flex items-center gap-1.5 font-bold text-amber-300">
              <Trophy class="w-4 h-4" />
              <span>Prize Pool: {{ formatCurrency(event.prizePool) }}</span>
            </div>

            <div class="flex items-center gap-1.5">
              <Calendar class="w-4 h-4 text-blue-400" />
              <span>{{ formatDate(event.startAt) }}</span>
            </div>

            <div class="flex items-center gap-1.5">
              <MapPin class="w-4 h-4 text-rose-400" />
              <span>{{ event.venueName || 'CUET Campus' }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <div class="flex border-b border-slate-200 px-6 bg-slate-50">
        <button
          v-for="t in tabs"
          :key="t.id"
          @click="activeTab = t.id"
          :class="[
            activeTab === t.id
              ? 'border-blue-600 text-blue-600 font-bold'
              : 'border-transparent text-slate-600 hover:text-slate-900 font-medium',
            'px-4 py-3 border-b-2 text-xs sm:text-sm transition-all'
          ]"
        >
          {{ t.label }}
        </button>
      </div>

      <!-- Modal Body Content Scrollable -->
      <div class="p-6 overflow-y-auto flex-1 space-y-6 bg-white">
        
        <!-- Tab 1: Segments & Schedule -->
        <div v-if="activeTab === 'segments'" class="space-y-4">
          <div class="p-4 rounded-xl border border-blue-200 bg-blue-50/50">
            <h4 class="font-bold text-blue-900 text-sm mb-1">About {{ event.name }}</h4>
            <p class="text-xs text-slate-700 leading-relaxed">{{ event.description }}</p>
          </div>

          <h3 class="font-extrabold text-lg text-slate-900 flex items-center gap-2 pt-2">
            <Layers class="w-5 h-5 text-blue-600" />
            <span>Event Segments & Competitions</span>
          </h3>

          <div class="space-y-3">
            <div
              v-for="seg in (event.segments || [])"
              :key="seg.id"
              class="glass-panel p-5 border border-slate-200 rounded-xl hover:border-blue-400 transition-all flex flex-col md:flex-row md:items-center justify-between gap-4 bg-white"
            >
              <div class="flex-1 space-y-1">
                <div class="flex items-center gap-2">
                  <h4 class="font-bold text-base text-slate-900">{{ seg.title }}</h4>
                  <span class="px-2.5 py-0.5 rounded bg-blue-50 text-blue-700 text-[10px] font-bold border border-blue-200">
                    {{ seg.type }}
                  </span>
                </div>
                <p class="text-xs text-slate-600 leading-relaxed">{{ seg.description }}</p>
                <div class="flex items-center gap-4 text-xs text-slate-600 pt-2 font-mono">
                  <span>Prize: <strong class="text-amber-600">{{ formatCurrency(seg.prize) }}</strong></span>
                  <span>Reg Fee: <strong class="text-emerald-600">৳ {{ seg.regFee }}</strong></span>
                  <span>Venue: {{ seg.buildingName || event.venueName }}</span>
                </div>
              </div>

              <button
                @click="emit('registerSegment', { event, segment: seg })"
                class="glass-button text-xs shrink-0 whitespace-nowrap py-2.5 px-4"
              >
                <span>Register Segment</span>
                <ArrowRight class="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        </div>

        <!-- Tab 2: Rules & Guidelines -->
        <div v-else-if="activeTab === 'rules'" class="space-y-4">
          <div class="glass-panel p-5 space-y-3 border-slate-200 bg-slate-50">
            <h4 class="font-bold text-slate-900 text-sm flex items-center gap-2">
              <ShieldAlert class="w-4 h-4 text-blue-600" />
              <span>General Participation Regulations</span>
            </h4>
            <ul class="text-xs text-slate-700 space-y-2 list-disc list-inside leading-relaxed">
              <li>All team members must be current undergraduate or postgraduate students of CUET or affiliated universities.</li>
              <li>Each participant must present their university ID card or registration ticket at venue check-in.</li>
              <li>Plagiarism, pre-built solutions (for hackathons), or unapproved bot hardware specs will lead to instant disqualification.</li>
              <li>Registration fees are strictly non-refundable once transaction ID verification is completed by event committee.</li>
            </ul>
          </div>
        </div>

        <!-- Tab 3: Venue & Live Feed -->
        <div v-else-if="activeTab === 'venue'" class="space-y-4">
          <div class="glass-panel p-5 space-y-3 border-slate-200 bg-white">
            <div class="flex items-center justify-between">
              <h4 class="font-bold text-slate-900 text-base flex items-center gap-2">
                <MapPin class="w-5 h-5 text-rose-500" />
                <span>{{ event.venueName || 'CUET Academic Area' }}</span>
              </h4>
              <span class="text-xs font-semibold px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
                Venue Verified
              </span>
            </div>
            <p class="text-xs text-slate-600">
              Located at the heart of Chittagong University of Engineering & Technology campus. High-speed gigabit Wi-Fi and power back-ups are available on site.
            </p>
            <div class="p-4 rounded-xl bg-slate-900 text-white border border-slate-800 flex items-center justify-between text-xs">
              <div class="flex items-center gap-2 text-cyan-400">
                <Video class="w-4 h-4" />
                <span>Live Event Streaming Available</span>
              </div>
              <a href="https://youtube.com" target="_blank" class="text-amber-400 hover:underline flex items-center gap-1 font-bold">
                <span>Watch Stream</span>
                <ExternalLink class="w-3.5 h-3.5" />
              </a>
            </div>
          </div>
        </div>

        <!-- Tab 4: Contact & FAQ -->
        <div v-else-if="activeTab === 'contact'" class="space-y-4">
          <div class="glass-panel p-5 space-y-3 border-slate-200 bg-slate-50">
            <h4 class="font-bold text-slate-900 text-base flex items-center gap-2">
              <Phone class="w-4 h-4 text-blue-600" />
              <span>Organizer Contact Details</span>
            </h4>
            <p class="text-xs text-slate-700">{{ event.organizerContact || 'Email: support@cuet.ac.bd | Helpline: +880 1712-345678' }}</p>
          </div>
        </div>

      </div>

      <!-- Footer CTA -->
      <div class="p-4 border-t border-slate-200 bg-slate-50 flex items-center justify-between">
        <div class="text-xs text-slate-600">
          <span>Organized by <strong class="text-slate-900 font-bold">{{ event.organizerClub }}</strong></span>
        </div>

        <button
          @click="emit('registerSegment', { event, segment: event.segments?.[0] })"
          class="glass-button text-sm py-2.5 px-6"
        >
          <span>Register Now</span>
          <ArrowRight class="w-4 h-4" />
        </button>
      </div>

    </div>
  </div>
</template>
