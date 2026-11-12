import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

// 后端服务地址：本地开发时通过代理转发 /api 请求
const SERVER_TARGET = process.env.VITE_PROXY_TARGET || 'http://127.0.0.1:3000'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
    proxy: {
      '/api': {
        target: SERVER_TARGET,
        changeOrigin: true
      },
      '/uploads': {
        target: SERVER_TARGET,
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: 'dist',
    chunkSizeWarningLimit: 1500
  }
})
