<template>
    <div>
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <!-- Back Button -->
            <div class="mb-6">
                <NuxtLink :to="`/admin/users/${route.params.id}`"
                    class="inline-flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors">
                    <i class="fa-solid fa-arrow-left"></i>
                    <span>ย้อนกลับไปหน้าผู้ใช้</span>
                </NuxtLink>
            </div>

            <div class="mx-auto max-w-5xl">
                <!-- Title -->
                <div class="mb-8">
                    <h1 class="text-2xl font-bold text-gray-800 flex items-center gap-3">
                        <i class="fa-solid fa-ticket text-orange-500"></i>
                        ออกใบเตือน (Ticket) — {{ userName }}
                    </h1>
                    <p class="text-sm text-gray-500 mt-1">สร้างใบเตือน ใบเหลือง หรือ ใบแดง สำหรับผู้ใช้รายนี้</p>
                </div>

                <div class="grid grid-cols-1 gap-8 lg:grid-cols-5">
                    <!-- Left: Create Ticket Form -->
                    <div class="lg:col-span-3 space-y-6">
                        <!-- Card Rules Info -->
                        <div class="bg-white border border-gray-200 rounded-xl shadow-sm p-5">
                            <h2 class="text-sm font-bold text-gray-700 mb-3 flex items-center gap-2">
                                <i class="fa-solid fa-circle-info text-blue-500"></i> กฎการออกใบเตือน
                            </h2>
                            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs">
                                <div class="p-3 rounded-lg bg-yellow-50 border border-yellow-200 text-yellow-800">
                                    <p class="font-bold mb-1"><i class="fa-solid fa-square text-yellow-400 mr-1"></i>
                                        ใบเหลือง × 1</p>
                                    <p>เตือน — ยังใช้งานได้</p>
                                </div>
                                <div class="p-3 rounded-lg bg-orange-50 border border-orange-200 text-orange-800">
                                    <p class="font-bold mb-1"><i class="fa-solid fa-square text-yellow-400 mr-1"></i>
                                        ใบเหลือง × 2</p>
                                    <p class="font-bold text-red-600">Blacklist อัตโนมัติ</p>
                                </div>
                                <div class="p-3 rounded-lg bg-red-50 border border-red-200 text-red-800">
                                    <p class="font-bold mb-1"><i class="fa-solid fa-square text-red-500 mr-1"></i> ใบแดง
                                        × 1</p>
                                    <p class="font-bold text-red-600">Blacklist ทันที</p>
                                </div>
                            </div>
                        </div>

                        <!-- Current Status Banner -->
                        <div v-if="user?.isBlacklisted"
                            class="p-4 rounded-xl bg-red-600 text-white flex items-center gap-3 shadow-md">
                            <i class="fa-solid fa-user-slash text-2xl"></i>
                            <div>
                                <p class="font-bold">ผู้ใช้รายนี้ถูก Blacklist แล้ว</p>
                                <p class="text-red-100 text-sm">ไม่สามารถออกใบเตือนเพิ่มเติมได้</p>
                            </div>
                        </div>

                        <!-- Warning before auto-blacklist -->
                        <div v-if="willTriggerBlacklist && !user?.isBlacklisted"
                            class="p-4 rounded-xl border-2 border-red-400 bg-red-50 text-red-800 flex items-center gap-3 animate-pulse">
                            <i class="fa-solid fa-triangle-exclamation text-2xl text-red-500"></i>
                            <div>
                                <p class="font-bold">⚠️ คำเตือน!</p>
                                <p class="text-sm" v-if="selectedCardType === 'RED'">การออก Red Card จะทำให้ผู้ใช้ถูก
                                    <b>Blacklist ทันที</b></p>
                                <p class="text-sm" v-else>ผู้ใช้มี ใบเหลือง {{ yellowCount }} ใบแล้ว
                                    การออกใบนี้จะทำให้ถูก <b>Blacklist อัตโนมัติ</b></p>
                            </div>
                        </div>

                        <!-- Create Form -->
                        <div v-if="!user?.isBlacklisted"
                            class="bg-white border border-gray-200 rounded-xl shadow-sm p-5 space-y-5">
                            <h2 class="text-sm font-bold text-gray-700 uppercase tracking-wide flex items-center gap-2">
                                <i class="fa-solid fa-plus-circle text-green-500"></i> สร้างใบเตือนใหม่
                            </h2>

                            <!-- Card Type Selection -->
                            <div>
                                <label class="block mb-2 text-xs font-bold text-gray-600 uppercase">เลือกประเภทการ์ด
                                    <span class="text-red-500">*</span></label>
                                <div class="grid grid-cols-2 gap-3">
                                    <button @click="selectedCardType = 'YELLOW'" type="button"
                                        class="relative p-4 rounded-xl border-2 transition-all text-left"
                                        :class="selectedCardType === 'YELLOW'
                                            ? 'border-yellow-400 bg-yellow-50 shadow-md ring-2 ring-yellow-300'
                                            : 'border-gray-200 bg-white hover:border-yellow-300 hover:bg-yellow-50/50'">
                                        <div class="flex items-center gap-3">
                                            <div
                                                class="w-10 h-14 rounded-md bg-yellow-400 shadow-sm flex items-center justify-center">
                                                <i class="fa-solid fa-exclamation text-white text-lg"></i>
                                            </div>
                                            <div>
                                                <p class="font-bold text-gray-800">ใบเหลือง</p>
                                                <p class="text-xs text-gray-500">ใบเตือน</p>
                                            </div>
                                        </div>
                                        <div v-if="selectedCardType === 'YELLOW'" class="absolute top-2 right-2">
                                            <i class="fa-solid fa-circle-check text-yellow-500"></i>
                                        </div>
                                    </button>

                                    <button @click="selectedCardType = 'RED'" type="button"
                                        class="relative p-4 rounded-xl border-2 transition-all text-left" :class="selectedCardType === 'RED'
                                            ? 'border-red-400 bg-red-50 shadow-md ring-2 ring-red-300'
                                            : 'border-gray-200 bg-white hover:border-red-300 hover:bg-red-50/50'">
                                        <div class="flex items-center gap-3">
                                            <div
                                                class="w-10 h-14 rounded-md bg-red-500 shadow-sm flex items-center justify-center">
                                                <i class="fa-solid fa-ban text-white text-lg"></i>
                                            </div>
                                            <div>
                                                <p class="font-bold text-gray-800">ใบแดง</p>
                                                <p class="text-xs text-gray-500">Blacklist ทันที</p>
                                            </div>
                                        </div>
                                        <div v-if="selectedCardType === 'RED'" class="absolute top-2 right-2">
                                            <i class="fa-solid fa-circle-check text-red-500"></i>
                                        </div>
                                    </button>
                                </div>
                            </div>

                            <!-- Category -->
                            <div>
                                <label class="block mb-1.5 text-xs font-bold text-gray-600 uppercase">
                                    ประเภทความผิด (ตาม Role: {{ user?.role }}) <span class="text-red-500">*</span>
                                </label>
                                <select v-model="selectedCategory"
                                    class="w-full px-3 py-2.5 text-sm border border-gray-300 rounded-md focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none">
                                    <option value="">-- เลือกประเภทความผิด --</option>
                                    <optgroup v-for="(group, role) in BLACKLIST_CATEGORIES" :key="role"
                                        :label="`หมวดหมู่ของ ${role}`" v-show="user?.role === role">
                                        <option v-for="cat in group" :key="cat.id" :value="cat.label">
                                            {{ cat.label }}
                                        </option>
                                    </optgroup>
                                    <option value="อื่นๆ">อื่นๆ (ระบุเพิ่มเติมด้านล่าง)</option>
                                </select>
                            </div>

                            <!-- Reason -->
                            <div>
                                <label class="block mb-1.5 text-xs font-bold text-gray-600 uppercase">
                                    รายละเอียดเพิ่มเติม <span class="text-red-500">*</span>
                                </label>
                                <textarea v-model="reasonText" rows="4"
                                    class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none"
                                    placeholder="ระบุพฤติกรรมหรือเลขอ้างอิงหลักฐาน..."></textarea>
                            </div>

                            <!-- Submit -->
                            <button @click="submitTicket" :disabled="!canSubmit || submitting"
                                class="w-full px-4 py-3 font-bold rounded-md transition-all shadow-md disabled:bg-gray-300 disabled:shadow-none disabled:cursor-not-allowed flex items-center justify-center gap-2"
                                :class="selectedCardType === 'RED'
                                    ? 'bg-red-600 hover:bg-red-700 text-white'
                                    : 'bg-yellow-500 hover:bg-yellow-600 text-white'">
                                <i v-if="submitting" class="fa-solid fa-circle-notch animate-spin"></i>
                                <i v-else class="fa-solid fa-paper-plane"></i>
                                {{ selectedCardType === 'RED' ? 'ออก ใบแดง (Blacklist ทันที)' : 'ออก ใบเหลือง (เตือน)'
                                }}
                            </button>
                        </div>
                    </div>

                    <!-- Right: Ticket History -->
                    <div class="lg:col-span-2 space-y-4">
                        <div class="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">
                            <div
                                class="px-4 py-4 bg-gray-50 border-b border-gray-200 flex items-center justify-between">
                                <h2 class="font-bold text-gray-700 text-sm flex items-center gap-2">
                                    <i class="fa-solid fa-clock-rotate-left text-gray-400"></i>
                                    ประวัติใบเตือน
                                </h2>
                                <span class="px-2 py-0.5 text-xs font-bold rounded-full"
                                    :class="tickets.length > 0 ? 'bg-red-100 text-red-600' : 'bg-gray-100 text-gray-500'">
                                    {{ tickets.length }} ใบ
                                </span>
                            </div>

                            <!-- Loading -->
                            <div v-if="loadingTickets" class="p-8 text-center text-gray-400">
                                <i class="fa-solid fa-circle-notch animate-spin text-xl mb-2"></i>
                                <p class="text-sm">กำลังโหลด...</p>
                            </div>

                            <!-- Empty -->
                            <div v-else-if="tickets.length === 0" class="p-8 text-center">
                                <div
                                    class="w-14 h-14 bg-green-50 rounded-full flex items-center justify-center mx-auto mb-3">
                                    <i class="fa-solid fa-check-circle text-2xl text-green-400"></i>
                                </div>
                                <p class="text-sm font-bold text-gray-700">ไม่มีประวัติใบเตือน</p>
                                <p class="text-xs text-gray-400 mt-1">ผู้ใช้ไม่เคยถูกออกใบเตือน</p>
                            </div>

                            <!-- Tickets List -->
                            <div v-else class="divide-y divide-gray-100 max-h-[500px] overflow-y-auto">
                                <div v-for="(ticket, index) in tickets" :key="ticket.id"
                                    class="p-4 hover:bg-gray-50/50 transition-colors">
                                    <div class="flex items-start gap-3">
                                        <!-- Card Icon -->
                                        <div class="w-8 h-12 rounded flex-shrink-0 flex items-center justify-center shadow-sm"
                                            :class="ticket.cardType === 'RED' ? 'bg-red-500' : 'bg-yellow-400'">
                                            <i class="text-white text-xs"
                                                :class="ticket.cardType === 'RED' ? 'fa-solid fa-ban' : 'fa-solid fa-exclamation'"></i>
                                        </div>
                                        <div class="flex-1 min-w-0">
                                            <div class="flex items-center gap-2 mb-1">
                                                <span class="text-xs font-bold px-1.5 py-0.5 rounded" :class="ticket.cardType === 'RED'
                                                    ? 'bg-red-100 text-red-700'
                                                    : 'bg-yellow-100 text-yellow-700'">
                                                    {{ ticket.cardType }} CARD #{{ tickets.length - index }}
                                                </span>
                                            </div>
                                            <p class="text-xs font-semibold text-gray-700">{{ ticket.category }}</p>
                                            <p class="text-xs text-gray-500 mt-1 italic line-clamp-2">{{ ticket.reason
                                                }}</p>
                                            <p class="text-[10px] text-gray-400 mt-2">
                                                <i class="fa-regular fa-clock mr-1"></i>
                                                {{ dayjs(ticket.createdAt).format('D MMM BBBB HH:mm น.') }}
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Summary -->
                            <div v-if="tickets.length > 0"
                                class="px-4 py-3 bg-gray-50 border-t border-gray-200 text-xs space-y-1">
                                <div class="flex justify-between">
                                    <span class="text-gray-500">ใบเหลือง:</span>
                                    <span class="font-bold text-yellow-600">{{ yellowCount }}</span>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-500">ใบแดง:</span>
                                    <span class="font-bold text-red-600">{{ redCount }}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRuntimeConfig, useCookie } from '#app'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import { useToast } from '~/composables/useToast'

dayjs.extend(buddhistEra)
dayjs.locale('th')

definePageMeta({ middleware: ['admin-auth'] })

const route = useRoute()
const config = useRuntimeConfig()
const { toast } = useToast()

// State
const user = ref(null)
const tickets = ref([])
const loadingTickets = ref(true)
const submitting = ref(false)

const selectedCardType = ref('YELLOW')
const selectedCategory = ref('')
const reasonText = ref('')

// Categories (same as user detail page)
const BLACKLIST_CATEGORIES = {
    DRIVER: [
        { id: 'D1', label: 'ฉ้อโกง / เก็บค่าโดยสารเกินจริง' },
        { id: 'D2', label: 'ขับรถอันตราย / ไม่ปฏิบัติตามกฎจราจร' },
        { id: 'D3', label: 'อนาจาร / คุกคามผู้โดยสาร' },
        { id: 'D4', label: 'ใช้ยานพาหนะไม่ตรงกับที่ลงทะเบียน' },
        { id: 'D5', label: 'ปฏิเสธผู้โดยสารอย่างไร้เหตุผลบ่อยครั้ง' },
    ],
    PASSENGER: [
        { id: 'U1', label: 'ก่อกวน / ทำลายทรัพย์สินในรถ' },
        { id: 'U2', label: 'ค้างชำระค่าบริการ / เรียกแล้วไม่มา' },
        { id: 'U3', label: 'ใช้คำพูดไม่สุภาพ / ดูหมิ่นคนขับ' },
        { id: 'U4', label: 'พยายามใช้ไอดีคนอื่นเดินทาง' },
        { id: 'U5', label: 'แจ้งความเท็จ / ก่อกวนระบบ' },
    ]
}

// Computed
const userName = computed(() => {
    if (!user.value) return '...'
    return `${user.value.firstName || ''} ${user.value.lastName || ''}`.trim() || user.value.username
})

const yellowCount = computed(() => tickets.value.filter(t => t.cardType === 'YELLOW').length)
const redCount = computed(() => tickets.value.filter(t => t.cardType === 'RED').length)

const willTriggerBlacklist = computed(() => {
    if (selectedCardType.value === 'RED') return true
    if (selectedCardType.value === 'YELLOW' && yellowCount.value >= 1) return true
    return false
})

const canSubmit = computed(() => {
    return selectedCardType.value && selectedCategory.value && reasonText.value.trim()
})

// Helper
function getToken() {
    return useCookie('token')?.value || localStorage.getItem('token')
}

// Fetch user data
async function fetchUser() {
    try {
        const token = getToken()
        const res = await $fetch(`/users/admin/${route.params.id}`, {
            baseURL: config.public.apiBase,
            headers: { Authorization: `Bearer ${token}` }
        })
        user.value = res?.data || null
    } catch (err) {
        console.error('Failed to fetch user:', err)
    }
}

// Fetch tickets
async function fetchTickets() {
    loadingTickets.value = true
    try {
        const token = getToken()
        const res = await $fetch('/blacklist-tickets', {
            baseURL: config.public.apiBase,
            headers: { Authorization: `Bearer ${token}` },
            query: { userId: route.params.id }
        })
        tickets.value = res?.data || []
    } catch (err) {
        console.error('Failed to fetch tickets:', err)
        tickets.value = []
    } finally {
        loadingTickets.value = false
    }
}

// Submit ticket
async function submitTicket() {
    if (!canSubmit.value) return

    // Confirm if it will trigger blacklist
    if (willTriggerBlacklist.value) {
        const msg = selectedCardType.value === 'RED'
            ? `ยืนยันการออก ใบแดง?\nผู้ใช้จะถูก Blacklist ทันที!`
            : `ยืนยันการออก ใบเหลือง ใบที่ ${yellowCount.value + 1}?\nผู้ใช้จะถูก Blacklist อัตโนมัติ!`
        if (!confirm(msg)) return
    } else {
        if (!confirm('ยืนยันการออกใบเตือน?')) return
    }

    submitting.value = true
    try {
        const token = getToken()
        const res = await $fetch('/blacklist-tickets', {
            baseURL: config.public.apiBase,
            method: 'POST',
            headers: { Authorization: `Bearer ${token}` },
            body: {
                userId: route.params.id,
                cardType: selectedCardType.value,
                category: selectedCategory.value,
                reason: reasonText.value.trim(),
            }
        })

        if (res?.data?.shouldBlacklist) {
            toast.success('ออกใบเตือนสำเร็จ', 'ผู้ใช้ถูก Blacklist อัตโนมัติแล้ว')
        } else {
            toast.success('ออกใบเตือนสำเร็จ', 'บันทึกใบเตือนเรียบร้อยแล้ว')
        }

        // Reset form
        selectedCardType.value = 'YELLOW'
        selectedCategory.value = ''
        reasonText.value = ''

        // Refresh data
        await Promise.all([fetchUser(), fetchTickets()])
    } catch (err) {
        console.error('Failed to create ticket:', err)
        toast.error('เกิดข้อผิดพลาด', err?.data?.message || 'ไม่สามารถออกใบเตือนได้ในขณะนี้')
    } finally {
        submitting.value = false
    }
}

onMounted(async () => {
    await Promise.all([fetchUser(), fetchTickets()])
})
</script>

<style scoped>
.line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
</style>
