import axios, { AxiosError, type AxiosRequestConfig } from 'axios';
import { ElMessage } from 'element-plus';
import router from '../router';

export const TOKEN_KEY = 'member_admin_token';

const request = axios.create({
  baseURL: '/api',
  timeout: 30000,
});

request.interceptors.request.use((config) => {
  const token = localStorage.getItem(TOKEN_KEY);
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

interface ApiBody<T = unknown> {
  status: string;
  errmsg: string;
  code: number;
  data: T;
}

request.interceptors.response.use(
  (response) => {
    // 文件流直接返回
    if (response.config.responseType === 'blob') {
      return response;
    }
    const body = response.data as ApiBody;
    if (body && body.status === '1') {
      return body.data;
    }
    const msg = body?.errmsg || '请求失败';
    ElMessage.error(msg);
    return Promise.reject(new Error(msg));
  },
  (error: AxiosError<ApiBody>) => {
    const status = error.response?.status;
    const msg = error.response?.data?.errmsg || error.message || '网络异常';
    if (status === 401) {
      localStorage.removeItem(TOKEN_KEY);
      if (router.currentRoute.value.path !== '/login') {
        ElMessage.warning('登录已过期，请重新登录');
        router.replace({ path: '/login', query: { redirect: router.currentRoute.value.fullPath } });
      }
    } else {
      ElMessage.error(msg);
    }
    return Promise.reject(error);
  },
);

/** 携带鉴权下载文件（Excel 导出） */
export async function downloadFile(url: string, filename: string, params?: Record<string, unknown>) {
  const response = await request.get(url, {
    params,
    responseType: 'blob',
  } as AxiosRequestConfig);
  const blob = new Blob([response.data], {
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  link.click();
  URL.revokeObjectURL(link.href);
}

export default request;
