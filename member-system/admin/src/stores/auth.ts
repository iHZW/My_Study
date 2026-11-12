import { defineStore } from 'pinia';
import { login as loginApi } from '../api';
import { TOKEN_KEY } from '../api/request';

interface UserInfo {
  id: number;
  username: string;
  nickname: string;
  role: string;
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem(TOKEN_KEY) || '',
    user: JSON.parse(localStorage.getItem('member_admin_user') || 'null') as UserInfo | null,
  }),
  getters: {
    isLoggedIn: (state) => !!state.token,
  },
  actions: {
    async login(username: string, password: string) {
      const res = await loginApi({ username, password });
      this.token = res.token;
      this.user = res.user;
      localStorage.setItem(TOKEN_KEY, res.token);
      localStorage.setItem('member_admin_user', JSON.stringify(res.user));
    },
    logout() {
      this.token = '';
      this.user = null;
      localStorage.removeItem(TOKEN_KEY);
      localStorage.removeItem('member_admin_user');
    },
  },
});
