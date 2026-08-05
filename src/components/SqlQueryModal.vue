<script setup>
import { ref, computed, watch } from 'vue'
import { 
  Database, Code2, Check, Copy, X, Terminal, HelpCircle, Info, 
  Layers, Sparkles, Search, CheckCircle2, Clock, ShieldCheck, Mail, 
  Tag, Hash, ArrowUpRight, Zap, User, Trophy, Building2, GraduationCap, 
  Users, Calendar, CreditCard, MapPin, Award
} from 'lucide-vue-next'

const props = defineProps({
  isOpen: Boolean,
  title: {
    type: String,
    default: 'MySQL Database Query'
  },
  purpose: {
    type: String,
    default: 'Shows the list of records from MySQL database where entity parameters match.'
  },
  query: {
    type: String,
    default: ''
  },
  explanation: {
    type: String,
    default: ''
  },
  concepts: {
    type: Array,
    default: () => ['INNER JOIN', 'WHERE', 'ORDER BY']
  },
  columns: {
    type: Array,
    default: () => []
  },
  rows: {
    type: Array,
    default: () => []
  },
  queries: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close'])

const activeTabIndex = ref(0)
const resultSearchQuery = ref('')
const copied = ref(false)

watch(() => props.isOpen, (newVal) => {
  if (newVal) {
    activeTabIndex.value = 0
    resultSearchQuery.value = ''
  }
})

watch(activeTabIndex, () => {
  resultSearchQuery.value = ''
})

// Current active query object
const activeQueryObj = computed(() => {
  if (props.queries && props.queries.length > 0) {
    return props.queries[activeTabIndex.value] || props.queries[0]
  }
  return {
    name: 'Standard Query',
    purpose: props.purpose,
    query: props.query,
    explanation: props.explanation,
    concepts: props.concepts,
    columns: props.columns,
    rows: props.rows
  }
})

// Filtered output rows based on user typing in result search bar
const filteredRows = computed(() => {
  const allRows = activeQueryObj.value.rows || []
  if (!resultSearchQuery.value.trim()) return allRows
  
  const q = resultSearchQuery.value.toLowerCase().trim()
  return allRows.filter(row => {
    return row.some(cell => String(cell).toLowerCase().includes(q))
  })
})

const copyQuery = () => {
  const textToCopy = activeQueryObj.value.query || ''
  navigator.clipboard.writeText(textToCopy)
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
}

// Smart formatting helpers for table cells
const getInitials = (name) => {
  if (!name || typeof name !== 'string') return 'U'
  const parts = name.trim().split(' ')
  if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase()
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
}

const isStatusValue = (val) => {
  if (typeof val !== 'string') return false
  const s = val.toUpperCase()
  return ['PAID', 'CONFIRMED', 'ACTIVE', 'CHECKED_IN', 'PENDING', 'UPCOMING', 'ASSIGNED', 'LIVE NOW'].includes(s)
}

const isRoleValue = (val) => {
  if (typeof val !== 'string') return false
  return ['STUDENT', 'ORGANIZER', 'ADMIN'].includes(val.toUpperCase())
}

const isEmailValue = (val) => {
  return typeof val === 'string' && val.includes('@')
}

const isCurrencyValue = (val) => {
  return typeof val === 'string' && (val.includes('৳') || val.includes('$'))
}

const isCodeOrId = (val) => {
  if (typeof val === 'number') return true
  if (typeof val !== 'string') return false
  return val.startsWith('TRX') || (val.length >= 7 && !isNaN(val)) || ['CCC', 'CRS', 'CDS', 'CCC-C', 'CSA'].includes(val)
}

// Column-based type checking for rich UI components
const getColType = (colName, val) => {
  if (!colName) return 'default'
  const col = String(colName).toLowerCase()

  if (col.includes('name') || col.includes('leader') || col.includes('user')) {
    if (col.includes('team') && !col.includes('leader')) return 'team'
    if (col.includes('event')) return 'event'
    if (col.includes('club')) return 'club'
    if (col.includes('building') || col.includes('venue')) return 'building'
    if (col.includes('department') || col.includes('dept')) return 'department'
    return 'person'
  }

  if (col.includes('event') || col.includes('competition')) return 'event'
  if (col.includes('club')) return 'club'
  if (col.includes('building') || col.includes('venue') || col.includes('location')) return 'building'
  if (col.includes('department') || col.includes('dept')) return 'department'
  if (col.includes('date') || col.includes('shift')) return 'date'
  if (col.includes('team')) return 'team'

  return 'default'
}
</script>

<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-3 sm:p-5 overflow-y-auto">
    <div class="bg-white border border-slate-200/90 text-slate-900 w-full max-w-[96vw] xl:max-w-[94vw] rounded-3xl shadow-2xl overflow-hidden my-auto space-y-0 animate-in fade-in zoom-in-95 duration-200">
      
      <!-- Modal Header -->
      <div class="p-5 bg-gradient-to-r from-slate-900 to-slate-800 text-white flex items-center justify-between">
        <div class="flex items-center gap-3.5">
          <div class="p-3 rounded-2xl bg-blue-500/20 border border-blue-400/30 text-blue-400 shrink-0 shadow-inner">
            <Database class="w-6 h-6" />
          </div>
          <div>
            <div class="flex items-center gap-2.5">
              <h3 class="font-black text-lg sm:text-xl text-white tracking-tight">{{ title }}</h3>
              <span class="px-2.5 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 text-[11px] font-mono font-bold border border-emerald-400/30">
                MySQL 8.0 Engine
              </span>
            </div>
            <p class="text-xs text-slate-300 mt-0.5">Presentation SQL Showcase & Application Data Grid</p>
          </div>
        </div>

        <button 
          @click="emit('close')" 
          class="p-2.5 rounded-2xl text-slate-400 hover:text-white hover:bg-slate-700/60 transition-colors"
        >
          <X class="w-6 h-6" />
        </button>
      </div>

      <!-- Multiple Queries Tab Bar (If queries array provided) -->
      <div v-if="queries && queries.length > 1" class="px-6 pt-4 pb-0 bg-slate-100/80 border-b border-slate-200 flex items-center gap-2 overflow-x-auto">
        <button
          v-for="(q, idx) in queries"
          :key="idx"
          @click="activeTabIndex = idx"
          :class="[
            activeTabIndex === idx 
              ? 'bg-white text-blue-700 font-extrabold border-t-2 border-t-blue-600 border-x border-slate-200 shadow-2xs' 
              : 'text-slate-600 hover:text-slate-900 font-semibold hover:bg-slate-200/60',
            'px-4 py-2.5 rounded-t-xl text-xs transition-all flex items-center gap-2 shrink-0'
          ]"
        >
          <Layers class="w-3.5 h-3.5 text-blue-500" />
          <span>{{ q.name || `Query ${idx + 1}` }}</span>
        </button>
      </div>

      <!-- Modal Content Body -->
      <div class="p-6 space-y-5 max-h-[82vh] overflow-y-auto bg-slate-50/50">
        
        <!-- 1. What This SQL Query Does (High Level Purpose Banner) -->
        <div class="bg-white p-4 rounded-2xl border border-blue-200/80 shadow-xs space-y-3">
          <div class="flex items-center justify-between flex-wrap gap-2">
            <div class="flex items-center gap-2 text-blue-700 font-extrabold text-xs uppercase tracking-wider">
              <Info class="w-4 h-4 text-blue-600" />
              <span>What this SQL query does</span>
            </div>

            <!-- Concept Badges: JOIN, EXISTS, IN, GROUP BY, HAVING, ORDER BY -->
            <div v-if="activeQueryObj.concepts && activeQueryObj.concepts.length > 0" class="flex items-center gap-1.5 flex-wrap">
              <span 
                v-for="c in activeQueryObj.concepts" 
                :key="c"
                class="px-2 py-0.5 rounded-md bg-slate-900 text-blue-300 font-mono font-bold text-[10px] border border-slate-700 shadow-2xs"
              >
                {{ c }}
              </span>
            </div>
          </div>

          <div class="p-3.5 bg-blue-50/80 rounded-xl border border-blue-100 text-xs sm:text-sm font-semibold text-slate-800 leading-relaxed flex items-start sm:items-center gap-2.5">
            <span class="px-2 py-1 rounded-lg bg-blue-600 text-white font-black text-[11px] uppercase shrink-0 shadow-xs">
              Query Purpose
            </span>
            <span>{{ activeQueryObj.purpose }}</span>
          </div>
        </div>

        <!-- 2. SQL Query Code Block -->
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <label class="text-xs font-bold text-slate-700 uppercase tracking-wider flex items-center gap-1.5">
              <Code2 class="w-4 h-4 text-blue-600" />
              <span>Executed MySQL Query Syntax</span>
            </label>
            <button 
              @click="copyQuery" 
              class="px-3 py-1.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-blue-400 text-xs font-mono font-bold flex items-center gap-1.5 transition-all border border-slate-700 shadow-xs active:scale-95"
            >
              <Check v-if="copied" class="w-3.5 h-3.5 text-emerald-400" />
              <Copy v-else class="w-3.5 h-3.5 text-blue-400" />
              <span>{{ copied ? 'Copied SQL' : 'Copy Query' }}</span>
            </button>
          </div>

          <div class="bg-slate-950 p-4 sm:p-5 rounded-2xl border border-slate-800 font-mono text-xs text-blue-300 overflow-x-auto leading-relaxed shadow-inner">
            <pre><code>{{ activeQueryObj.query }}</code></pre>
          </div>
        </div>

        <!-- 3. Technical Relational Logic -->
        <div class="space-y-2" v-if="activeQueryObj.explanation">
          <label class="text-xs font-bold text-slate-700 uppercase tracking-wider flex items-center gap-1.5">
            <HelpCircle class="w-4 h-4 text-amber-600" />
            <span>Relational Execution & Advanced Concepts</span>
          </label>
          <div class="p-4 rounded-2xl bg-white border border-slate-200/80 text-xs text-slate-700 leading-relaxed shadow-xs">
            <p>{{ activeQueryObj.explanation }}</p>
          </div>
        </div>

        <!-- 4. Smart Query Results Output (Clean Light Theme Application Grid) -->
        <div class="space-y-3">
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <label class="text-xs font-extrabold text-slate-900 uppercase tracking-wider flex items-center gap-2">
              <Terminal class="w-4 h-4 text-emerald-600" />
              <span>Application Execution Output Grid</span>
            </label>

            <div class="flex items-center gap-3">
              <!-- Result Search Filter -->
              <div class="relative">
                <Search class="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                <input 
                  v-model="resultSearchQuery"
                  type="text"
                  placeholder="Filter output rows..."
                  class="pl-8 pr-3 py-1.5 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 w-44 font-medium transition-all shadow-xs"
                />
              </div>

              <!-- Row Count Badge -->
              <span class="px-3 py-1 rounded-xl bg-emerald-50 text-emerald-700 font-mono font-bold text-xs border border-emerald-200/80 shadow-2xs">
                {{ filteredRows.length }} / {{ (activeQueryObj.rows || []).length }} row(s)
              </span>
            </div>
          </div>

          <!-- Light Theme Application-Style Data Table -->
          <div v-if="activeQueryObj.columns && activeQueryObj.columns.length > 0 && activeQueryObj.rows && activeQueryObj.rows.length > 0" class="overflow-x-auto border border-slate-200/90 rounded-2xl bg-white shadow-xs">
            <table class="w-full text-left text-xs">
              <thead class="bg-slate-100/90 text-slate-800 font-extrabold border-b border-slate-200 tracking-wide uppercase text-[11px]">
                <tr>
                  <th class="py-3.5 px-3 w-10 text-center text-slate-400 font-mono">#</th>
                  <th v-for="col in activeQueryObj.columns" :key="col" class="py-3.5 px-4 font-black text-slate-900">{{ col }}</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100 text-slate-800 font-medium">
                <tr 
                  v-for="(row, rIdx) in filteredRows" 
                  :key="rIdx" 
                  class="hover:bg-blue-50/70 transition-all even:bg-slate-50/40"
                >
                  <!-- Row Number Index Column -->
                  <td class="py-3.5 px-3 text-center font-mono text-[11px] text-slate-400 font-semibold select-none">
                    {{ rIdx < 9 ? `0${rIdx + 1}` : rIdx + 1 }}
                  </td>

                  <!-- Cell Columns -->
                  <td v-for="(val, cIdx) in row" :key="cIdx" class="py-3.5 px-4">
                    
                    <!-- 1. Status Badges -->
                    <template v-if="isStatusValue(val)">
                      <span v-if="['PAID', 'CONFIRMED', 'ACTIVE', 'CHECKED_IN'].includes(String(val).toUpperCase())" class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 font-bold text-[11px] border border-emerald-200 shadow-2xs">
                        <CheckCircle2 class="w-3 h-3 text-emerald-600" />
                        <span>{{ val }}</span>
                      </span>
                      <span v-else-if="['PENDING', 'UPCOMING', 'ASSIGNED'].includes(String(val).toUpperCase())" class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-amber-50 text-amber-700 font-bold text-[11px] border border-amber-200 shadow-2xs">
                        <Clock class="w-3 h-3 text-amber-600" />
                        <span>{{ val }}</span>
                      </span>
                      <span v-else-if="String(val).toUpperCase() === 'LIVE NOW'" class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-rose-50 text-rose-700 font-bold text-[11px] border border-rose-200 animate-pulse">
                        <span class="w-1.5 h-1.5 rounded-full bg-rose-600"></span>
                        <span>{{ val }}</span>
                      </span>
                      <span v-else class="px-2.5 py-0.5 rounded-full bg-slate-100 text-slate-700 font-bold text-[11px] border border-slate-200">
                        {{ val }}
                      </span>
                    </template>

                    <!-- 2. Role Badges -->
                    <template v-else-if="isRoleValue(val)">
                      <span v-if="String(val).toUpperCase() === 'STUDENT'" class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-blue-50 text-blue-700 font-bold text-[11px] border border-blue-200">
                        <span>🎓 {{ val }}</span>
                      </span>
                      <span v-else-if="String(val).toUpperCase() === 'ORGANIZER'" class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-purple-50 text-purple-700 font-bold text-[11px] border border-purple-200">
                        <span>⚡ {{ val }}</span>
                      </span>
                      <span v-else-if="String(val).toUpperCase() === 'ADMIN'" class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-slate-900 text-slate-100 font-bold text-[11px] border border-slate-800">
                        <span>🛡️ {{ val }}</span>
                      </span>
                    </template>

                    <!-- 3. Person Name with Rich Avatar Image Bubble -->
                    <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'person'">
                      <div class="flex items-center gap-2.5">
                        <div class="w-6 h-6 rounded-full bg-gradient-to-tr from-blue-600 to-indigo-600 text-white flex items-center justify-center text-[10px] font-black shadow-2xs shrink-0 ring-1 ring-white">
                          {{ getInitials(val) }}
                        </div>
                        <span class="font-bold text-slate-900 text-xs">{{ val }}</span>
                      </div>
                    </template>

                    <!-- 4. Event Title with Event Icon -->
                    <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'event'">
                      <div class="flex items-center gap-2">
                        <div class="p-1 rounded-lg bg-amber-50 border border-amber-200 text-amber-600 shrink-0">
                          <Trophy class="w-3.5 h-3.5" />
                        </div>
                        <span class="font-extrabold text-slate-900 text-xs">{{ val }}</span>
                      </div>
                    </template>

                    <!-- 5. Club Name with Shield Icon -->
                    <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'club'">
                      <div class="flex items-center gap-2">
                        <div class="p-1 rounded-lg bg-blue-50 border border-blue-200 text-blue-600 shrink-0">
                          <Users class="w-3.5 h-3.5" />
                        </div>
                        <span class="font-bold text-slate-900 text-xs">{{ val }}</span>
                      </div>
                    </template>

                    <!-- 6. Venue Building with Location Icon -->
                    <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'building'">
                      <div class="flex items-center gap-2">
                        <div class="p-1 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-600 shrink-0">
                          <Building2 class="w-3.5 h-3.5" />
                        </div>
                        <span class="font-semibold text-slate-800 text-xs">{{ val }}</span>
                      </div>
                    </template>

                    <!-- 7. Department with Graduation Cap -->
                    <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'department'">
                      <div class="flex items-center gap-2">
                        <div class="p-1 rounded-lg bg-purple-50 border border-purple-200 text-purple-600 shrink-0">
                          <GraduationCap class="w-3.5 h-3.5" />
                        </div>
                        <span class="font-semibold text-slate-800 text-xs">{{ val }}</span>
                      </div>
                    </template>

                    <!-- 8. Team Name with Sparkles -->
                    <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'team'">
                      <div class="flex items-center gap-1.5 font-extrabold text-slate-900 text-xs">
                        <Sparkles class="w-3.5 h-3.5 text-indigo-500 shrink-0" />
                        <span>{{ val }}</span>
                      </div>
                    </template>

                    <!-- 9. Email Formatting -->
                    <template v-else-if="isEmailValue(val)">
                      <span class="font-mono text-xs text-blue-600 hover:text-blue-800 font-semibold inline-flex items-center gap-1">
                        <Mail class="w-3 h-3 text-blue-400" />
                        <span>{{ val }}</span>
                      </span>
                    </template>

                    <!-- 10. Currency Monetary Amounts -->
                    <template v-else-if="isCurrencyValue(val)">
                      <span class="font-mono font-extrabold text-emerald-700 text-xs bg-emerald-50/80 px-2 py-0.5 rounded-md border border-emerald-200/80 inline-block">
                        {{ val }}
                      </span>
                    </template>

                    <!-- 11. Code / ID Formatting -->
                    <template v-else-if="isCodeOrId(val)">
                      <span class="font-mono font-bold text-slate-800 bg-slate-100 px-2 py-0.5 rounded-md border border-slate-200/80 text-xs">
                        {{ val }}
                      </span>
                    </template>

                    <!-- 12. Default Text Value -->
                    <template v-else>
                      <span class="text-slate-800 font-semibold">
                        {{ val }}
                      </span>
                    </template>

                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="p-8 text-center bg-white border border-slate-200 rounded-2xl text-slate-400">
            <p class="text-xs font-semibold">No matching execution rows found for "{{ resultSearchQuery }}"</p>
          </div>
        </div>

      </div>

      <!-- Modal Footer with Execution Metrics -->
      <div class="p-4 sm:p-5 bg-white border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-500">
        <div class="flex items-center gap-4 flex-wrap">
          <div class="flex items-center gap-1.5">
            <span class="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
            <span class="font-mono font-bold text-slate-800">MySQL 8.0 InnoDB</span>
          </div>

          <div class="flex items-center gap-1 text-slate-400 font-mono text-[11px]">
            <Zap class="w-3.5 h-3.5 text-amber-500" />
            <span>Execution Latency: <strong>1.2 ms</strong></span>
          </div>
        </div>

        <button 
          @click="emit('close')" 
          class="px-6 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-extrabold text-xs shadow-md transition-all active:scale-95 w-full sm:w-auto"
        >
          Close Preview
        </button>
      </div>

    </div>
  </div>
</template>
