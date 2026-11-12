<template>
  <div class="page-container">
    <el-card class="filter-card" shadow="never">
      <el-form inline @submit.prevent>
        <el-form-item label="关键词">
          <el-input v-model="query.keyword" placeholder="订单号 / 会员姓名 / 手机号" clearable style="width: 240px" @keyup.enter="onSearch" />
        </el-form-item>
        <el-form-item label="订单类型">
          <el-select v-model="query.type" placeholder="全部" clearable style="width: 120px" @change="onSearch">
            <el-option label="堂食" :value="1" />
            <el-option label="外卖" :value="2" />
            <el-option label="零售" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="消费时间">
          <el-date-picker v-model="dateRange" type="daterange" value-format="YYYY-MM-DD" start-placeholder="开始" end-placeholder="结束" style="width: 240px" @change="onSearch" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="onSearch">查询</el-button>
          <el-button :icon="Refresh" @click="onReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="table-card" shadow="never">
      <div class="toolbar">
        <el-button type="primary" :icon="Plus" @click="openCreate">录入消费订单</el-button>
        <span class="text-muted">下单自动执行：等级折扣 → 优惠券 → 积分抵扣 → 赠送积分 → 自动升级</span>
      </div>
      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column prop="orderNo" label="订单号" width="160" />
        <el-table-column label="会员" min-width="110">
          <template #default="{ row }">
            <div>{{ row.member?.name || '—' }}</div>
            <div class="text-muted">{{ row.member?.phone }}</div>
          </template>
        </el-table-column>
        <el-table-column label="类型" width="70">
          <template #default="{ row }">{{ typeName(row.type) }}</template>
        </el-table-column>
        <el-table-column label="原价" width="90" align="right">
          <template #default="{ row }">¥{{ row.totalAmount }}</template>
        </el-table-column>
        <el-table-column label="优惠" width="90" align="right">
          <template #default="{ row }">
            <span v-if="row.discountAmount > 0" style="color: #f56c6c">-¥{{ row.discountAmount }}</span>
            <span v-else>—</span>
          </template>
        </el-table-column>
        <el-table-column label="积分抵扣" width="100" align="right">
          <template #default="{ row }">
            <span v-if="row.pointsUsed > 0">{{ row.pointsUsed }} 分</span>
            <span v-else>—</span>
          </template>
        </el-table-column>
        <el-table-column label="实付" width="100" align="right">
          <template #default="{ row }"><b>¥{{ row.payAmount }}</b></template>
        </el-table-column>
        <el-table-column label="赠送积分" width="90" align="right">
          <template #default="{ row }">+{{ row.pointsEarned }}</template>
        </el-table-column>
        <el-table-column label="支付方式" width="90">
          <template #default="{ row }">{{ payName(row.payMethod) }}</template>
        </el-table-column>
        <el-table-column label="消费时间" width="150">
          <template #default="{ row }">{{ formatTime(row.consumeAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="70" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="query.page"
          v-model:page-size="query.size"
          :total="total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          background
          @change="loadList"
        />
      </div>
    </el-card>

    <!-- 录入订单 -->
    <el-dialog v-model="createVisible" title="录入消费订单" width="640px" destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="消费会员" required>
          <el-select
            v-model="createForm.memberId"
            filterable
            remote
            :remote-method="searchMembers"
            :loading="memberSearching"
            placeholder="输入姓名 / 手机号搜索会员"
            style="width: 100%"
            @change="onMemberChange"
          >
            <el-option v-for="m in memberOptions" :key="m.id" :value="m.id" :label="`${m.name}（${m.phone}）`">
              <span>{{ m.name }}（{{ m.phone }}）</span>
              <span class="text-muted" style="float: right">{{ m.level?.name || '未分级' }} · 积分 {{ m.points }}</span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="订单明细">
          <div style="width: 100%">
            <div v-for="(item, idx) in createForm.items" :key="idx" class="item-row">
              <el-input v-model="item.name" placeholder="商品名" style="width: 200px" />
              <el-input-number v-model="item.price" :min="0" :precision="2" placeholder="单价" style="width: 140px" />
              <span>×</span>
              <el-input-number v-model="item.quantity" :min="1" style="width: 110px" />
              <el-button link type="danger" :icon="Delete" @click="createForm.items.splice(idx, 1)" />
            </div>
            <el-button link type="primary" :icon="Plus" @click="createForm.items.push({ name: '', price: 10, quantity: 1 })">
              添加商品
            </el-button>
          </div>
        </el-form-item>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="订单类型">
              <el-select v-model="createForm.type" style="width: 100%">
                <el-option label="堂食" :value="1" />
                <el-option label="外卖" :value="2" />
                <el-option label="零售" :value="3" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="支付方式">
              <el-select v-model="createForm.payMethod" style="width: 100%">
                <el-option label="微信" value="wechat" />
                <el-option label="支付宝" value="alipay" />
                <el-option label="现金" value="cash" />
                <el-option label="储值卡" value="balance" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="优惠券">
              <el-select v-model="createForm.memberCouponId" clearable placeholder="不使用" style="width: 100%">
                <el-option v-for="c in availableCoupons" :key="c.id" :value="c.id" :label="c.template?.name" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="积分抵扣">
              <el-input-number v-model="createForm.pointsUsed" :min="0" :step="100" style="width: 100%" />
              <div class="text-muted">100 积分抵 1 元，当前会员积分 {{ currentMember?.points ?? '—' }}</div>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="消费时间">
              <el-date-picker v-model="createForm.consumeAt" type="datetime" value-format="YYYY-MM-DDTHH:mm:ss" style="width: 100%" placeholder="默认现在" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="门店">
              <el-input v-model="createForm.storeName" placeholder="门店名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注">
          <el-input v-model="createForm.remark" placeholder="订单备注" />
        </el-form-item>
        <el-alert type="success" :closable="false">
          商品合计：<b>¥{{ itemsTotal }}</b>（等级折扣 / 券 / 积分抵扣由系统自动计算）
        </el-alert>
      </el-form>
      <template #footer>
        <el-button @click="createVisible = false">取消</el-button>
        <el-button type="primary" :loading="creating" @click="onCreate">提交订单</el-button>
      </template>
    </el-dialog>

    <!-- 订单详情 -->
    <el-dialog v-model="detailVisible" title="订单详情" width="560px">
      <template v-if="detail">
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item label="订单号" :span="2">{{ detail.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="会员">{{ detail.member?.name }}</el-descriptions-item>
          <el-descriptions-item label="类型">{{ typeName(detail.type) }}</el-descriptions-item>
          <el-descriptions-item label="原价">¥{{ detail.totalAmount }}</el-descriptions-item>
          <el-descriptions-item label="优惠金额">¥{{ detail.discountAmount }}</el-descriptions-item>
          <el-descriptions-item label="积分抵扣">{{ detail.pointsUsed }} 分（¥{{ detail.pointsDeductionAmount }}）</el-descriptions-item>
          <el-descriptions-item label="实付"><b>¥{{ detail.payAmount }}</b></el-descriptions-item>
          <el-descriptions-item label="赠送积分">+{{ detail.pointsEarned }}</el-descriptions-item>
          <el-descriptions-item label="支付方式">{{ payName(detail.payMethod) }}</el-descriptions-item>
          <el-descriptions-item label="门店">{{ detail.storeName || '—' }}</el-descriptions-item>
          <el-descriptions-item label="消费时间">{{ formatTime(detail.consumeAt) }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ detail.remark || '—' }}</el-descriptions-item>
        </el-descriptions>
        <el-table :data="detail.items" size="small" style="margin-top: 12px">
          <el-table-column prop="name" label="商品" min-width="140" />
          <el-table-column prop="price" label="单价" width="90" align="right" />
          <el-table-column prop="quantity" label="数量" width="70" align="right" />
          <el-table-column label="小计" width="100" align="right">
            <template #default="{ row }">¥{{ (row.price * row.quantity).toFixed(2) }}</template>
          </el-table-column>
        </el-table>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import dayjs from 'dayjs';
import { ElMessage } from 'element-plus';
import { Delete, Plus, Refresh, Search } from '@element-plus/icons-vue';
import { createOrder, getMemberCoupons, getMembers, getOrder, getOrders } from '../../api';

const formatTime = (v?: string) => (v ? dayjs(v).format('YYYY-MM-DD HH:mm') : '—');
const typeName = (t: number) => ({ 1: '堂食', 2: '外卖', 3: '零售' } as Record<number, string>)[t] || '其他';
const payName = (p: string) => ({ wechat: '微信', alipay: '支付宝', cash: '现金', balance: '储值卡' } as Record<string, string>)[p] || p;

const loading = ref(false);
const list = ref<any[]>([]);
const total = ref(0);
const dateRange = ref<[string, string] | null>(null);
const query = reactive({ page: 1, size: 20, keyword: '', type: undefined as number | undefined });

async function loadList() {
  loading.value = true;
  try {
    const params = Object.fromEntries(
      Object.entries({ ...query, startDate: dateRange.value?.[0], endDate: dateRange.value?.[1] })
        .filter(([, v]) => v !== '' && v !== undefined && v !== null),
    );
    const res: any = await getOrders(params);
    list.value = res.list;
    total.value = res.total;
  } finally {
    loading.value = false;
  }
}
function onSearch() {
  query.page = 1;
  loadList();
}
function onReset() {
  query.keyword = '';
  query.type = undefined;
  dateRange.value = null;
  onSearch();
}

// ---------- 录入 ----------
const createVisible = ref(false);
const creating = ref(false);
const memberSearching = ref(false);
const memberOptions = ref<any[]>([]);
const availableCoupons = ref<any[]>([]);
const currentMember = computed(() => memberOptions.value.find((m) => m.id === createForm.memberId));
const createForm = reactive({
  memberId: undefined as number | undefined,
  items: [{ name: '', price: 10, quantity: 1 }] as { name: string; price: number; quantity: number }[],
  type: 1,
  payMethod: 'wechat',
  memberCouponId: undefined as number | undefined,
  pointsUsed: 0,
  consumeAt: '',
  storeName: '',
  remark: '',
});

const itemsTotal = computed(() =>
  createForm.items.reduce((sum, i) => sum + (i.price || 0) * (i.quantity || 0), 0).toFixed(2),
);

async function searchMembers(kw: string) {
  memberSearching.value = true;
  try {
    const res: any = await getMembers({ keyword: kw, page: 1, size: 20 });
    memberOptions.value = res.list;
  } finally {
    memberSearching.value = false;
  }
}

async function onMemberChange(id: number) {
  createForm.memberCouponId = undefined;
  createForm.pointsUsed = 0;
  const res: any = await getMemberCoupons({ memberId: id, status: 0, page: 1, size: 50 });
  availableCoupons.value = res.list;
}

function openCreate() {
  createVisible.value = true;
  searchMembers('');
}

async function onCreate() {
  if (!createForm.memberId) {
    ElMessage.warning('请选择消费会员');
    return;
  }
  const items = createForm.items.filter((i) => i.name && i.price > 0);
  if (!items.length) {
    ElMessage.warning('请至少填写一条有效商品明细');
    return;
  }
  creating.value = true;
  try {
    const res: any = await createOrder({ ...createForm, items, consumeAt: createForm.consumeAt || undefined });
    ElMessage.success(`下单成功：实付 ¥${res.payAmount}，赠送 ${res.pointsEarned} 积分`);
    createVisible.value = false;
    loadList();
  } finally {
    creating.value = false;
  }
}

// ---------- 详情 ----------
const detailVisible = ref(false);
const detail = ref<any>(null);
async function openDetail(row: any) {
  detail.value = await getOrder(row.id);
  detailVisible.value = true;
}

onMounted(loadList);
</script>

<style scoped>
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.item-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}
</style>
