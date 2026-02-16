export default defineNuxtConfig({
  ssr: false, // ปิด SSR ให้เป็น SPA

  runtimeConfig: {
    public: {
      apiBase: 'https://myapp-backend-af5a.onrender.com/api'
    }
  },

  nitro: {
    preset: 'static' // บอกให้ generate เป็น static
  }
})
