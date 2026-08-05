<script setup>
import { ref } from 'vue'
import { Users, Calendar, Award, CheckCircle2, ArrowRight, ShieldCheck } from 'lucide-vue-next'

const props = defineProps({
  clubs: Array
})

const emit = defineEmits(['selectClubEvents'])

const joinedClub = ref(null)

const handleJoin = (club) => {
  joinedClub.value = club.name
  setTimeout(() => { joinedClub.value = null }, 3000)
}
</script>

<template>
  <div class="pt-28 pb-16 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto space-y-8">
    
    <!-- Top Header -->
    <div class="text-center max-w-3xl mx-auto space-y-3">
      <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-blue-50 border border-blue-200 text-blue-700 text-xs font-bold uppercase tracking-wider">
        <Users class="w-3.5 h-3.5" />
        <span>CUET Registered Societies & Clubs</span>
      </div>

      <h2 class="text-3xl sm:text-5xl font-black text-slate-900">Campus Clubs & Societies</h2>
      <p class="text-slate-600 text-sm sm:text-base">
        Empowering innovation, robotics, cultural heritage, and professional leadership across the student body.
      </p>
    </div>

    <!-- Toast message for join -->
    <div v-if="joinedClub" class="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-bold text-center">
      ✓ Membership application submitted to {{ joinedClub }}!
    </div>

    <!-- Clubs Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div
        v-for="c in clubs"
        :key="c.id"
        class="glass-panel border-slate-200 p-6 hover:border-blue-400 transition-all rounded-2xl flex flex-col justify-between bg-white shadow-sm space-y-4"
      >
        <div class="space-y-4">
          <div class="flex items-center gap-4">
            <img
              :src="c.logoUrl"
              :alt="c.name"
              class="w-16 h-16 rounded-2xl object-cover border border-slate-200 shadow-sm"
            />
            <div>
              <div class="flex items-center gap-2">
                <h3 class="text-xl font-extrabold text-slate-900">{{ c.name }}</h3>
                <span class="px-2 py-0.5 rounded bg-blue-50 text-blue-700 text-[10px] font-bold border border-blue-200">
                  {{ c.category }}
                </span>
              </div>
              <p class="text-xs text-amber-700 font-bold font-mono mt-0.5">Est. {{ c.established }} | Code: {{ c.code }}</p>
            </div>
          </div>

          <p class="text-xs text-slate-600 leading-relaxed">{{ c.description }}</p>

          <div class="grid grid-cols-2 gap-3 text-xs text-slate-700 p-3 rounded-xl bg-slate-50 border border-slate-200">
            <div>
              <span class="text-slate-500 block text-[10px] uppercase font-bold">Active Members</span>
              <span class="font-bold text-slate-900 font-mono">{{ c.membersCount }}+ Joined</span>
            </div>
            <div>
              <span class="text-slate-500 block text-[10px] uppercase font-bold">Society Status</span>
              <span class="font-bold text-emerald-700">✓ {{ c.status }}</span>
            </div>
          </div>
        </div>

        <div class="pt-4 border-t border-slate-100 flex items-center justify-between gap-3">
          <button
            @click="emit('selectClubEvents', c.name)"
            class="glass-button-secondary text-xs flex-1 py-2"
          >
            <span>View Events</span>
          </button>

          <button
            @click="handleJoin(c)"
            class="glass-button text-xs flex-1 py-2"
          >
            <span>Join Club</span>
            <ArrowRight class="w-3.5 h-3.5" />
          </button>
        </div>
      </div>
    </div>

  </div>
</template>
