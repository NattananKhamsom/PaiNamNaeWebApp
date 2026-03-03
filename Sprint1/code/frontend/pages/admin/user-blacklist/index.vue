<template>
  <div class="min-h-screen bg-gray-50">
    <AdminHeader />
    <AdminSidebar />

    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6 transition-all duration-300">
      <div class="mx-auto max-w-7xl">
        <!-- Header Section -->
        <div class="mb-8 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <nav class="flex mb-4" aria-label="Breadcrumb">
              <ol class="inline-flex items-center space-x-1 md:space-x-3">
                <li class="inline-flex items-center">
                  <NuxtLink to="/admin/users" class="text-sm font-medium text-gray-500 hover:text-blue-600">
                    <i class="fa-solid fa-users mr-2"></i> User Management
                  </NuxtLink>
                </li>
                <li aria-current="page">
                  <div class="flex items-center">
                    <i class="fa-solid fa-chevron-right text-gray-300 text-xs mx-2"></i>
                    <span class="text-sm font-medium text-red-600">Blacklist</span>
                  </div>
                </li>
              </ol>
            </nav>
            <h1 class="text-3xl font-extrabold text-gray-900 flex items-center gap-3">
              <i class="fa-solid fa-user-slash text-red-500"></i>
              รายชื่อผู้ใช้ที่ถูกระงับ
            </h1>
            <p class="mt-2 text-sm text-gray-600">จัดการรายชื่อผู้ใช้ที่ถูกใส่ใน Blacklist หรือถูกระงับการใช้งานถาวร</p>
          </div>

          <div class="flex items-center gap-3">
            <button @click="fetchBlacklistedUsers" 
                    class="p-2.5 bg-white border border-gray-200 rounded-lg text-gray-600 hover:bg-gray-50 transition-all shadow-sm disabled:opacity-50"
                    :disabled="isLoading">
              <i class="fa-solid fa-rotate" :class="{ 'fa-spin': isLoading }"></i>
            </button>
          </div>
        </div>

        <!-- Stats Card -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div class="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-gray-500 uppercase tracking-wider">Total Blacklisted</p>
                <h3 class="text-3xl font-bold text-red-600 mt-1">{{ blacklistedUsers.length }}</h3>
              </div>
              <div class="p-3 bg-red-50 text-red-500 rounded-xl text-2xl">
                <i class="fa-solid fa-shield-halved"></i>
              </div>
            </div>
          </div>
        </div>

        <!-- Main Table -->
        <div class="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden min-h-[400px]">
          <div v-if="isLoading" class="p-20 text-center">
            <div class="inline-block animate-spin rounded-full h-12 w-12 border-4 border-blue-500 border-t-transparent mb-4"></div>
            <p class="text-gray-500 font-medium">กำลังโหลดข้อมูล...</p>
          </div>

          <div v-else-if="blacklistedUsers.length === 0" class="p-20 text-center">
            <div class="w-20 h-20 bg-gray-50 rounded-full flex items-center justify-center mx-auto mb-6">
              <i class="fa-solid fa-user-check text-4xl text-gray-300"></i>
            </div>
            <h3 class="text-xl font-bold text-gray-900">ไม่พบรายชื่อที่ถูกระงับ</h3>
            <p class="text-gray-500 mt-2">ขณะนี้ไม่มีผู้ใช้งานรายใดอยู่ในระบบ Blacklist</p>
          </div>

          <div v-else class="overflow-x-auto">
            <table class="w-full text-left">
              <thead>
                <tr class="bg-gray-50 border-b border-gray-100">
                  <th class="px-6 py-4 text-xs font-bold text-gray-500 uppercase">User Profile</th>
                  <th class="px-6 py-4 text-xs font-bold text-gray-500 uppercase">Reason</th>
                  <th class="px-6 py-4 text-xs font-bold text-gray-500 uppercase">Blacklisted At</th>
                  <th class="px-6 py-4 text-xs font-bold text-gray-500 uppercase text-right">Actions</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                <tr v-for="user in blacklistedUsers" :key="user.id" class="hover:bg-gray-50/50 transition-colors">
                  <td class="px-6 py-4">
                    <div class="flex items-center gap-4">
                      <div class="relative">
                        <img :src="user.profilePicture || `https://ui-avatars.com/api/?name=${encodeURIComponent(user.username)}&background=fecaca&color=dc2626`" 
                             class="w-12 h-12 rounded-full border border-gray-100 object-cover shadow-sm" />
                        <span class="absolute bottom-0 right-0 block h-3 w-3 rounded-full bg-red-500 border-2 border-white"></span>
                      </div>
                      <div>
                        <div class="text-sm font-bold text-gray-900">{{ user.firstName }} {{ user.lastName }}</div>
                        <div class="text-xs text-gray-500">@{{ user.username }}</div>
                        <div class="mt-1 flex gap-1">
                          <span class="px-1.5 py-0.5 rounded text-[10px] font-bold uppercase" 
                                :class="user.role === 'DRIVER' ? 'bg-blue-100 text-blue-600' : 'bg-green-100 text-green-600'">
                            {{ user.role }}
                          </span>
                        </div>
                      </div>
                    </div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="max-w-xs">
                      <p class="text-sm text-gray-600 italic">
                        <i class="fa-solid fa-quote-left text-gray-300 mr-1 text-[10px]"></i>
                        {{ user.blacklistReason || 'ไม่ได้ระบุเหตุผล' }}
                      </p>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm text-gray-700 font-medium">{{ formatDate(user.updatedAt) }}</div>
                    <div class="text-xs text-gray-400">เวลา {{ formatTime(user.updatedAt) }}</div>
                  </td>
                  <td class="px-6 py-4 text-right">
                    <button @click="unblacklistUser(user)" 
                            class="inline-flex items-center gap-2 px-4 py-2 bg-white border border-green-500 text-green-600 text-sm font-bold rounded-xl hover:bg-green-600 hover:text-white transition-all shadow-sm active:scale-95">
                      <i class="fa-solid fa-user-check"></i>
                      ปลดจาก Blacklist
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>

    <!-- Full Screen Loading Overlay -->
    <div v-if="isProcessing" class="fixed inset-0 bg-gray-900/60 backdrop-blur-sm z-[9999] flex items-center justify-center p-4">
      <div class="bg-white p-8 rounded-3xl shadow-2xl flex flex-col items-center gap-4 max-w-sm w-full">
        <div class="relative w-16 h-16">
          <div class="absolute inset-0 border-4 border-gray-100 rounded-full"></div>
          <div class="absolute inset-0 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
        </div>
        <div class="text-center">
          <h3 class="text-lg font-bold text-gray-900">กำลังดำเนินการ</h3>
          <p class="text-sm text-gray-500 mt-1">โปรดรอสักครู่ ระบบกำลังอัปเดตสถานะผู้ใช้งาน...</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import dayjs from 'dayjs';
import 'dayjs/locale/th';
import buddhistEra from 'dayjs/plugin/buddhistEra';
import { useToast } from '~/composables/useToast';

dayjs.locale('th');
dayjs.extend(buddhistEra);

const { toast } = useToast();
const config = useRuntimeConfig();
const isLoading = ref(true);
const isProcessing = ref(false);
const blacklistedUsers = ref([]);

/**
 * ดึงข้อมูลผู้ใช้และกรองตามเงื่อนไข Blacklist (isBlacklisted หรือ isActive เป็น false พร้อมเหตุผล)
 */
async function fetchBlacklistedUsers() {
  isLoading.value = true;
  // same token resolution used across other admin pages (cookie + localStorage)
  const token = useCookie('token').value || useCookie('cookie_token').value || (process.client ? localStorage.getItem('token') : '');
  try {
    // request only blacklisted users from backend now that service supports the flag
    const res = await $fetch('/users/admin', {
      baseURL: config.public.apiBase,
      headers: token ? { Authorization: `Bearer ${token}` } : {},
      query: { limit: 100, isBlacklisted: true, sortBy: 'updatedAt', sortOrder: 'desc' }
    });

    // Extract raw data from multiple possible response formats
    let rawUsers = [];
    if (res?.data?.items) rawUsers = res.data.items;
    else if (res?.items) rawUsers = res.items;
    else if (res?.data && Array.isArray(res.data)) rawUsers = res.data;
    else if (Array.isArray(res)) rawUsers = res;

    // just sort by updatedAt since all returned should be blacklisted
    blacklistedUsers.value = rawUsers.sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));

  } catch (err) {
    console.error('Fetch error:', err);
    // show backend message if available
    const message = err?.data?.message || err?.message || 'ไม่สามารถโหลดรายชื่อ Blacklist ได้';
    toast.error('Error', message);
  } finally {
    isLoading.value = false;
  }
}

/**
 * ปลดรายชื่อออกจาก Blacklist
 */
async function unblacklistUser(user) {
  const confirmed = window.confirm(`คุณต้องการปลดระงับผู้ใช้ "${user.firstName} ${user.lastName}" ใช่หรือไม่?`);
  if (!confirmed) return;

  isProcessing.value = true;
  const token = useCookie('token').value || useCookie('cookie_token').value;

  try {
    await $fetch(`/users/admin/${user.id}`, {
      baseURL: config.public.apiBase,
      method: 'PATCH',
      headers: { Authorization: `Bearer ${token}` },
      body: {
        isBlacklisted: false,
        isActive: true,
        blacklistReason: null,
        driverSuspendedUntil: null,
        passengerSuspendedUntil: null
      }
    });

    toast.success('สำเร็จ', 'ปลดระงับผู้ใช้งานเรียบร้อยแล้ว');
    await fetchBlacklistedUsers();
  } catch (err) {
    console.error('Update error:', err);
    toast.error('ผิดพลาด', err?.data?.message || 'ไม่สามารถอัปเดตสถานะได้');
  } finally {
    isProcessing.value = false;
  }
}

function formatDate(date) {
  if (!date) return '-';
  return dayjs(date).format('D MMMM BBBB');
}

function formatTime(date) {
  if (!date) return '';
  return dayjs(date).format('HH:mm น.');
}

onMounted(() => {
  fetchBlacklistedUsers();
});

useHead({
  title: 'Blacklist Management | Admin Console',
  link: [
    { rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }
  ]
});
</script>

<style scoped>
.main-content {
  min-height: calc(100vh - 64px);
}
</style>