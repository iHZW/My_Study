<template>
  <div ref="chartRef" class="chart-box" />
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue';
import * as echarts from 'echarts';

const props = defineProps<{
  option: echarts.EChartsOption;
}>();

const chartRef = ref<HTMLDivElement>();
let chart: echarts.ECharts | null = null;
let resizeObserver: ResizeObserver | null = null;

function render() {
  if (!chart) return;
  chart.setOption(props.option, true);
}

onMounted(() => {
  chart = echarts.init(chartRef.value!);
  render();
  resizeObserver = new ResizeObserver(() => chart?.resize());
  resizeObserver.observe(chartRef.value!);
});

watch(() => props.option, render, { deep: true });

onBeforeUnmount(() => {
  resizeObserver?.disconnect();
  chart?.dispose();
  chart = null;
});
</script>
