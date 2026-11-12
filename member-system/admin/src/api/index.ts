import request from './request';

// ---------- 认证 ----------
export const login = (data: { username: string; password: string }) =>
  request.post('/auth/login', data) as Promise<{ token: string; user: { id: number; username: string; nickname: string; role: string } }>;
export const getProfile = () => request.get('/auth/profile');

// ---------- 会员 ----------
export const getMembers = (params: Record<string, unknown>) => request.get('/members', { params });
export const getMember = (id: number) => request.get(`/members/${id}`);
export const createMember = (data: Record<string, unknown>) => request.post('/members', data);
export const updateMember = (id: number, data: Record<string, unknown>) => request.put(`/members/${id}`, data);
export const deleteMember = (id: number) => request.delete(`/members/${id}`);
export const adjustPoints = (id: number, data: { points: number; remark?: string }) =>
  request.post(`/members/${id}/points`, data);
export const rechargeMember = (id: number, data: { amount: number; remark?: string }) =>
  request.post(`/members/${id}/recharge`, data);
export const batchTag = (data: { memberIds: number[]; tagIds: number[]; mode: 'set' | 'add' | 'remove' }) =>
  request.post('/members/batch-tag', data);
export const importMembers = (file: File, mode: 'skip' | 'update') => {
  const form = new FormData();
  form.append('file', file);
  form.append('mode', mode);
  return request.post('/members/import', form, { headers: { 'Content-Type': 'multipart/form-data' } });
};

// ---------- 标签 ----------
export const getTags = () => request.get('/tags');
export const createTag = (data: Record<string, unknown>) => request.post('/tags', data);
export const updateTag = (id: number, data: Record<string, unknown>) => request.put(`/tags/${id}`, data);
export const deleteTag = (id: number) => request.delete(`/tags/${id}`);

// ---------- 等级 ----------
export const getLevels = () => request.get('/levels');
export const createLevel = (data: Record<string, unknown>) => request.post('/levels', data);
export const updateLevel = (id: number, data: Record<string, unknown>) => request.put(`/levels/${id}`, data);
export const deleteLevel = (id: number) => request.delete(`/levels/${id}`);

// ---------- 订单 ----------
export const getOrders = (params: Record<string, unknown>) => request.get('/orders', { params });
export const getOrder = (id: number) => request.get(`/orders/${id}`);
export const createOrder = (data: Record<string, unknown>) => request.post('/orders', data);

// ---------- 优惠券 ----------
export const getCouponTemplates = () => request.get('/coupons/templates');
export const createCouponTemplate = (data: Record<string, unknown>) => request.post('/coupons/templates', data);
export const updateCouponTemplate = (id: number, data: Record<string, unknown>) =>
  request.put(`/coupons/templates/${id}`, data);
export const deleteCouponTemplate = (id: number) => request.delete(`/coupons/templates/${id}`);
export const issueCoupon = (data: { templateId: number; memberIds: number[] }) => request.post('/coupons/issue', data);
export const getMemberCoupons = (params: Record<string, unknown>) => request.get('/coupons/member-coupons', { params });

// ---------- 统计 ----------
export const getOverview = () => request.get('/stats/overview');
export const getMemberTrend = (days: number) => request.get('/stats/member-trend', { params: { days } });
export const getConsumptionTrend = (days: number) => request.get('/stats/consumption-trend', { params: { days } });
export const getLevelDistribution = () => request.get('/stats/level-distribution');
export const getTagDistribution = () => request.get('/stats/tag-distribution');
export const getOrderTypeDistribution = () => request.get('/stats/order-type-distribution');
export const getTopMembers = (limit = 10) => request.get('/stats/top-members', { params: { limit } });
