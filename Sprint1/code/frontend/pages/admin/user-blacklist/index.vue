<template>
    <div class="min-h-screen bg-gray-50">
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6 transition-all duration-300">
            <div class="mx-auto max-w-8xl">
                <!-- Navigation & Title -->
                <div class="mb-8">
                    <NuxtLink to="/admin/users" class="inline-flex items-center gap-2 text-gray-500 hover:text-blue-600 transition-colors mb-4 font-medium">
                        <i class="fa-solid fa-arrow-left"></i>
                        <span>กลับไปหน้าจัดการผู้ใช้</span>
                    </NuxtLink>
                    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <div>
                            <h1 class="text-2xl font-bold text-gray-800 flex items-center gap-3">
                                <span class="p-2 bg-red-100 text-red-600 rounded-lg shadow-sm">
                                    <i class="fa-solid fa-user-slash"></i>
                                </span>
                                รายชื่อผู้ใช้ที่ถูกระงับ (Blacklist)
                            </h1>
                            <p class="text-gray-500 mt-1">รายการผู้ใช้ที่ไม่สามารถเข้าใช้งานระบบได้เนื่องจากทำผิดกฎ</p>
                        </div>
                        <div class="bg-white px-5 py-3 rounded-xl border border-gray-200 shadow-sm flex items-center gap-4">
                            <div class="text-right">
                                <span class="text-xs font-semibold text-gray-400 uppercase">จำนวนทั้งหมด</span>
                                <div class="text-2xl font-bold text-red-600 line-height-1">{{ blacklistedUsers.length }}</div>
                            </div>
                            <div class="h-10 w-[1px] bg-gray-100"></div>
                            <button @click="fetchBlacklisted" class="p-2 text-gray-400 hover:text-blue-600 transition-colors" title="โหลดข้อมูลใหม่">
                                <i class="fa-solid fa-rotate" :class="{ 'fa-spin': isLoading }"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Error Alert -->
                <div v-if="errorMsg" class="mb-6 p-4 bg-red-50 border-l-4 border-red-500 text-red-700 flex items-center justify-between rounded-r-lg">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-exclamation text-xl"></i>
                        <p class="font-medium">{{ errorMsg }}</p>
                    </div>
                    <button @click="fetchBlacklisted" class="text-sm underline hover:no-underline">ลองใหม่อีกครั้ง</button>
                </div>

                <!-- Table Content -->
                <div class="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden min-h-[400px]">
                    <!-- Loading State -->
                    <div v-if="isLoading" class="flex flex-col items-center justify-center p-24">
                        <div class="w-12 h-12 border-4 border-blue-100 border-t-blue-600 rounded-full animate-spin mb-4"></div>
                        <p class="text-gray-500 font-medium">กำลังดึงข้อมูลรายชื่อสีดำ...</p>
                    </div>

                    <!-- Empty State -->
                    <div v-else-if="blacklistedUsers.length === 0" class="flex flex-col items-center justify-center p-24 text-center">
                        <div class="w-20 h-20 bg-gray-50 rounded-full flex items-center justify-center mb-6">
                            <i class="fa-solid fa-user-check text-4xl text-gray-300"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900 mb-2">ไม่พบรายชื่อที่ถูกระงับ</h3>
                        <p class="text-gray-500 max-w-xs mx-auto">ขณะนี้ไม่มีผู้ใช้งานรายใดถูกใส่ชื่อใน Blacklist ระบบทำงานเป็นปกติ</p>
                    </div>

                    <!-- Data Table -->
                    <div v-else class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-100">
                            <thead>
                                <tr class="bg-gray-50/50">
                                    <th class="px-6 py-4 text-left text-[11px] font-bold text-gray-400 uppercase tracking-widest">ผู้ใช้งาน</th>
                                    <th class="px-6 py-4 text-left text-[11px] font-bold text-gray-400 uppercase tracking-widest">เหตุผล/หมายเหตุ</th>
                                    <th class="px-6 py-4 text-left text-[11px] font-bold text-gray-400 uppercase tracking-widest">ระงับเมื่อ</th>
                                    <th class="px-6 py-4 text-right text-[11px] font-bold text-gray-400 uppercase tracking-widest">การจัดการ</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-50">
                                <tr v-for="user in blacklistedUsers" :key="user.id" class="hover:bg-red-50/20 transition-colors group">
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-3">
                                            <div class="relative">
                                                <img :src="user.profilePicture || `https://ui-avatars.com/api/?name=${encodeURIComponent(user.username || 'U')}&background=fecaca&color=dc2626`" 
                                                     class="w-11 h-11 rounded-full border border-gray-100 object-cover shadow-sm" />
                                                <div class="absolute -bottom-1 -right-1 bg-red-500 text-white text-[8px] px-1 rounded-full border border-white">BLOCKED</div>
                                            </div>
                                            <div>
                                                <div class="text-sm font-bold text-gray-900 group-hover:text-red-700 transition-colors">
                                                    {{ user.firstName }} {{ user.lastName }}
                                                </div>
                                                <div class="text-xs text-gray-400">{{ user.email || user.username }}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="inline-flex items-start gap-2 max-w-xs">
                                            <i class="fa-solid fa-comment-dots text-gray-300 mt-1"></i>
                                            <span class="text-sm text-gray-600 italic">
                                                {{ user.blacklistReason || 'ไม่มีการระบุเหตุผล' }}
                                            </span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-sm text-gray-500">
                                            {{ formatDate(user.updatedAt || user.createdAt) }}
                                        </div>
                                        <div class="text-[10px] text-gray-300 uppercase font-bold mt-0.5">Thai Buddhist Era</div>
                                    </td>
                                    <td class="px-6 py-4 text-right whitespace-nowrap">
                                        <button @click="onUnblacklist(user)" 
                                                class="inline-flex items-center gap-2 px-4 py-2 bg-white border border-green-500 text-green-600 text-sm font-bold rounded-lg hover:bg-green-500 hover:text-white transition-all shadow-sm active:scale-95">
                                            <i class="fa-solid fa-user-check"></i>
                                            ปลดระงับ
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>

        <!-- Action Loading Overlay -->
        <div v-if="isActionLoading" class="fixed inset-0 bg-gray-900/40 backdrop-blur-[2px] z-[9999] flex items-center justify-center p-4">
            <div class="bg-white px-8 py-6 rounded-2xl shadow-2xl flex flex-col items-center gap-4 max-w-xs w-full">
                <div class="w-10 h-10 border-4 border-blue-100 border-t-blue-600 rounded-full animate-spin"></div>
                <div class="text-center">
                    <h4 class="font-bold text-gray-900">กำลังดำเนินการ</h4>
                    <p class="text-sm text-gray-500 mt-1">โปรดรอสักครู่ ระบบกำลังปลดระงับผู้ใช้งาน...</p>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import { useToast } from '~/composables/useToast'

dayjs.locale('th')
dayjs.extend(buddhistEra)

const { toast } = useToast()
const config = useRuntimeConfig()

// States
const isLoading = ref(true)
const isActionLoading = ref(false)
const blacklistedUsers = ref([])
const errorMsg = ref('')

async function fetchBlacklisted() {
    isLoading.value = true
    errorMsg.value = ''
    const token = useCookie('token').value
    
    try {
        // ลองดึงข้อมูลผู้ใช้ที่ติด Blacklist
        let res = null
        
        // วิธีที่ 1: ดึงแบบ isBlacklisted: true
        try {
            res = await $fetch('/users/admin', {
                baseURL: config.public.apiBase,
                headers: { Authorization: `Bearer ${token}` },
                query: {
                    isBlacklisted: 'true',
                    limit: 100
                }
            })
        } catch (err1) {
            console.warn('Method 1 (isBlacklisted) failed, trying isActive=false...')
            // วิธีที่ 2: ดึงแบบ isActive: false (เนื่องจาก blacklist จะ set isActive=false)
            try {
                res = await $fetch('/users/admin', {
                    baseURL: config.public.apiBase,
                    headers: { Authorization: `Bearer ${token}` },
                    query: {
                        isActive: 'false',
                        limit: 100
                    }
                })
            } catch (err2) {
                console.error('Both methods failed:', err1, err2)
                throw err1 // throw original error
            }
        }

        // จุดสำคัญ: ตรวจสอบโครงสร้างข้อมูล
        let rawData = []
        if (Array.isArray(res)) {
            rawData = res
        } else if (res && res.data && Array.isArray(res.data)) {
            rawData = res.data
        } else if (res && res.data && typeof res.data === 'object' && !Array.isArray(res.data)) {
            if (res.data.items && Array.isArray(res.data.items)) {
                rawData = res.data.items
            } else if (res.data.users && Array.isArray(res.data.users)) {
                rawData = res.data.users
            }
        } else if (res && res.items && Array.isArray(res.items)) {
            rawData = res.items
        } else if (res && res.users && Array.isArray(res.users)) {
            rawData = res.users
        }

        // กรองเฉพาะคนที่โดนแบนจริงๆ (isBlacklisted = true หรือ isActive = false ที่มี blacklistReason)
        blacklistedUsers.value = rawData.filter(u => 
            (u.isBlacklisted === true || u.isBlacklisted === 'true' || u.isBlacklisted === 1) ||
            (u.isActive === false && u.blacklistReason) // คนที่ inactive และมี blacklistReason
        ).sort((a, b) => new Date(b.updatedAt || b.createdAt) - new Date(a.updatedAt || a.createdAt))

        console.log('API Response:', res)
        console.log('Raw Data after extraction:', rawData)
        console.log('Final Blacklist Data:', blacklistedUsers.value)

    } catch (err) {
        console.error('Fetch error:', err)
        errorMsg.value = err.data?.message || 'ไม่สามารถโหลดรายชื่อได้ กรุณาตรวจสอบการเชื่อมต่อ API'
        toast.error('โหลดข้อมูลล้มเหลว', errorMsg.value)
    } finally {
        isLoading.value = false
    }
}

async function onUnblacklist(user) {
    // ใช้ confirm พื้นฐาน หรือ Modal ถ้าคุณมี
    const confirmed = window.confirm(`ยืนยันการปลดระงับผู้ใช้: ${user.firstName} ${user.lastName}?`)
    if (!confirmed) return

    isActionLoading.value = true
    const token = useCookie('token').value
    
    try {
        await $fetch(`/users/admin/${user.id}/status`, {
            baseURL: config.public.apiBase,
            method: 'PATCH',
            headers: { Authorization: `Bearer ${token}` },
            body: { 
                isBlacklisted: false,
                isActive: true, // ปลดแล้วให้เปิดใช้งานอัตโนมัติ
                blacklistReason: null
            }
        })

        toast.success('สำเร็จ', `ปลดระงับ ${user.username} เรียบร้อยแล้ว`)
        // Refresh รายชื่อใหม่
        await fetchBlacklisted()
    } catch (err) {
        console.error('Update error:', err)
        toast.error('ผิดพลาด', err?.data?.message || 'ไม่สามารถปลดระงับได้ในขณะนี้')
    } finally {
        isActionLoading.value = false
    }
}

function formatDate(date) {
    if (!date) return '-'
    return dayjs(date).format('D MMM BBBB')
}

onMounted(() => {
    fetchBlacklisted()
})

useHead({
    title: 'Blacklist Management | Admin',
    link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})
</script>

<style scoped>
.main-content {
    min-height: calc(100vh - 64px);
    background-image: radial-gradient(#e5e7eb 1px, transparent 1px);
    background-size: 20px 20px;
}
</style>