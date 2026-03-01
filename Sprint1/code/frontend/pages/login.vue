<template>
  <div class="min-h-[80vh] flex items-center justify-center p-4 font-sans">
    <main class="bg-white rounded-lg shadow-lg max-w-md w-full p-8 border border-gray-100">
      <h1 class="text-3xl font-bold text-blue-600 mb-6 text-center">เข้าสู่ระบบ</h1>
      
      <!-- แจ้งเตือนข้อผิดพลาดแบบ Alert Box -->
      <div v-if="errorMessage" 
           class="mb-4 p-3 rounded-md text-sm flex items-center gap-2"
           :class="errorMessage.includes('ระงับ') ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-orange-50 text-orange-700 border border-orange-200'">
        <i class="fa-solid fa-circle-exclamation"></i>
        <span>{{ errorMessage }}</span>
      </div>

      <form @submit.prevent="submit" id="loginForm">
        <!-- username / Email -->
        <div class="mb-4">
          <label for="identifier" class="block text-sm font-medium text-gray-700 mb-1">
            ชื่อผู้ใช้ หรือ อีเมล<span class="text-red-500">*</span>
          </label>
          <input type="text" id="identifier" v-model="identifier" required placeholder="กรอกชื่อผู้ใช้หรืออีเมล"
            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all" />
        </div>

        <!-- รหัสผ่าน -->
        <div class="mb-6">
          <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
            รหัสผ่าน <span class="text-red-500">*</span>
          </label>
          <input type="password" id="password" v-model="password" required minlength="6" placeholder="กรอกรหัสผ่าน"
            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all" />
        </div>

        <!-- ปุ่มเข้าสู่ระบบ -->
        <button type="submit" :disabled="isLoading"
          class="w-full py-3 bg-blue-600 text-white rounded-md font-medium hover:bg-blue-700 transition duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed">
          <span v-if="isLoading"><i class="fa-solid fa-spinner animate-spin mr-2"></i> กำลังตรวจสอบ...</span>
          <span v-else>เข้าสู่ระบบ</span>
        </button>
      </form>

      <!-- ลิงก์สมัครสมาชิก -->
      <p class="mt-6 text-center text-gray-600 text-sm">
        ยังไม่มีบัญชี? <NuxtLink to="/register" class="text-blue-600 hover:underline">สมัครสมาชิก</NuxtLink>
      </p>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
// สมมติว่าใช้ composable useAuth ที่คุณสร้างไว้
const { login } = useAuth()

const identifier = ref('')
const password = ref('')
const errorMessage = ref('')
const isLoading = ref(false)
const router = useRouter()

const submit = async () => {
  if (isLoading.value) return
  
  errorMessage.value = ''
  isLoading.value = true

  try {
    await login(identifier.value, password.value)
    router.push('/')
  } catch (e) {
    console.error('Login Error:', e)
    
    // ตรวจสอบเงื่อนไขจาก Response ของ Backend
    // หาก Backend ส่งสถานะ inactive หรือระงับมา เราจะแสดงข้อความตามต้องการ
    const errorStatus = e?.response?.status || e?.status
    const errorMsg = e?.data?.message || e?.message || ''

    if (errorStatus === 403 || errorMsg.includes('inactive') || errorMsg.includes('suspended')) {
      errorMessage.value = 'บัญชีของคุณถูกระงับการใช้งาน กรุณาติดต่อผู้ดูแลระบบ'
    } else if (errorStatus === 401) {
      errorMessage.value = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'
    } else {
      errorMessage.value = errorMsg || 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ'
    }
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped>
/* คุณสามารถเพิ่ม CSS เฉพาะส่วนได้ที่นี่ */
</style>