import { useCookie } from '#app'
import { useRouter } from 'vue-router'
import { watch } from 'vue'

export function useAuth() {
  const { $api } = useNuxtApp()

  const cookieOpts = {
    maxAge: 60 * 60 * 24 * 7,
    path: '/',
    sameSite: 'lax',
    secure: false,  // ตั้งเป็น false ก่อน (ถ้า HTTPS ให้เปลี่ยนเป็น true)
    domain: '.cpkku.com'  // ลอง uncomment ถ้า cookie ยังไม่ work
  }
  const token = useCookie('token', cookieOpts)
  const user = useCookie('user', cookieOpts)
  
  // Debug: log token เพื่อตรวจสอบ
  if (process.client) {
    watch(() => token.value, (newVal) => {
      console.log('[useAuth] token updated:', !!newVal)
    })
  }
  // const token = useCookie('token', { maxAge: 60 * 60 * 24 * 7, secure: true })
  // const user = useCookie('user', { maxAge: 60 * 60 * 24 * 7, secure: true })
  const router = useRouter()

  const login = async (identifier, password) => {
    const payload = { password }
    if (identifier.includes('@')) {
      payload.email = identifier
    } else {
      payload.username = identifier
    }

    const res = await $api('/auth/login', {
      method: 'POST',
      body: payload
    })
    token.value = res.token
    user.value = res.user
    return res
  }

  // const register = async (email, password, firstName, lastName) => {
  //   const res = await $api('/users', {
  //     method: 'POST',
  //     body: { email, password, firstName, lastName }
  //   })
  //   return res
  // }

  const register = async (formData) => {
    const res = await $api('/users', {
      method: 'POST',
      body: formData // ส่ง FormData ไปทั้งก้อน ไม่ต้องแปลงเป็น JSON
    })
    return res
  }

  const logout = () => {
    token.value = null
    user.value = null
    return router.push('/')
  }

  return { token, user, login, logout, register }
}
