<script setup>
import { CheckCircle2, AlertCircle, Info, X } from 'lucide-vue-next'

const props = defineProps({
  toast: Object
})

const emit = defineEmits(['close'])
</script>

<template>
  <div
    v-if="toast"
    class="fixed bottom-6 right-6 z-50 max-w-sm w-full p-4 rounded-2xl shadow-xl border backdrop-blur-md flex items-start gap-3 transition-all duration-300 bg-white"
    :class="[
      toast.type === 'success' ? 'border-emerald-300 bg-emerald-50/90 text-emerald-900' : 'border-blue-300 bg-blue-50/90 text-blue-900'
    ]"
  >
    <CheckCircle2 v-if="toast.type === 'success'" class="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
    <Info v-else class="w-5 h-5 text-blue-600 shrink-0 mt-0.5" />

    <div class="flex-1">
      <h4 class="font-extrabold text-xs uppercase tracking-wider">{{ toast.title }}</h4>
      <p class="text-xs mt-0.5 leading-relaxed font-medium">{{ toast.message }}</p>
    </div>

    <button @click="emit('close')" class="p-1 hover:bg-black/5 rounded-lg transition-colors">
      <X class="w-4 h-4 text-slate-500" />
    </button>
  </div>
</template>
