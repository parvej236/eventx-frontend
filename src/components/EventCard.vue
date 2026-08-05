<script setup>
import { Trophy, Calendar, MapPin, Layers, ArrowRight, Clock, Building2 } from 'lucide-vue-next'

const props = defineProps({
  event: Object
})

const emit = defineEmits(['select', 'register'])

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-BD', { style: 'currency', currency: 'BDT', maximumFractionDigits: 0 }).format(amount || 0)
}

const formatDate = (dateStr) => {
  if (!dateStr) return 'TBA'
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

const getStatusBadge = (status) => {
  switch (status?.toUpperCase()) {
    case 'LIVE NOW':
    case 'LIVE':
      return { class: 'badge-live', label: '🔴 Live Now' }
    case 'REGISTRATION OPEN':
      return { class: 'badge-open', label: '🟢 Registration Open' }
    case 'ENDED':
      return { class: 'badge-ended', label: '⚪ Completed' }
    default:
      return { class: 'badge-upcoming', label: '⏳ Upcoming' }
  }
}
</script>

<template>
  <div class="glass-panel glass-panel-hover flex flex-col overflow-hidden group border border-slate-200 rounded-xl bg-white">
    
    <!-- Banner Container -->
    <div class="h-44 relative overflow-hidden bg-slate-100">
      <img
        v-if="event.bannerUrl"
        :src="event.bannerUrl"
        :alt="event.name"
        class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
      />
      <div v-else class="w-full h-full bg-slate-200 flex items-center justify-center text-slate-400 font-bold text-2xl">
        CUET EventX
      </div>

      <div class="absolute inset-0 bg-gradient-to-t from-slate-900/75 via-slate-900/15 to-transparent"></div>

      <!-- Top Badges -->
      <div class="absolute top-3 left-3 right-3 flex items-center justify-between z-10">
        <span 
          :class="[getStatusBadge(event.status).class, 'px-2.5 py-0.5 rounded-md text-xs font-semibold shadow-2xs']"
        >
          {{ getStatusBadge(event.status).label }}
        </span>

        <span class="px-2.5 py-0.5 rounded-md bg-slate-900/75 text-white text-xs font-medium backdrop-blur-xs">
          {{ event.category || 'Tech' }}
        </span>
      </div>

      <!-- Bottom Overlay Info -->
      <div class="absolute bottom-3 left-3 right-3 z-10 flex items-center justify-between text-xs text-white">
        <div class="flex items-center gap-1.5 bg-slate-900/80 px-2 py-0.5 rounded-md border border-white/10 font-medium text-[11px]">
          <Calendar class="w-3.5 h-3.5 text-blue-400" />
          <span>{{ formatDate(event.startAt) }}</span>
        </div>
        <div class="flex items-center gap-1 bg-amber-500 text-slate-950 px-2 py-0.5 rounded-md font-bold font-mono text-xs">
          <Trophy class="w-3.5 h-3.5" />
          <span>{{ formatCurrency(event.prizePool) }}</span>
        </div>
      </div>
    </div>

    <!-- Content Details -->
    <div class="p-4 flex-1 flex flex-col justify-between space-y-3">
      <div>
        <div class="flex items-center gap-1.5 mb-1.5 text-xs text-slate-500 font-medium">
          <Building2 class="w-3.5 h-3.5 text-slate-400" />
          <span class="font-semibold text-blue-700">{{ event.organizerClub || 'CUET Central' }}</span>
        </div>

        <h3 class="text-base font-bold text-slate-900 group-hover:text-blue-700 transition-colors line-clamp-1 mb-1">
          {{ event.name }}
        </h3>

        <p class="text-xs text-slate-600 line-clamp-2 leading-relaxed">
          {{ event.description }}
        </p>
      </div>

      <!-- Footer Info & Actions -->
      <div class="pt-3 border-t border-slate-100">
        <div class="flex items-center justify-between text-xs text-slate-500 mb-3">
          <div class="flex items-center gap-1">
            <Layers class="w-3.5 h-3.5 text-indigo-600" />
            <span>{{ event.segments?.length || 1 }} Segments</span>
          </div>

          <div class="flex items-center gap-1">
            <MapPin class="w-3.5 h-3.5 text-rose-500" />
            <span>{{ event.venueName || 'CUET Campus' }}</span>
          </div>
        </div>

        <div class="flex items-center gap-2">
          <button
            @click="emit('select', event)"
            class="glass-button-secondary text-xs flex-1 py-2 px-3 flex items-center justify-center gap-1.5 whitespace-nowrap"
          >
            <span>Details</span>
          </button>
          
          <button
            @click="emit('register', event)"
            class="glass-button text-xs flex-1 py-2 px-3 flex items-center justify-center gap-1.5 whitespace-nowrap"
          >
            <span>Register</span>
            <ArrowRight class="w-3.5 h-3.5 shrink-0" />
          </button>
        </div>
      </div>

    </div>
  </div>
</template>
