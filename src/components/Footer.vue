<script setup>
import { Sparkles, Globe, Mail, Phone, MapPin, ShieldCheck } from 'lucide-vue-next'
</script>

<template>
  <footer class="border-t border-slate-200 bg-white text-slate-600 text-xs py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-4 gap-8">
      
      <!-- Col 1: Brand Info -->
      <div class="space-y-3">
        <div class="flex items-center gap-2.5">
          <div class="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center text-white font-black text-sm shadow-sm">
            <Sparkles class="w-4 h-4" />
          </div>
          <span class="text-base font-black text-slate-900">CUET EventX</span>
        </div>
        <p class="text-slate-600 leading-relaxed text-xs">
          Official central event management and registration portal for Chittagong University of Engineering & Technology.
        </p>
        <div class="flex items-center gap-2 text-emerald-700 text-[11px] font-bold">
          <ShieldCheck class="w-4 h-4" />
          <span>Verified University System</span>
        </div>
      </div>

      <!-- Col 2: Quick Links -->
      <div class="space-y-2">
        <h4 class="font-bold text-slate-900 text-xs uppercase tracking-wider mb-3">Quick Navigation</h4>
        <ul class="space-y-2 text-xs">
          <li><a href="#" class="hover:text-blue-600 transition-colors">Explore Campus Events</a></li>
          <li><a href="#" class="hover:text-blue-600 transition-colors">Campus Venues & Live Stream</a></li>
          <li><a href="#" class="hover:text-blue-600 transition-colors">Clubs & Societies Showcase</a></li>
          <li><a href="#" class="hover:text-blue-600 transition-colors">My Registrations & E-Pass</a></li>
        </ul>
      </div>

      <!-- Col 3: Recognized Societies -->
      <div class="space-y-2">
        <h4 class="font-bold text-slate-900 text-xs uppercase tracking-wider mb-3">Recognized Societies</h4>
        <ul class="space-y-2 text-xs">
          <li><span class="text-slate-700 font-semibold">CUET Computer Club (CCC)</span></li>
          <li><span class="text-slate-700 font-semibold">IEEE CUET Student Branch</span></li>
          <li><span class="text-slate-700 font-semibold">CUET Robotics Society</span></li>
          <li><span class="text-slate-700 font-semibold">CUET Cultural Club</span></li>
        </ul>
      </div>

      <!-- Col 4: Contact & Help -->
      <div class="space-y-2">
        <h4 class="font-bold text-slate-900 text-xs uppercase tracking-wider mb-3">Contact & Support</h4>
        <ul class="space-y-2 text-xs">
          <li class="flex items-center gap-2">
            <MapPin class="w-3.5 h-3.5 text-blue-600 shrink-0" />
            <span>CUET Campus, Raozan, Chittagong-4349</span>
          </li>
          <li class="flex items-center gap-2">
            <Mail class="w-3.5 h-3.5 text-amber-600 shrink-0" />
            <span>eventx@cuet.ac.bd</span>
          </li>
          <li class="flex items-center gap-2">
            <Globe class="w-3.5 h-3.5 text-emerald-600 shrink-0" />
            <span>www.cuet.ac.bd</span>
          </li>
        </ul>
      </div>

    </div>

    <!-- Bottom copyright -->
    <div class="max-w-7xl mx-auto pt-8 mt-8 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between text-[11px] text-slate-500 gap-4">
      <p>© 2026 Chittagong University of Engineering & Technology. All rights reserved.</p>
      <p class="flex items-center gap-1 font-medium">
        <span>Engineered for CUET Campus Excellence</span>
      </p>
    </div>
  </footer>
</template>
