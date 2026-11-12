import { createRouter, createWebHistory } from 'vue-router';
import { TOKEN_KEY } from '../api/request';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('../views/login/LoginView.vue'),
      meta: { title: '登录' },
    },
    {
      path: '/',
      component: () => import('../layout/MainLayout.vue'),
      redirect: '/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('../views/dashboard/DashboardView.vue'),
          meta: { title: '数据看板', icon: 'DataAnalysis' },
        },
        {
          path: 'members',
          name: 'Members',
          component: () => import('../views/member/MemberListView.vue'),
          meta: { title: '会员管理', icon: 'User' },
        },
        {
          path: 'orders',
          name: 'Orders',
          component: () => import('../views/order/OrderListView.vue'),
          meta: { title: '消费订单', icon: 'Tickets' },
        },
        {
          path: 'coupons',
          name: 'Coupons',
          component: () => import('../views/coupon/CouponView.vue'),
          meta: { title: '优惠券', icon: 'Discount' },
        },
        {
          path: 'tags',
          name: 'Tags',
          component: () => import('../views/tag/TagView.vue'),
          meta: { title: '标签管理', icon: 'CollectionTag' },
        },
        {
          path: 'levels',
          name: 'Levels',
          component: () => import('../views/level/LevelView.vue'),
          meta: { title: '等级设置', icon: 'Medal' },
        },
      ],
    },
    { path: '/:pathMatch(.*)*', redirect: '/dashboard' },
  ],
});

router.beforeEach((to) => {
  document.title = to.meta.title ? `${to.meta.title} · 会员管理系统` : '会员管理系统';
  const token = localStorage.getItem(TOKEN_KEY);
  if (to.path !== '/login' && !token) {
    return { path: '/login', query: { redirect: to.fullPath } };
  }
  if (to.path === '/login' && token) {
    return { path: '/dashboard' };
  }
  return true;
});

export default router;
