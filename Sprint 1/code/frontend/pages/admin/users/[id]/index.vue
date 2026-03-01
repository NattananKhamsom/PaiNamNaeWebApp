<template>
        <div>
            <AdminHeader />
            <AdminSidebar />

            <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
                <!-- Back -->
                <div class="mb-8">
                    <NuxtLink to="/admin/users"
                        class="inline-flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50">
                        <i class="fa-solid fa-arrow-left"></i>
                        <span>ย้อนกลับ</span>
                    </NuxtLink>
                </div>

                <div class="mx-auto max-w-8xl">
                    <!-- Title -->
                    <div class="flex flex-col gap-3 mb-6 sm:flex-row sm:items-center sm:justify-between">
                        <div class="flex items-center gap-3">
                            <h1 class="text-2xl font-semibold text-gray-800">รายละเอียดผู้ใช้</h1>
                            <span v-if="user?.isBlacklisted" class="px-2 py-1 text-xs font-bold text-white bg-red-600 rounded animate-pulse">BLACKLISTED</span>
                            <span v-else class="text-sm text-gray-500">ดูข้อมูลทั้งหมดของผู้ใช้งาน</span>
                        </div>

                        <!-- Verify switch -->
                        <div v-if="user" class="flex items-center gap-4">
                            <div class="flex items-center gap-2">
                                <label class="inline-flex items-center cursor-pointer select-none switch">
                                    <input type="checkbox" class="switch-input" :checked="user.isVerified"
                                        :disabled="isLoading || toggling || user.isBlacklisted" @change="onToggleVerify($event.target.checked)" />
                                    <span class="switch-slider"></span>
                                </label>
                                <span class="text-sm" :class="user.isVerified ? 'text-green-700' : 'text-gray-500'">
                                    {{ user.isVerified ? 'Verified' : 'Unverified' }}
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
                        <!-- Left: Main User Info (2/3) -->
                        <div class="space-y-6 lg:col-span-2">
                            <!-- Card Info -->
                            <div class="bg-white border border-gray-300 rounded-lg shadow-sm">
                                <div class="px-4 py-4 border-b border-gray-200 sm:px-6">
                                    <h2 class="font-medium text-gray-800">ข้อมูลส่วนบุคคล</h2>
                                </div>

                                <div v-if="isLoading" class="p-8 text-center text-gray-500">กำลังโหลดข้อมูล...</div>
                                <div v-else-if="loadError" class="p-8 text-center text-red-600">{{ loadError }}</div>

                                <div v-else class="p-4 sm:p-6 text-[15px]">
                                    <div class="w-full space-y-6">
                                        <!-- ข้อมูลพื้นฐาน -->
                                        <section>
                                            <h3 class="mb-3 text-sm font-semibold text-gray-700 border-l-4 border-blue-500 pl-2">บัญชีและข้อมูลติดต่อ</h3>
                                            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                                                <div>
                                                    <label class="block mb-1 text-xs font-medium text-gray-600">อีเมล</label>
                                                    <div class="w-full px-3 py-2.5 border border-gray-300 rounded-md bg-gray-50 text-gray-900">
                                                        {{ user.email }}
                                                    </div>
                                                </div>
                                                <div>
                                                    <label class="block mb-1 text-xs font-medium text-gray-600">ชื่อผู้ใช้ (username)</label>
                                                    <div class="w-full px-3 py-2.5 border border-gray-300 rounded-md bg-gray-50 text-gray-900">
                                                        {{ user.username }}
                                                    </div>
                                                </div>
                                                <div>
                                                    <label class="block mb-1 text-xs font-medium text-gray-600">เบอร์โทรศัพท์</label>
                                                    <div class="w-full px-3 py-2.5 border border-gray-300 rounded-md bg-gray-50 text-gray-900" :class="{'text-red-600 font-bold': user.isBlacklisted}">
                                                        {{ user.phoneNumber || '-' }}
                                                    </div>
                                                </div>
                                                <div>
                                                    <label class="block mb-1 text-xs font-medium text-gray-600">บทบาท</label>
                                                    <div class="w-full px-3 py-2.5 border border-gray-300 rounded-md bg-gray-50 text-gray-900">
                                                        {{ user.role }}
                                                    </div>
                                                </div>
                                            </div>
                                        </section>

                                        <!-- บัตรประชาชน -->
                                        <section>
                                            <h3 class="mb-3 text-sm font-semibold text-gray-700 border-l-4 border-blue-500 pl-2">หลักฐานการยืนยันตัวตน</h3>
                                            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                                                <div>
                                                    <label class="block mb-1 text-xs font-medium text-gray-600">เลขบัตรประชาชน</label>
                                                    <div class="w-full px-3 py-2.5 border border-gray-300 rounded-md bg-gray-50 text-gray-900" :class="{'text-red-600 font-bold': user.isBlacklisted}">
                                                        {{ user.nationalIdNumber || '-' }}
                                                    </div>
                                                </div>
                                                <div>
                                                    <label class="block mb-1 text-xs font-medium text-gray-600">ชื่อ-นามสกุลจริง</label>
                                                    <div class="w-full px-3 py-2.5 border border-gray-300 rounded-md bg-gray-50 text-gray-900">
                                                        {{ user.firstName }} {{ user.lastName }}
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="grid grid-cols-1 gap-6 mt-4 sm:grid-cols-2">
                                                <div>
                                                    <label class="block mb-1 text-xs font-medium text-gray-600">รูปบัตรประชาชน</label>
                                                    <div class="p-4 text-center border-2 border-gray-300 border-dashed rounded-md bg-gray-50">
                                                        <template v-if="user.nationalIdPhotoUrl">
                                                            <div class="flex items-center justify-center">
                                                                <img :src="user.nationalIdPhotoUrl" alt="National ID" class="rounded max-h-48" />
                                                            </div>
                                                        </template>
                                                        <div v-else class="text-gray-400 py-4 italic text-sm">ไม่มีรูป</div>
                                                    </div>
                                                </div>
                                                <div>
                                                    <label class="block mb-1 text-xs font-medium text-gray-600">รูป Selfie</label>
                                                    <div class="p-4 text-center border-2 border-gray-300 border-dashed rounded-md bg-gray-50">
                                                        <template v-if="user.selfiePhotoUrl">
                                                            <div class="flex items-center justify-center">
                                                                <img :src="user.selfiePhotoUrl" alt="Selfie" class="rounded max-h-48" />
                                                            </div>
                                                        </template>
                                                        <div v-else class="text-gray-400 py-4 italic text-sm">ไม่มีรูป</div>
                                                    </div>
                                                </div>
                                            </div>
                                        </section>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Right: Blacklist & Admin Control (1/3) -->
                        <div class="space-y-6">
                            <!-- Blacklist Control -->
                            <div class="bg-white border rounded-lg shadow-sm overflow-hidden" :class="user?.isBlacklisted ? 'border-red-300' : 'border-gray-300'">
                                <div class="px-4 py-4 sm:px-6 flex items-center justify-between" :class="user?.isBlacklisted ? 'bg-red-50' : 'bg-gray-50'">
                                    <h2 class="font-bold" :class="user?.isBlacklisted ? 'text-red-800' : 'text-gray-800'">
                                        <i class="fa-solid fa-user-shield mr-1"></i> ควบคุมความปลอดภัย
                                    </h2>
                                </div>
                                
                                <div class="p-4 sm:p-6 space-y-5">
                                    <!-- สถานะ Blacklist ปัจจุบัน -->
                                    <div v-if="user?.isBlacklisted" class="space-y-4">
                                        <div class="p-4 rounded-md bg-red-100 border border-red-200 text-red-800">
                                            <p class="font-bold flex items-center gap-2 mb-2">
                                                <i class="fa-solid fa-user-slash"></i> บัญชีนี้ถูกระงับ (Blacklisted)
                                            </p>
                                            <p class="text-sm bg-white p-2 rounded border border-red-100 italic">
                                                "{{ user.blacklistReason || 'ไม่ระบุเหตุผล' }}"
                                            </p>
                                            <p class="text-[11px] mt-2 opacity-75">
                                                * ข้อมูลเลขบัตรประชาชนและเบอร์โทรศัพท์ถูกล็อกในระบบป้องกันการสมัครใหม่
                                            </p>
                                        </div>
                                        <button @click="unblacklistUser" class="w-full px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded hover:bg-gray-50 transition-colors">
                                            ยกเลิกการระงับบัญชี
                                        </button>
                                    </div>

                                    <!-- ฟอร์ม Blacklist (ถ้ายังไม่โดน) -->
                                    <div v-else class="space-y-4">
                                        <div class="text-sm text-gray-600 leading-relaxed">
                                            <p>ระงับบัญชีผู้ใช้ถาวรเมื่อพบพฤติกรรมร้ายแรง ระบบจะเก็บข้อมูล <b>ID Card</b> และ <b>Phone No.</b> ไว้เพื่อบล็อกการเข้าถึงในอนาคต</p>
                                        </div>

                                        <div>
                                            <label class="block mb-1.5 text-xs font-semibold text-gray-700">ระบุพฤติกรรมที่ทำผิดกฎ <span class="text-red-500">*</span></label>
                                            <select v-model="blacklistCategory" class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md mb-2">
                                                <option value="">-- เลือกประเภทความผิด --</option>
                                                <option value="FRAUD">ฉ้อโกง / เก็บค่าโดยสารเกินจริง</option>
                                                <option value="DANGEROUS_DRIVING">ขับรถอันตราย / ไม่ปฏิบัติตามกฎจราจร</option>
                                                <option value="HARASSMENT">คุกคาม / ใช้คำพูดไม่สุภาพ</option>
                                                <option value="CANCEL_TRIP">ยกเลิกทริปบ่อยครั้งโดยไม่มีเหตุผล</option>
                                                <option value="OTHER">อื่นๆ (ระบุเพิ่มเติมด้านล่าง)</option>
                                            </select>
                                            <textarea v-model="blacklistReason" rows="4" 
                                                class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:ring-2 focus:ring-red-500 focus:border-red-500" 
                                                placeholder="รายละเอียดพฤติกรรมหรือหลักฐานการทำผิด..."></textarea>
                                        </div>

                                        <button 
                                            @click="confirmBlacklist" 
                                            :disabled="!blacklistReason || !blacklistCategory || toggling"
                                            class="w-full px-4 py-3 text-white font-bold rounded-md bg-red-600 hover:bg-red-700 transition-all shadow-sm disabled:bg-gray-300 disabled:cursor-not-allowed"
                                        >
                                            <i class="fa-solid fa-user-xmark mr-1"></i> ลงโทษ Blacklist
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Notification Section -->
                            <div class="bg-white border border-gray-300 rounded-lg shadow-sm">
                                <div class="px-4 py-4 border-b border-gray-200 sm:px-6">
                                    <h2 class="font-medium text-gray-800">ส่งการแจ้งเตือน</h2>
                                </div>
                                <div class="p-4 sm:p-6 space-y-4">
                                    <select v-model="presetKey" @change="applyPreset"
                                        class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md">
                                        <option value="">-- เลือกข้อความ --</option>
                                        <option value="VERIFY_FAIL_DOC">เอกสารไม่ชัดเจน</option>
                                        <option value="VERIFY_APPROVED">ยืนยันตัวตนสำเร็จ</option>
                                        <option value="CUSTOM">กำหนดเอง</option>
                                    </select>
                                    <textarea v-if="presetKey" v-model="customBody" rows="2" class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md"></textarea>
                                    <button @click="sendNotification" :disabled="sending || !currentBody"
                                        class="w-full px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700 text-sm font-medium disabled:opacity-50">
                                        ส่งข้อความ
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
    import { useToast } from '~/composables/useToast'

    dayjs.locale('th')
    definePageMeta({ middleware: ['admin-auth'] })
    
    const route = useRoute()
    const { toast } = useToast()

    const isLoading = ref(true)
    const loadError = ref('')
    const toggling = ref(false)
    const user = ref(null)

    // Blacklist State
    const blacklistCategory = ref('')
    const blacklistReason = ref('')

    // Notification State
    const sending = ref(false)
    const presetKey = ref('')
    const customBody = ref('')

    const BODY_PRESETS = {
        VERIFY_FAIL_DOC: 'ข้อมูลยืนยันตัวตนไม่ชัดเจน กรุณาอัปโหลดใหม่',
        VERIFY_APPROVED: 'ยินดีด้วย! บัญชีของคุณได้รับการยืนยันแล้ว',
    }

    const currentBody = computed(() => {
        if (presetKey.value === 'CUSTOM') return customBody.value
        return BODY_PRESETS[presetKey.value] || ''
    })

    function applyPreset() {
        if (presetKey.value !== 'CUSTOM') customBody.value = BODY_PRESETS[presetKey.value]
    }

    async function fetchUser() {
        isLoading.value = true
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
            loadError.value = 'ไม่สามารถโหลดข้อมูลผู้ใช้ได้'
        } finally {
            isLoading.value = false
        }
    }

    async function confirmBlacklist() {
        if (!confirm(`คุณต้องการระงับบัญชีคุณ ${user.value.firstName} ถาวรใช่หรือไม่?`)) return
        toggling.value = true
        try {
            // จำลองการเรียก API (ในระบบจริงจะส่งเหตุผลไปเก็บด้วย)
            await new Promise(r => setTimeout(r, 800))
            
            user.value.isBlacklisted = true
            user.value.blacklistReason = `[${blacklistCategory.value}] ${blacklistReason.value}`
            user.value.isVerified = false // โดน blacklist ต้องโดนถอด verify ทันที
            
            toast.success('Blacklist สำเร็จ', 'บัญชีนี้จะไม่สามารถใช้งานหรือสมัครใหม่ได้')
        } catch (err) {
            toast.error('เกิดข้อผิดพลาด', 'ไม่สามารถดำเนินการได้')
        } finally {
            toggling.value = false
        }
    }

    async function unblacklistUser() {
        if (!confirm('ยืนยันการคืนสถานะบัญชี?')) return
        user.value.isBlacklisted = false
        user.value.blacklistReason = ''
        toast.success('คืนสถานะสำเร็จ')
    }

    async function onToggleVerify(next) {
        if (user.value.isBlacklisted) return
        user.value.isVerified = next
        toast.success('อัปเดตสถานะการยืนยันแล้ว')
    }

    async function sendNotification() {
        sending.value = true
        await new Promise(r => setTimeout(r, 500))
        toast.success('ส่งข้อความเรียบร้อย')
        sending.value = false
        presetKey.value = ''
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