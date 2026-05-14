<template>
  <div
    class="summary-card"
    :class="[`summary-card--${variant}`, { 'summary-card--large': large }]"
  >
    <div class="row items-center">
      <div v-if="icon" class="summary-card__icon q-mr-md">
        <q-icon :name="icon" :size="large ? '28px' : '22px'" />
      </div>
      <div class="summary-card__content">
        <div class="summary-card__label">{{ label }}</div>
        <div
          class="summary-card__value"
          :class="{ 'text-negative': isNegative, 'text-positive': isPositive }"
        >
          {{ formattedValue }}
        </div>
      </div>
    </div>
    <div v-if="$slots.footer" class="summary-card__footer q-mt-sm">
      <slot name="footer" />
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { formatCurrency } from "src/utils/formatters";

const props = defineProps({
  label: {
    type: String,
    required: true,
  },
  value: {
    type: Number,
    default: 0,
  },
  icon: {
    type: String,
    default: "",
  },
  variant: {
    type: String,
    default: "default",
    validator: (v) =>
      ["default", "income", "expense", "balance", "primary"].includes(v),
  },
  large: {
    type: Boolean,
    default: false,
  },
  showSign: {
    type: Boolean,
    default: true,
  },
});

const formattedValue = computed(() => {
  if (!props.showSign) return formatCurrency(Math.abs(props.value));
  return formatCurrency(props.value);
});

const isNegative = computed(() => props.value < 0);
const isPositive = computed(
  () =>
    props.value > 0 &&
    (props.variant === "income" || props.variant === "balance"),
);
</script>

<style scoped>
.summary-card {
  padding: 16px;
  border-radius: 16px;
  background: #ffffff;
  box-shadow:
    0 1px 3px rgba(0, 0, 0, 0.04),
    0 4px 12px rgba(0, 0, 0, 0.04);
  border: 1px solid rgba(0, 0, 0, 0.04);
  transition:
    transform 0.2s ease,
    box-shadow 0.2s ease;
}

.summary-card:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.body--dark .summary-card {
  background: #1e293b;
  border-color: rgba(255, 255, 255, 0.06);
}

/* Variantes */
.summary-card--primary {
  background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
  color: white;
  border: none;
}

.summary-card--primary .summary-card__label,
.summary-card--primary .summary-card__value {
  color: rgba(255, 255, 255, 0.9);
}

.summary-card--income {
  background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
  border-color: #a7f3d0;
}

.body--dark .summary-card--income {
  background: linear-gradient(135deg, #064e3b 0%, #065f46 100%);
  border-color: #059669;
}

.summary-card--expense {
  background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
  border-color: #fecaca;
}

.body--dark .summary-card--expense {
  background: linear-gradient(135deg, #450a0a 0%, #7f1d1d 100%);
  border-color: #dc2626;
}

.summary-card--balance {
  background: linear-gradient(135deg, #f0fdfa 0%, #ccfbf1 100%);
  border-color: #99f6e4;
}

.body--dark .summary-card--balance {
  background: linear-gradient(135deg, #134e4a 0%, #115e59 100%);
  border-color: #14b8a6;
}

/* Icon */
.summary-card__icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: rgba(13, 148, 136, 0.1);
  color: #0d9488;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.summary-card--income .summary-card__icon {
  background: rgba(16, 185, 129, 0.15);
  color: #059669;
}

.summary-card--expense .summary-card__icon {
  background: rgba(239, 68, 68, 0.15);
  color: #dc2626;
}

.summary-card--balance .summary-card__icon {
  background: rgba(13, 148, 136, 0.15);
  color: #0d9488;
}

.summary-card--primary .summary-card__icon {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

/* Content */
.summary-card__label {
  font-size: 12px;
  font-weight: 500;
  color: #64748b;
  letter-spacing: 0.02em;
  text-transform: uppercase;
}

.body--dark .summary-card__label {
  color: #94a3b8;
}

.summary-card--primary .summary-card__label {
  color: rgba(255, 255, 255, 0.8);
}

.summary-card__value {
  font-size: clamp(16px, 5vw, 22px);
  font-weight: 700;
  color: #1e293b;
  margin-top: 4px;
  font-variant-numeric: tabular-nums;
  letter-spacing: -0.02em;
  overflow-wrap: break-word;
  word-break: break-word;
}

.summary-card--large .summary-card__value {
  font-size: 26px;
}

.body--dark .summary-card__value {
  color: #f8fafc;
}

.summary-card--primary .summary-card__value {
  color: white;
}

/* Footer */
.summary-card__footer {
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  padding-top: 10px;
  font-size: 12px;
}

.body--dark .summary-card__footer {
  border-top-color: rgba(255, 255, 255, 0.06);
}

.summary-card--primary .summary-card__footer {
  border-top-color: rgba(255, 255, 255, 0.15);
}
</style>
