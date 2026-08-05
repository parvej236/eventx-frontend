<script setup>
import { ref } from 'vue'
import { Terminal, RefreshCw } from 'lucide-vue-next'

const logs = ref([
  { id: 1, time: '2026-08-03 20:12:15', level: 'INFO', scope: 'SpringSecurity', message: 'User admin@cuet.ac.bd authenticated successfully.' },
  { id: 2, time: '2026-08-03 20:10:04', level: 'INFO', scope: 'ClubController', message: 'Fetched 15 active clubs from MySQL eventxdb.' },
  { id: 3, time: '2026-08-03 20:08:20', level: 'SUCCESS', scope: 'Hibernate', message: 'Initialized JPA EntityManagerFactory for persistence unit default.' },
  { id: 4, time: '2026-08-03 20:05:12', level: 'INFO', scope: 'UserController', message: 'Retrieved 5 registered users from database.' },
  { id: 5, time: '2026-08-03 20:00:18', level: 'DB_SEED', scope: 'DatabaseInitializer', message: 'Executed schema.sql and data.sql scripts successfully.' }
])

const activeFilter = ref('ALL')

const refreshLogs = () => {
  logs.value.unshift({
    id: Date.now(),
    time: new Date().toISOString().replace('T', ' ').substring(0, 19),
    level: 'INFO',
    scope: 'SystemAudit',
    message: 'Manual audit refresh triggered by admin.'
  })
}
</script>

<template>
  <div class="space-y-6 w-full">
    <div class="flex justify-between items-center">
      <div>
        <h2 class="text-xl font-bold text-slate-900">System Audit Logs</h2>
        <p class="text-xs text-slate-500 font-medium">Real-time backend system events & security logs</p>
      </div>
      <button @click="refreshLogs" class="flex items-center gap-2 bg-slate-900 hover:bg-black text-white text-xs font-bold px-3.5 py-2 rounded-xl transition-all shadow-sm">
        <RefreshCw class="w-3.5 h-3.5" /> Refresh
      </button>
    </div>

    <!-- Console Log Window -->
    <div class="bg-slate-950 text-slate-200 rounded-2xl p-6 font-mono text-xs shadow-xl border border-slate-800 space-y-4">
      <div class="flex items-center justify-between border-b border-slate-800 pb-4">
        <div class="flex items-center gap-2 text-slate-400">
          <Terminal class="w-4 h-4 text-emerald-400" />
          <span class="font-bold">System Log Terminal</span>
        </div>
        <div class="flex gap-2">
          <span class="w-3 h-3 rounded-full bg-red-500 inline-block"></span>
          <span class="w-3 h-3 rounded-full bg-amber-500 inline-block"></span>
          <span class="w-3 h-3 rounded-full bg-emerald-500 inline-block"></span>
        </div>
      </div>

      <div class="space-y-2.5 overflow-x-auto max-h-[500px] overflow-y-auto">
        <div v-for="log in logs" :key="log.id" class="flex items-start gap-3 hover:bg-slate-900/60 p-1.5 rounded transition-colors">
          <span class="text-slate-500 shrink-0">[{{ log.time }}]</span>
          <span :class="[
            'font-bold px-1.5 py-0.5 rounded text-[10px] uppercase shrink-0',
            log.level === 'SUCCESS' ? 'bg-emerald-900/50 text-emerald-400 border border-emerald-700/50' :
            log.level === 'DB_SEED' ? 'bg-purple-900/50 text-purple-400 border border-purple-700/50' : 'bg-blue-900/50 text-blue-400 border border-blue-700/50'
          ]">{{ log.level }}</span>
          <span class="text-amber-400 font-bold shrink-0">[{{ log.scope }}]</span>
          <span class="text-slate-300">{{ log.message }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
