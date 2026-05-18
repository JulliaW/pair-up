<template>
  <div class="donut-chart-container">
    <svg
      :viewBox="`0 0 ${size} ${size}`"
      :width="size"
      :height="size"
      class="donut-chart"
    >
      <!-- Fundo do donut -->
      <circle
        :cx="center"
        :cy="center"
        :r="radius"
        fill="none"
        :stroke="darkMode ? '#334155' : '#E2E8F0'"
        :stroke-width="strokeWidth"
      />

      <!-- Segmentos -->
      <circle
        v-for="(segment, index) in segments"
        :key="index"
        :cx="center"
        :cy="center"
        :r="radius"
        fill="none"
        :stroke="segment.color"
        :stroke-width="strokeWidth"
        :stroke-dasharray="segment.dashArray"
        :stroke-dashoffset="segment.dashOffset"
        :stroke-linecap="rounded ? 'round' : 'butt'"
      />

      <!-- Texto central -->
      <g v-if="showCenterText" class="donut-center-text">
        <text
          :x="center"
          :y="center - 6"
          text-anchor="middle"
          :fill="darkMode ? '#F8FAFC' : '#1E293B'"
          font-size="12"
          font-weight="500"
          opacity="0.6"
        >
          {{ centerLabel }}
        </text>
        <text
          :x="center"
          :y="center + 14"
          text-anchor="middle"
          :fill="darkMode ? '#F8FAFC' : '#1E293B'"
          font-size="18"
          font-weight="700"
        >
          {{ centerValue }}
        </text>
      </g>
    </svg>

    <!-- Legenda -->
    <div v-if="showLegend" class="donut-legend q-mt-md">
      <div
        v-for="(item, index) in sortedData"
        :key="index"
        class="donut-legend-item row items-center justify-between q-py-xs"
      >
        <div class="row items-center">
          <div
            class="donut-legend-dot q-mr-sm"
            :style="{ backgroundColor: item.color }"
          />
          <span class="donut-legend-label">{{ item.label }}</span>
        </div>
        <span class="donut-legend-value">{{ formatCurrency(item.value) }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { useQuasar } from "quasar";
import { formatCurrency } from "src/utils/formatters";

const props = defineProps({
  data: {
    type: Array,
    required: true,
    // [{ label: string, value: number, color?: string }]
  },
  size: {
    type: Number,
    default: 200,
  },
  strokeWidth: {
    type: Number,
    default: 28,
  },
  showCenterText: {
    type: Boolean,
    default: true,
  },
  centerLabel: {
    type: String,
    default: "Total",
  },
  showLegend: {
    type: Boolean,
    default: true,
  },
  rounded: {
    type: Boolean,
    default: false,
  },
});

const $q = useQuasar();
const darkMode = computed(() => $q.dark.isActive);

// Paleta de cores elegante para o gráfico
const DEFAULT_COLORS = [
  "#0D9488", // Teal 600
  "#3B82F6", // Blue 500
  "#8B5CF6", // Violet 500
  "#EC4899", // Pink 500
  "#F59E0B", // Amber 500
  "#10B981", // Emerald 500
  "#EF4444", // Red 500
  "#64748B", // Slate 500
  "#06B6D4", // Cyan 500
  "#84CC16", // Lime 500
];

const sortedData = computed(() => {
  const sorted = [...props.data]
    .filter((d) => d.value > 0)
    .sort((a, b) => b.value - a.value);

  return sorted.map((item, index) => ({
    ...item,
    color: item.color || DEFAULT_COLORS[index % DEFAULT_COLORS.length],
  }));
});

const total = computed(() =>
  sortedData.value.reduce((sum, item) => sum + item.value, 0),
);

const centerValue = computed(() => formatCurrency(total.value));

const center = computed(() => props.size / 2);
const radius = computed(() => (props.size - props.strokeWidth) / 2);
const circumference = computed(() => 2 * Math.PI * radius.value);

const segments = computed(() => {
  let accumulatedPercent = 0;

  return sortedData.value.map((item) => {
    const percent = total.value > 0 ? item.value / total.value : 0;
    const dashArray = `${circumference.value * percent} ${circumference.value}`;
    const dashOffset = -circumference.value * accumulatedPercent;

    accumulatedPercent += percent;

    return {
      color: item.color,
      dashArray,
      dashOffset,
    };
  });
});
</script>

<style scoped>
.donut-chart-container {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.donut-chart {
  transform: rotate(-90deg);
}

.donut-center-text {
  transform: rotate(90deg);
  transform-origin: center;
}

.donut-legend {
  width: 100%;
  max-width: 320px;
}

.donut-legend-item {
  font-size: 13px;
}

.donut-legend-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}

.donut-legend-label {
  color: v-bind("darkMode ? '#CBD5E1' : '#475569'");
  font-weight: 500;
}

.donut-legend-value {
  color: v-bind("darkMode ? '#F8FAFC' : '#1E293B'");
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}
</style>
