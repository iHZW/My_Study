<template>
  <div class="page-container" v-loading="loading">
    <!-- 指标卡 -->
    <el-row :gutter="16">
      <el-col v-for="card in cards" :key="card.label" :xs="12" :sm="12" :md="6" :lg="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-label">{{ card.label }}</div>
          <div class="stat-value" :style="{ color: card.color }">{{ card.value }}</div>
          <div class="text-muted">{{ card.sub }}</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 趋势图 -->
    <el-row :gutter="16" style="margin-top: 16px">
      <el-col :xs="24" :lg="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>新增会员趋势</span>
              <el-radio-group v-model="memberDays" size="small" @change="loadMemberTrend">
                <el-radio-button :value="7">近 7 天</el-radio-button>
                <el-radio-button :value="30">近 30 天</el-radio-button>
                <el-radio-button :value="90">近 90 天</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <VChart :option="memberTrendOption" />
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>消费金额趋势</span>
              <el-radio-group v-model="consumptionDays" size="small" @change="loadConsumptionTrend">
                <el-radio-button :value="7">近 7 天</el-radio-button>
                <el-radio-button :value="30">近 30 天</el-radio-button>
                <el-radio-button :value="90">近 90 天</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <VChart :option="consumptionTrendOption" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 分布与排行 -->
    <el-row :gutter="16" style="margin-top: 16px">
      <el-col :xs="24" :md="12" :lg="6">
        <el-card shadow="never">
          <template #header><span>会员等级分布</span></template>
          <VChart :option="levelOption" />
        </el-card>
      </el-col>
      <el-col :xs="24" :md="12" :lg="6">
        <el-card shadow="never">
          <template #header><span>订单类型分布</span></template>
          <VChart :option="orderTypeOption" />
        </el-card>
      </el-col>
      <el-col :xs="24" :md="12" :lg="6">
        <el-card shadow="never">
          <template #header><span>会员标签 Top 10</span></template>
          <VChart :option="tagOption" />
        </el-card>
      </el-col>
      <el-col :xs="24" :md="12" :lg="6">
        <el-card shadow="never">
          <template #header><span>消费排行 Top 10</span></template>
          <el-table :data="topMembers" size="small" height="320">
            <el-table-column type="index" width="42" />
            <el-table-column prop="name" label="会员" min-width="70" />
            <el-table-column prop="levelName" label="等级" min-width="80">
              <template #default="{ row }">{{ row.levelName || '未分级' }}</template>
            </el-table-column>
            <el-table-column label="累计消费" min-width="90" align="right">
              <template #default="{ row }">¥{{ formatMoney(row.totalConsumption) }}</template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import dayjs from 'dayjs';
import VChart from '../../components/VChart.vue';
import {
  getConsumptionTrend,
  getLevelDistribution,
  getMemberTrend,
  getOrderTypeDistribution,
  getOverview,
  getTagDistribution,
  getTopMembers,
} from '../../api';

const loading = ref(false);
const overview = ref<Record<string, number>>({});
const memberDays = ref(30);
const consumptionDays = ref(30);
const memberTrend = ref<{ date: string; count: number }[]>([]);
const consumptionTrend = ref<{ date: string; amount: number; orders: number }[]>([]);
const levelDist = ref<{ name: string; color: string; count: number }[]>([]);
const tagDist = ref<{ name: string; color: string; count: number }[]>([]);
const orderTypeDist = ref<{ name: string; count: number; amount: number }[]>([]);
const topMembers = ref<Record<string, unknown>[]>([]);

const formatMoney = (n: number) => Number(n || 0).toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const cards = computed(() => [
  { label: '会员总数', value: overview.value.totalMembers ?? 0, sub: `30 天活跃 ${overview.value.activeMembers30d ?? 0} 人`, color: '#409EFF' },
  { label: '今日新增会员', value: overview.value.newToday ?? 0, sub: `本月新增 ${overview.value.newThisMonth ?? 0} 人`, color: '#67C23A' },
  { label: '今日营业额', value: `¥${formatMoney(overview.value.todayAmount ?? 0)}`, sub: `今日订单 ${overview.value.todayOrders ?? 0} 笔`, color: '#E6A23C' },
  { label: '累计消费金额', value: `¥${formatMoney(overview.value.totalConsumption ?? 0)}`, sub: `累计订单 ${overview.value.totalOrders ?? 0} 笔`, color: '#F56C6C' },
]);

const dateAxis = (dates: string[]) => dates.map((d) => dayjs(d).format('MM-DD'));

const memberTrendOption = computed(() => ({
  tooltip: { trigger: 'axis' as const },
  grid: { left: 40, right: 20, top: 30, bottom: 30 },
  xAxis: { type: 'category' as const, data: dateAxis(memberTrend.value.map((i) => i.date)) },
  yAxis: { type: 'value' as const, minInterval: 1 },
  series: [
    {
      name: '新增会员',
      type: 'line' as const,
      smooth: true,
      data: memberTrend.value.map((i) => i.count),
      areaStyle: { opacity: 0.15 },
      itemStyle: { color: '#409EFF' },
    },
  ],
}));

const consumptionTrendOption = computed(() => ({
  tooltip: { trigger: 'axis' as const },
  legend: { data: ['消费金额', '订单数'] },
  grid: { left: 60, right: 40, top: 40, bottom: 30 },
  xAxis: { type: 'category' as const, data: dateAxis(consumptionTrend.value.map((i) => i.date)) },
  yAxis: [
    { type: 'value' as const, name: '金额(元)' },
    { type: 'value' as const, name: '订单数', minInterval: 1 },
  ],
  series: [
    {
      name: '消费金额',
      type: 'bar' as const,
      data: consumptionTrend.value.map((i) => i.amount),
      itemStyle: { color: '#67C23A', borderRadius: [3, 3, 0, 0] },
    },
    {
      name: '订单数',
      type: 'line' as const,
      yAxisIndex: 1,
      smooth: true,
      data: consumptionTrend.value.map((i) => i.orders),
      itemStyle: { color: '#E6A23C' },
    },
  ],
}));

const levelOption = computed(() => ({
  tooltip: { trigger: 'item' as const },
  legend: { bottom: 0 },
  series: [
    {
      type: 'pie' as const,
      radius: ['40%', '65%'],
      center: ['50%', '45%'],
      data: levelDist.value.map((i) => ({ name: i.name, value: i.count, itemStyle: { color: i.color } })),
      label: { formatter: '{b}: {c}' },
    },
  ],
}));

const orderTypeOption = computed(() => ({
  tooltip: { trigger: 'item' as const, formatter: '{b}<br/>{c} 笔 ({d}%)' },
  legend: { bottom: 0 },
  series: [
    {
      type: 'pie' as const,
      radius: '60%',
      center: ['50%', '45%'],
      data: orderTypeDist.value.map((i, idx) => ({
        name: i.name,
        value: i.count,
        itemStyle: { color: ['#409EFF', '#67C23A', '#E6A23C'][idx % 3] },
      })),
      label: { formatter: '{b}: {c}' },
    },
  ],
}));

const tagOption = computed(() => {
  const data = [...tagDist.value].reverse();
  return {
    tooltip: { trigger: 'axis' as const },
    grid: { left: 80, right: 30, top: 10, bottom: 25 },
    xAxis: { type: 'value' as const, minInterval: 1 },
    yAxis: { type: 'category' as const, data: data.map((i) => i.name) },
    series: [
      {
        type: 'bar' as const,
        data: data.map((i) => ({ value: i.count, itemStyle: { color: i.color, borderRadius: [0, 3, 3, 0] } })),
        barWidth: 14,
      },
    ],
  };
});

async function loadMemberTrend() {
  memberTrend.value = (await getMemberTrend(memberDays.value)) as never;
}
async function loadConsumptionTrend() {
  consumptionTrend.value = (await getConsumptionTrend(consumptionDays.value)) as never;
}

onMounted(async () => {
  loading.value = true;
  try {
    const results = await Promise.all([
      getOverview(),
      getMemberTrend(memberDays.value),
      getConsumptionTrend(consumptionDays.value),
      getLevelDistribution(),
      getTagDistribution(),
      getOrderTypeDistribution(),
      getTopMembers(10),
    ]);
    overview.value = results[0] as never;
    memberTrend.value = results[1] as never;
    consumptionTrend.value = results[2] as never;
    levelDist.value = results[3] as never;
    tagDist.value = results[4] as never;
    orderTypeDist.value = results[5] as never;
    topMembers.value = results[6] as never;
  } finally {
    loading.value = false;
  }
});
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.stat-card {
  margin-bottom: 12px;
}
</style>
