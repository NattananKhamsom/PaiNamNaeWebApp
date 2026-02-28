export default defineNuxtRouteMiddleware((to, from) => {
  if (process.server) return

  const { token } = useAuth()
  
  // ถ้าไม่มี token และ path ไม่ใช่ login → redirect ไป login
  if (!token.value && to.path !== '/login' && to.path !== '/register') {
    return navigateTo('/login')
  }
})