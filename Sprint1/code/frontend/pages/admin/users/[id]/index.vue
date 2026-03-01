<template>
    <div>
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <!-- Back Button -->
            <div class="mb-8">
                <NuxtLink to="/admin/users"
                    class="inline-flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors">
                    <i class="fa-solid fa-arrow-left"></i>
                    <span>ย้อนกลับ</span>
                </NuxtLink>
            </div>

            <div class="mx-auto max-w-8xl">
                <!-- Title Section -->
                <div class="flex flex-col gap-3 mb-6 sm:flex-row sm:items-center sm:justify-between">
                    <div class="flex items-center gap-3">
                        <h1 class="text-2xl font-semibold text-gray-800">รายละเอียดผู้ใช้</h1>
                        <span v-if="user?.isBlacklisted" class="px-2 py-1 text-xs font-bold text-white bg-red-600 rounded animate-pulse">BLACKLISTED</span>
                        <span v-else class="text-sm text-gray-500 italic">ID: {{ user?.id }}</span>
                    </div>

                    <!-- Verify switch -->
                    <div v-if="user" class="flex items-center gap-4 bg-white px-4 py-2 rounded-lg border border-gray-200">
                        <div class="flex items-center gap-2">
                            <label class="inline-flex items-center cursor-pointer select-none switch">
                                <input type="checkbox" class="switch-input" :checked="user.isVerified"
                                    :disabled="isLoading || toggling || user.isBlacklisted" @change="onToggleVerify($event.target.checked)" />
                                <span class="switch-slider"></span>
                            </label>
                            <span class="text-sm font-medium" :class="user.isVerified ? 'text-green-700' : 'text-gray-500'">
                                {{ user.isVerified ? 'Verified' : 'Unverified' }}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
                    <!-- Left Column: User Info -->
                    <div class="space-y-6 lg:col-span-2">
                        <div class="bg-white border border-gray-300 rounded-lg shadow-sm">
                            <div class="px-4 py-4 border-b border-gray-200 sm:px-6 flex justify-between items-center">
                                <h2 class="font-medium text-gray-800">ข้อมูลส่วนบุคคล ({{ user?.role }})</h2>
                                <span class="text-xs text-gray-400">อัปเดตล่าสุด: {{ dayjs(user?.updatedAt).format('DD MMM BBBB HH:mm') }}</span>
                            </div>

                            <div v-if="isLoading" class="p-12 text-center text-gray-500">
                                <i class="fa-solid fa-circle-notch animate-spin text-2xl mb-2"></i>
                                <p>กำลังโหลดข้อมูล...</p>
                            </div>
                            <div v-else-if="loadError" class="p-12 text-center text-red-600">{{ loadError }}</div>

                            <div v-else class="p-4 sm:p-6 text-[15px]">
                                <div class="w-full space-y-8">
                                    <!-- ข้อมูลพื้นฐาน -->
                                    <section>
                                        <h3 class="mb-4 text-sm font-bold text-gray-700 border-l-4 border-blue-500 pl-2 uppercase tracking-wide">บัญชีและข้อมูลติดต่อ</h3>
                                        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                                            <div>
                                                <label class="block mb-1.5 text-xs font-semibold text-gray-500 uppercase">อีเมล</label>
                                                <div class="w-full px-3 py-2.5 border border-gray-200 rounded-md bg-gray-50 text-gray-900 font-medium italic">
                                                    {{ user.email }}
                                                </div>
                                            </div>
                                            <div>
                                                <label class="block mb-1.5 text-xs font-semibold text-gray-500 uppercase">ชื่อผู้ใช้</label>
                                                <div class="w-full px-3 py-2.5 border border-gray-200 rounded-md bg-gray-50 text-gray-900">
                                                    @{{ user.username }}
                                                </div>
                                            </div>
                                            <div>
                                                <label class="block mb-1.5 text-xs font-semibold text-gray-500 uppercase">เบอร์โทรศัพท์</label>
                                                <div class="w-full px-3 py-2.5 border border-gray-200 rounded-md bg-gray-50" :class="user.isBlacklisted ? 'text-red-600 font-bold' : 'text-gray-900'">
                                                    {{ user.phoneNumber || '-' }}
                                                </div>
                                            </div>
                                            <div>
                                                <label class="block mb-1.5 text-xs font-semibold text-gray-500 uppercase">บทบาทในระบบ</label>
                                                <div class="w-full px-3 py-2.5 border border-gray-200 rounded-md bg-gray-50">
                                                    <span :class="user.role === 'DRIVER' ? 'text-purple-700' : 'text-blue-700'" class="font-bold">
                                                        {{ user.role }}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </section>

                                    <!-- หลักฐาน -->
                                    <section>
                                        <h3 class="mb-4 text-sm font-bold text-gray-700 border-l-4 border-blue-500 pl-2 uppercase tracking-wide">หลักฐานการยืนยันตัวตน</h3>
                                        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                                            <div>
                                                <label class="block mb-1.5 text-xs font-semibold text-gray-500 uppercase">เลขบัตรประชาชน</label>
                                                <div class="w-full px-3 py-2.5 border border-gray-200 rounded-md bg-gray-50" :class="user.isBlacklisted ? 'text-red-600 font-bold' : 'text-gray-900'">
                                                    {{ user.nationalIdNumber || '-' }}
                                                </div>
                                            </div>
                                            <div>
                                                <label class="block mb-1.5 text-xs font-semibold text-gray-500 uppercase">ชื่อ-นามสกุลจริง</label>
                                                <div class="w-full px-3 py-2.5 border border-gray-200 rounded-md bg-gray-50 font-medium">
                                                    {{ user.firstName }} {{ user.lastName }}
                                                </div>
                                            </div>
                                        </div>

                                        <div class="grid grid-cols-1 gap-6 mt-6 sm:grid-cols-2">
                                            <div>
                                                <label class="block mb-2 text-xs font-semibold text-gray-500 uppercase">รูปบัตรประชาชน</label>
                                                <div class="relative group cursor-zoom-in p-2 border-2 border-gray-200 border-dashed rounded-lg bg-gray-50 hover:bg-gray-100 transition-colors">
                                                    <template v-if="user.nationalIdPhotoUrl">
                                                        <img :src="user.nationalIdPhotoUrl" alt="National ID" class="rounded w-full object-cover max-h-56 shadow-sm" />
                                                    </template>
                                                    <div v-else class="py-12 text-center text-gray-400 italic text-sm">ไม่มีไฟล์รูปภาพ</div>
                                                </div>
                                            </div>
                                            <div>
                                                <label class="block mb-2 text-xs font-semibold text-gray-500 uppercase">รูป Selfie คู่บัตร</label>
                                                <div class="relative group cursor-zoom-in p-2 border-2 border-gray-200 border-dashed rounded-lg bg-gray-50 hover:bg-gray-100 transition-colors">
                                                    <template v-if="user.selfiePhotoUrl">
                                                        <img :src="user.selfiePhotoUrl" alt="Selfie" class="rounded w-full object-cover max-h-56 shadow-sm" />
                                                    </template>
                                                    <div v-else class="py-12 text-center text-gray-400 italic text-sm">ไม่มีไฟล์รูปภาพ</div>
                                                </div>
                                            </div>
                                        </div>
                                    </section>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column: Control Panel -->
                    <div class="space-y-6">
                        <!-- Blacklist Section -->
                        <div class="bg-white border rounded-lg shadow-sm overflow-hidden" :class="user?.isBlacklisted ? 'border-red-400 shadow-md' : 'border-gray-300'">
                            <div class="px-4 py-4 sm:px-6 flex items-center justify-between" :class="user?.isBlacklisted ? 'bg-red-600 text-white' : 'bg-gray-50'">
                                <h2 class="font-bold flex items-center gap-2">
                                    <i class="fa-solid fa-shield-halved"></i> การจัดการสิทธิ์การใช้งาน
                                </h2>
                            </div>
                            
                            <div class="p-4 sm:p-6 space-y-5">
                                <div v-if="user?.isBlacklisted" class="space-y-4">
                                    <div class="p-4 rounded-md bg-red-50 border border-red-200 text-red-800">
                                        <p class="font-bold flex items-center gap-2 mb-2">
                                            <i class="fa-solid fa-user-slash"></i> บัญชีนี้ถูกระงับถาวร
                                        </p>
                                        <div class="text-sm bg-white/60 p-3 rounded border border-red-100 mb-3">
                                            <span class="block text-xs font-bold text-red-600 mb-1 uppercase tracking-tighter">เหตุผล:</span>
                                            <p class="italic leading-relaxed font-medium">{{ user.blacklistReason || 'ไม่ระบุเหตุผล' }}</p>
                                        </div>
                                        <p class="text-[11px] leading-tight opacity-80">
                                            * เมื่อระงับบัญชี ระบบจะล็อกข้อมูลบัตรประชาชนและเบอร์โทรศัพท์ เพื่อป้องกันการสร้างบัญชีใหม่
                                        </p>
                                    </div>
                                    <button @click="unblacklistUser" :disabled="toggling" 
                                        class="w-full px-4 py-2.5 text-sm font-bold text-red-700 bg-white border-2 border-red-200 rounded-md hover:bg-red-50 hover:border-red-300 transition-all flex items-center justify-center gap-2">
                                        <i v-if="toggling" class="fa-solid fa-circle-notch animate-spin"></i>
                                        ยกเลิกการระงับบัญชี
                                    </button>
                                </div>

                                <div v-else class="space-y-4">
                                    <div class="text-sm text-gray-600 bg-blue-50 p-3 rounded-md border border-blue-100 flex gap-2">
                                        <i class="fa-solid fa-circle-info text-blue-500 mt-0.5"></i>
                                        <p>การ <b>Blacklist</b> จะตัดสิทธิ์การเข้าถึงทันที และบล็อกข้อมูลสำคัญของผู้ใช้ไม่ให้สมัครใหม่</p>
                                    </div>

                                    <div>
                                        <label class="block mb-1.5 text-xs font-bold text-gray-700 uppercase">ประเภทความผิด (ตาม Role: {{ user?.role }}) <span class="text-red-500">*</span></label>
                                        <select v-model="blacklistCategory" class="w-full px-3 py-2.5 text-sm border border-gray-300 rounded-md mb-3 focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none">
                                            <option value="">-- เลือกประเภทความผิด --</option>
                                            <optgroup v-for="(group, role) in BLACKLIST_CATEGORIES" :key="role" :label="`หมวดหมู่ของ ${role}`" v-show="user?.role === role">
                                                <option v-for="cat in group" :key="cat.id" :value="cat.label">
                                                    {{ cat.label }}
                                                </option>
                                            </optgroup>
                                            <option value="อื่นๆ">อื่นๆ (ระบุเพิ่มเติมด้านล่าง)</option>
                                        </select>
                                        
                                        <label class="block mb-1.5 text-xs font-bold text-gray-700 uppercase">รายละเอียดเพิ่มเติม <span class="text-red-500">*</span></label>
                                        <textarea v-model="blacklistReason" rows="4" 
                                            class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none" 
                                            placeholder="ระบุพฤติกรรมหรือเลขอ้างอิงหลักฐาน..."></textarea>
                                    </div>

                                    <button 
                                        @click="confirmBlacklist" 
                                        :disabled="!blacklistReason || !blacklistCategory || toggling"
                                        class="w-full px-4 py-3 text-white font-bold rounded-md bg-red-600 hover:bg-red-700 transition-all shadow-md disabled:bg-gray-300 disabled:shadow-none flex items-center justify-center gap-2"
                                    >
                                        <i v-if="toggling" class="fa-solid fa-circle-notch animate-spin"></i>
                                        <i v-else class="fa-solid fa-user-xmark"></i>
                                        ลงโทษ BLACKLIST ถาวร
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Communication Section -->
                        <div class="bg-white border border-gray-300 rounded-lg shadow-sm">
                            <div class="px-4 py-4 border-b border-gray-200 sm:px-6">
                                <h2 class="font-medium text-gray-800">เครื่องมือติดต่อสื่อสาร</h2>
                            </div>
                            <div class="p-4 sm:p-6 space-y-4">
                                <label class="block text-xs font-bold text-gray-600 uppercase">รูปแบบข้อความด่วน</label>
                                <select v-model="presetKey" @change="applyPreset"
                                    class="w-full px-3 py-2.5 text-sm border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 outline-none">
                                    <option value="">-- เลือกเทมเพลตข้อความ --</option>
                                    <option value="VERIFY_FAIL_DOC">เอกสารยืนยันตัวตนไม่ชัดเจน</option>
                                    <option value="VERIFY_APPROVED">ยืนยันตัวตนสำเร็จ (Welcome)</option>
                                    <option value="WARNING_BEHAVIOR">คำเตือนเรื่องพฤติกรรม</option>
                                    <option value="CUSTOM">กำหนดข้อความเอง</option>
                                </select>
                                <textarea v-if="presetKey" v-model="customBody" rows="3" 
                                    class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md font-medium text-blue-800 bg-blue-50/30"></textarea>
                                
                                <button @click="sendNotification" :disabled="sending || !currentBody"
                                    class="w-full px-4 py-2.5 text-white bg-blue-600 rounded-md hover:bg-blue-700 text-sm font-bold disabled:opacity-50 transition-colors flex items-center justify-center gap-2">
                                    <i v-if="sending" class="fa-solid fa-spinner animate-spin"></i>
                                    <i v-else class="fa-solid fa-paper-plane"></i>
                                    ส่งการแจ้งเตือน
                                </button>
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
const { toast } = useToast()

const isLoading = ref(true)
const loadError = ref('')
const toggling = ref(false)
const user = ref(null)

// Blacklist Logic by Role
const BLACKLIST_CATEGORIES = {
    DRIVER: [
        { id: 'D1', label: 'ฉ้อโกง / เก็บค่าโดยสารเกินจริง' },
        { id: 'D2', label: 'ขับรถอันตราย / ไม่ปฏิบัติตามกฎจราจร' },
        { id: 'D3', label: 'อนาจาร / คุกคามผู้โดยสาร' },
        { id: 'D4', label: 'ใช้ยานพาหนะไม่ตรงกับที่ลงทะเบียน' },
        { id: 'D5', label: 'ปฏิเสธผู้โดยสารอย่างไร้เหตุผลบ่อยครั้ง' },
    ],
    USER: [
        { id: 'U1', label: 'ก่อกวน / ทำลายทรัพย์สินในรถ' },
        { id: 'U2', label: 'ค้างชำระค่าบริการ / เรียกแล้วไม่มา' },
        { id: 'U3', label: 'ใช้คำพูดไม่สุภาพ / ดูหมิ่นคนขับ' },
        { id: 'U4', label: 'พยายามใช้ไอดีคนอื่นเดินทาง' },
        { id: 'U5', label: 'แจ้งความเท็จ / ก่อกวนระบบ' },
    ]
}

const blacklistCategory = ref('')
const blacklistReason = ref('')

// Notification State
const sending = ref(false)
const presetKey = ref('')
const customBody = ref('')

const BODY_PRESETS = {
    VERIFY_FAIL_DOC: 'ขออภัย ข้อมูลยืนยันตัวตนของคุณไม่ชัดเจนหรือไม่ถูกต้องตามระเบียบ กรุณาถ่ายรูปบัตรประชาชนและรูปเซลฟี่ใหม่อีกครั้งในเมนูตั้งค่า',
    VERIFY_APPROVED: 'ยินดีด้วย! บัญชีของคุณได้รับการตรวจสอบและยืนยันตัวตนสำเร็จแล้ว คุณสามารถเริ่มใช้งานฟีเจอร์เต็มรูปแบบได้ทันที',
    WARNING_BEHAVIOR: 'ประกาศเตือน: ระบบได้รับรายงานเกี่ยวกับพฤติกรรมที่ไม่เหมาะสมของท่าน หากยังมีการกระทำซ้ำ บัญชีอาจถูกระงับถาวร',
}

const currentBody = computed(() => {
    if (presetKey.value === 'CUSTOM') return customBody.value
    return BODY_PRESETS[presetKey.value] || ''
})

function applyPreset() {
    if (presetKey.value !== 'CUSTOM') {
        customBody.value = BODY_PRESETS[presetKey.value]
    } else {
        customBody.value = ''
    }
}

async function fetchUser() {
    isLoading.value = true
    loadError.value = ''
    try {
        const id = route.params.id
        const config = useRuntimeConfig()
        const token = useCookie('token')?.value || localStorage.getItem('token')
        
        const res = await $fetch(`/users/admin/${id}`, {
            baseURL: config.public.apiBase,
            headers: { Authorization: `Bearer ${token}` }
        })
        user.value = res?.data || null
    } catch (err) {
        console.error(err)
        loadError.value = 'ไม่สามารถโหลดข้อมูลผู้ใช้ได้ (Server Error)'
    } finally {
        isLoading.value = false
    }
}

async function confirmBlacklist() {
    const roleText = user.value.role === 'DRIVER' ? 'คนขับ' : 'ผู้โดยสาร'
    if (!confirm(`ยืนยันการระงับบัญชี ${roleText}: ${user.value.firstName} ถาวร?\nการดำเนินการนี้ไม่สามารถย้อนคืนได้โดยง่าย`)) return
    
    toggling.value = true
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token')?.value || localStorage.getItem('token')
        const fullReason = `[${blacklistCategory.value}] ${blacklistReason.value}`

        await $fetch(`/users/admin/${user.value.id}/status`, {
            baseURL: config.public.apiBase,
            method: 'PATCH',
            headers: { Authorization: `Bearer ${token}` },
            body: { 
                isBlacklisted: true,
                blacklistReason: fullReason
            }
        })
        
        // Sync UI
        user.value.isBlacklisted = true
        user.value.blacklistReason = fullReason
        user.value.isVerified = false
        
        toast.success('Blacklist สำเร็จ', 'ระบบได้ระงับการเข้าถึงและล็อกข้อมูลสำคัญเรียบร้อยแล้ว')
        
        // Clear Form
        blacklistCategory.value = ''
        blacklistReason.value = ''
    } catch (err) {
        toast.error('เกิดข้อผิดพลาด', err.data?.message || 'ไม่สามารถลงโทษได้ในขณะนี้')
    } finally {
        toggling.value = false
    }
}

async function unblacklistUser() {
    if (!confirm('ยืนยันการคืนสถานะบัญชีให้ผู้ใช้รายนี้?')) return
    
    toggling.value = true
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token')?.value || localStorage.getItem('token')

        await $fetch(`/users/admin/${user.value.id}/status`, {
            baseURL: config.public.apiBase,
            method: 'PATCH',
            headers: { Authorization: `Bearer ${token}` },
            body: { 
                isBlacklisted: false,
                blacklistReason: ''
            }
        })

        user.value.isBlacklisted = false
        user.value.blacklistReason = ''
        toast.success('คืนสถานะสำเร็จ', 'ผู้ใช้สามารถกลับเข้าใช้งานระบบได้ตามปกติแล้ว')
    } catch (err) {
        toast.error('ผิดพลาด', 'ไม่สามารถคืนสถานะได้')
    } finally {
        toggling.value = false
    }
}

async function onToggleVerify(next) {
    if (user.value.isBlacklisted) return
    
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token')?.value || localStorage.getItem('token')

        await $fetch(`/users/admin/${user.value.id}/status`, {
            baseURL: config.public.apiBase,
            method: 'PATCH',
            headers: { Authorization: `Bearer ${token}` },
            body: { isVerified: next }
        })

        user.value.isVerified = next
        toast.success('อัปเดตสถานะสำเร็จ', next ? 'ยืนยันตัวตนเรียบร้อย' : 'ยกเลิกการยืนยันแล้ว')
    } catch (err) {
        toast.error('ล้มเหลว', 'ไม่สามารถเปลี่ยนสถานะ Verify ได้')
    }
}

async function sendNotification() {
    sending.value = true
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token')?.value || localStorage.getItem('token')

        await $fetch(`/notifications/admin/send`, {
            baseURL: config.public.apiBase,
            method: 'POST',
            headers: { Authorization: `Bearer ${token}` },
            body: { 
                userId: user.value.id,
                title: 'ประกาศจากผู้ดูแลระบบ',
                body: currentBody.value
            }
        })

        toast.success('ส่งข้อความเรียบร้อย')
        presetKey.value = ''
        customBody.value = ''
    } catch (err) {
        toast.error('ผิดพลาด', 'ไม่สามารถส่งข้อความได้')
    } finally {
        sending.value = false
    }
}

onMounted(fetchUser)
</script>

<style scoped>
.switch { position: relative; width: 42px; height: 24px; }
.switch-input { appearance: none; width: 42px; height: 24px; position: relative; cursor: pointer; outline: none; }
.switch-slider { pointer-events: none; position: absolute; inset: 0; background: #e5e7eb; border-radius: 9999px; transition: background .2s ease; }
.switch-input:checked+.switch-slider { background: #22c55e; }
.switch-slider::after { content: ""; position: absolute; top: 3px; left: 3px; width: 18px; height: 18px; background: #fff; border-radius: 9999px; transition: transform .2s ease; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }
.switch-input:checked+.switch-slider::after { transform: translateX(18px); }
.switch-input:disabled+.switch-slider { opacity: 0.5; cursor: not-allowed; }
</style>