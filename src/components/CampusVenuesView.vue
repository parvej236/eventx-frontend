<script setup>
import { ref } from 'vue'
import { MapPin, Building2, Users, Video, Wifi, ShieldCheck, Play, X } from 'lucide-vue-next'

const props = defineProps({
  buildings: Array,
  events: Array
})

const activeStreamBuilding = ref(null)
</script>

<template>
  <div class="pt-28 pb-16 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto space-y-8">
    
    <!-- Header -->
    <div class="text-center max-w-3xl mx-auto space-y-3">
      <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-blue-50 border border-blue-200 text-blue-700 text-xs font-bold uppercase tracking-wider">
        <MapPin class="w-3.5 h-3.5" />
        <span>Campus Facilities & Schedule</span>
      </div>

      <h2 class="text-3xl sm:text-5xl font-black text-slate-900">CUET Campus Venues</h2>
      <p class="text-slate-600 text-sm sm:text-base">
        Explore academic halls, high-capacity auditoriums, and live video broadcast links across campus grounds.
      </p>
    </div>

    <!-- Buildings Directory Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div
        v-for="b in buildings"
        :key="b.id"
        class="glass-panel border-slate-200 p-6 hover:border-blue-400 transition-all rounded-2xl flex flex-col justify-between bg-white shadow-sm space-y-4"
      >
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="p-3 rounded-xl bg-blue-50 border border-blue-200 text-blue-600">
                <Building2 class="w-6 h-6" />
              </div>
              <div>
                <h3 class="text-xl font-bold text-slate-900">{{ b.name }}</h3>
                <span class="text-xs text-slate-500 font-mono">Code: {{ b.code }}</span>
              </div>
            </div>

            <span class="px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 text-xs font-bold">
              Active Facility
            </span>
          </div>

          <p class="text-xs text-slate-600 leading-relaxed">{{ b.description }}</p>

          <div class="grid grid-cols-2 gap-3 text-xs text-slate-700 p-3 rounded-xl bg-slate-50 border border-slate-200">
            <div>
              <span class="text-slate-500 block text-[10px] uppercase font-bold">Seating Capacity</span>
              <span class="font-bold text-slate-900 font-mono">{{ b.capacity }} Seats</span>
            </div>
            <div>
              <span class="text-slate-500 block text-[10px] uppercase font-bold">Wi-Fi & Power</span>
              <span class="font-bold text-emerald-700">✓ Gigabit Available</span>
            </div>
          </div>
        </div>

        <div class="pt-4 border-t border-slate-100 flex items-center justify-between">
          <div class="flex items-center gap-2 text-xs text-slate-500">
            <Wifi class="w-4 h-4 text-blue-600" />
            <span>High-Speed Network</span>
          </div>

          <button
            @click="activeStreamBuilding = b"
            class="glass-button text-xs py-2 px-4"
          >
            <Play class="w-3.5 h-3.5 fill-white" />
            <span>Live Stream</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Live Stream Simulation Modal -->
    <div v-if="activeStreamBuilding" class="fixed inset-0 z-50 bg-slate-900/70 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="glass-panel p-6 border-slate-200 max-w-2xl w-full rounded-2xl bg-white text-slate-900 space-y-4 shadow-2xl">
        <div class="flex items-center justify-between border-b border-slate-200 pb-3">
          <div class="flex items-center gap-2">
            <Video class="w-5 h-5 text-rose-600" />
            <h4 class="font-extrabold text-slate-900 text-lg">Live Video Broadcast — {{ activeStreamBuilding.name }}</h4>
          </div>
          <button @click="activeStreamBuilding = null" class="text-slate-400 hover:text-slate-900"><X class="w-5 h-5" /></button>
        </div>

        <!-- Simulated Video Player -->
        <div class="relative aspect-video rounded-xl bg-slate-900 overflow-hidden flex items-center justify-center text-white">
          <img src="/images/techfest_banner.png" alt="Stream Preview" class="w-full h-full object-cover opacity-60" />
          <div class="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-transparent to-transparent flex items-center justify-center">
            <div class="text-center space-y-2">
              <div class="w-14 h-14 rounded-full bg-rose-600 text-white flex items-center justify-center mx-auto shadow-lg animate-pulse">
                <Play class="w-6 h-6 fill-white ml-0.5" />
              </div>
              <span class="text-xs font-bold uppercase tracking-wider bg-rose-600 px-3 py-1 rounded-full text-white">🔴 LIVE CAM BROADCAST</span>
            </div>
          </div>
        </div>

        <div class="flex items-center justify-between text-xs text-slate-600">
          <span>Connecting to stream endpoint: <strong class="font-mono text-blue-600">{{ activeStreamBuilding.liveUrl }}</strong></span>
          <button @click="activeStreamBuilding = null" class="glass-button-secondary py-1.5 px-4 text-xs">Close Stream</button>
        </div>
      </div>
    </div>

  </div>
</template>
