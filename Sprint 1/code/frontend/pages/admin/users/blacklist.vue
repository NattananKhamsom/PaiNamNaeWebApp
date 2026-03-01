<template>
    <div class="">
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <div class="mx-auto max-w-8xl">
                <!-- Header -->
                <div class="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <div>
                        <div class="flex items-center gap-2 text-red-600 mb-1">
                            <NuxtLink to="/admin/users" class="hover:underline flex items-center gap-1 text-gray-500 text-sm">
                                <i class="fa-solid fa-arrow-left"></i> กลับไปหน้ารวม
                            </NuxtLink>
                        </div>
                        <h1 class="text-2xl font-bold text-gray-800 flex items-center gap-2">
                            <i class="fa-solid fa-user-slash text-red-600"></i> รายชื่อที่ถูกระงับการใช้งาน
                        </h1>
                        <p class="text-sm text-gray-500">จัดการและตรวจสอบรายชื่อผู้ที่ถูก Blacklist ออกจากระบบ</p>
                    </div>
                </div>

                <!-- Stats Summary -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div class="bg-white p-6 rounded-xl border border-red-100 shadow-sm">
                        <div class="text-xs font-bold text-red-500 uppercase tracking-wider mb-1">Total Blacklisted</div>
                        <div class="text-3xl font-black text-gray-800">{{ blacklistedUsers.length }}</div>
                    </div>
                </div>

                <!-- Blacklist Table -->
                <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                    <div v-if="isLoading" class="p-12 text-center text-gray-400">
                        <i class="fa-solid fa-circle-notch fa-spin text-2xl mb-2"></i>
                        <p>กำลังโหลดข้อมูล...</p>
                    </div>

                    <table v-else class="w-full text-left text-sm">
                        <thead class="bg-gray-50 text-gray-600 font-bold uppercase text-[11px] tracking-widest">
                            <tr>
                                <th class="px-6 py-4">User Information</th>
                                <th class="px-6 py-4">Blacklist Date</th>
                                <th class="px-6 py-4">Reason Summary</th>
                                <th class="px-6 py-4 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <tr v-for="user in blacklistedUsers" :key="user.id" class="hover:bg-red-50/30 transition-colors">
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-500 font-bold">
                                            {{ user.username.charAt(0).toUpperCase() }}
                                        </div>
                                        <div>
                                            <div class="font-bold text-gray-900">{{ user.username }}</div>
                                            <div class="text-xs text-gray-500">{{ user.email }}</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-gray-600">
                                    {{ user.blacklistDate || '-' }}
                                </td>
                                <td class="px-6 py-4">
                                    <div class="max-w-xs truncate text-gray-600 italic">
                                        "{{ user.blacklistReason || 'ละเมิดกฎการใช้งานซ้ำซ้อน' }}"
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <button @click="onUnblacklist(user)" 
                                        class="px-3 py-1.5 text-xs font-bold text-green-700 bg-green-100 rounded-md hover:bg-green-200 transition-colors">
                                        ปลดระงับการใช้งาน
                                    </button>
                                </td>
                            </tr>
                            <tr v-if="!blacklistedUsers.length">
                                <td colspan="4" class="px-6 py-20 text-center">
                                    <div class="flex flex-col items-center opacity-30">
                                        <i class="fa-solid fa-user-check text-5xl mb-4"></i>
                                        <p class="text-xl">ไม่มีรายชื่อที่ถูกระงับในขณะนี้</p>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useToast } from '~/composables/useToast'
import { useRuntimeConfig, useCookie } from '#app'

const { toast } = useToast()
const blacklistedUsers = ref([])
const isLoading = ref(true)

async function fetchBlacklisted() {
    isLoading.value = true
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token').value
        
        // ดึงข้อมูลจริงจาก API โดยระบุเงื่อนไขว่าเอาเฉพาะคนที่เป็น Blacklisted
        const res = await $fetch('/users/admin', {
            baseURL: config.public.apiBase,
            params: { isBlacklisted: true },
            headers: { Authorization: `Bearer ${token}` }
        })
        
        blacklistedUsers.value = res?.data || []
    } catch (e) {
        toast.error('Error', 'ไม่สามารถโหลดรายชื่อได้จากเซิร์ฟเวอร์')
    } finally {
        isLoading.value = false
    }
}

async function onUnblacklist(user) {
    if (!confirm(`ต้องการปลดระงับผู้ใช้ "${user.username}" ใช่หรือไม่?`)) return
    
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token').value
        
        // ส่งคำขอปลดล็อคไปยัง API
        await $fetch(`/users/admin/${user.id}/status`, {
            baseURL: config.public.apiBase,
            method: 'PATCH',
            headers: { Authorization: `Bearer ${token}` },
            body: { isBlacklisted: false }
        })
        
        // อัปเดต UI โดยลบคนที่ปลดล็อคออก
        blacklistedUsers.value = blacklistedUsers.value.filter(u => u.id !== user.id)
        toast.success('ปลดระงับสำเร็จ', `ผู้ใช้ ${user.username} สามารถใช้งานได้แล้ว`)
    } catch (e) {
        toast.error('ผิดพลาด', 'ไม่สามารถดำเนินการปลดระงับได้ในขณะนี้')
    }
}

onMounted(fetchBlacklisted)
</script>