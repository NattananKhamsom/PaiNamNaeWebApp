export default defineNuxtConfig({
  ssr: false,

  app: {
    baseURL: '/'
  },

  router: {
    options: {
      hashMode: true
    }
  },

  runtimeConfig: {
    public: {
      apiBase: 'https://myapp-backend-af5a.onrender.com/api'
    }
  },

  nitro: {
    preset: 'static'
  }
})