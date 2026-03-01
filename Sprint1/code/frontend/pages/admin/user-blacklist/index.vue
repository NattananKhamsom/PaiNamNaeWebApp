<template>
    <div class="">
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6 text-gray-800">
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
                            <i class="fa-solid fa-user-slash text-red-600"></i> รายชื่อที่ถูกระงับการใช้งาน (Blacklisted)
                        </h1>
                        <p class="text-sm text-gray-500">จัดการและตรวจสอบรายชื่อผู้ที่ถูก Blacklist ออกจากระบบ</p>
                    </div>
                </div>

                <!-- Stats Summary -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div class="bg-white p-6 rounded-xl border border-red-100 flex items-center gap-4 shadow-sm">
                        <div class="h-12 w-12 bg-red-50 rounded-lg flex items-center justify-center text-red-600">
                            <i class="fa-solid fa-users text-xl"></i>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500 font-medium">รวมผู้ถูกระงับ</p>
                            <h3 class="text-2xl font-bold">{{ blacklistedUsers.length }} คน</h3>
                        </div>
                    </div>
                </div>

                <!-- Blacklist Table -->
                <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                    <div v-if="isLoading" class="p-20 flex flex-col items-center justify-center gap-4">
                        <div class="animate-spin rounded-full h-12 w-12 border-4 border-red-600 border-t-transparent"></div>
                        <p class="text-gray-500 animate-pulse">กำลังโหลดข้อมูล...</p>
                    </div>

                    <div v-else-if="blacklistedUsers.length === 0" class="p-20 text-center">
                        <div class="bg-gray-50 h-20 w-20 rounded-full flex items-center justify-center mx-auto mb-4 text-gray-400">
                            <i class="fa-solid fa-user-check text-3xl"></i>
                        </div>
                        <h3 class="text-lg font-medium text-gray-800">ไม่พบรายชื่อผู้ถูกระงับ</h3>
                        <p class="text-gray-500 max-w-xs mx-auto mt-1">ผู้ใช้งานทุกคนในระบบมีสถานะปกติในขณะนี้</p>
                    </div>

                    <div v-else class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-gray-50 border-bottom border-gray-200">
                                    <th class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider">ผู้ใช้งาน</th>
                                    <th class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider">เหตุผล/วันที่ระงับ</th>
                                    <th class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider text-center border-x border-gray-100">สถานะ</th>
                                    <th class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider text-right">การจัดการ</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <tr v-for="user in blacklistedUsers" :key="user.id" class="hover:bg-gray-50/50 transition-colors">
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-3">
                                            <div class="h-10 w-10 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                                                <img v-if="user.profilePicture" :src="user.profilePicture" class="h-full w-full object-cover">
                                                <div v-else class="h-full w-full flex items-center justify-center bg-red-100 text-red-600 font-bold">
                                                    {{ user.username?.charAt(0).toUpperCase() }}
                                                </div>
                                            </div>
                                            <div>
                                                <div class="font-bold text-gray-900">{{ user.firstName }} {{ user.lastName }}</div>
                                                <div class="text-xs text-gray-500">@{{ user.username }}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 text-sm text-gray-600">
                                        <div class="flex flex-col">
                                            <span>ระงับโดยผู้ดูแลระบบ</span>
                                            <span class="text-xs text-gray-400 italic">อัปเดตล่าสุด: {{ new Date(user.updatedAt).toLocaleDateString('th-TH') }}</span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 text-center border-x border-gray-50">
                                        <span class="inline-flex items-center px-3 py-1 bg-red-600 text-white text-[10px] font-black rounded-md shadow-sm uppercase tracking-widest">
                                            <i class="fa-solid fa-circle-exclamation mr-1 text-[8px]"></i> Blacklisted
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-right">
                                        <button 
                                            @click="onUnblacklist(user)"
                                            class="text-sm font-semibold text-blue-600 hover:text-blue-800 transition-colors bg-blue-50 hover:bg-blue-100 px-4 py-2 rounded-lg"
                                        >
                                            <i class="fa-solid fa-user-plus mr-1"></i> ปลดระงับ
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>
</template>

<script setup>
const blacklistedUsers = ref([])
const isLoading = ref(false)
const toast = useToast()

onMounted(() => {
    fetchBlacklisted()
})

async function fetchBlacklisted() {
    isLoading.value = true
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token').value
        
        // ดึงเฉพาะคนที่ isActive: false ตาม Schema Prisma
        const res = await $fetch('/users/admin', {
            baseURL: config.public.apiBase,
            params: { isActive: false },
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
        
        // ส่งคำขอปลดล็อคโดยเซ็ต isActive กลับเป็น true
        await $fetch(`/users/admin/${user.id}/status`, {
            baseURL: config.public.apiBase,
            method: 'PATCH',
            headers: { Authorization: `Bearer ${token}` },
            body: { isActive: true }
        })
        
        // อัปเดต UI โดยลบคนที่ปลดล็อคออกทันที
        blacklistedUsers.value = blacklistedUsers.value.filter(u => u.id !== user.id)
        toast.success('Success', `ปลดระงับคุณ ${user.username} เรียบร้อยแล้ว`)
    } catch (e) {
        toast.error('Error', 'ไม่สามารถปลดระงับได้ในขณะนี้')
    }
}
</script>

<style scoped>
.main-content {
    min-height: 100vh;
    background-color: #f9fafb;
}
</style>