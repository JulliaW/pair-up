<template>
  <q-page class="dashboard-page">
    <!-- Header com saudação -->
    <DashboardHeader />

    <!-- Resumo Financeiro -->
    <div class="dashboard-section">
      <div class="section-header">
        <span class="section-title">Resumo Financeiro</span>
        <span class="section-period">{{ currentMonthLabel }}</span>
      </div>
      <div class="summary-grid">
        <SummaryCard
          icon="arrow_upward"
          icon-color="positive"
          label="Receitas"
          :value="financeStore.monthIncome"
        />
        <SummaryCard
          icon="arrow_downward"
          icon-color="negative"
          label="Despesas"
          :value="financeStore.monthExpenses"
        />
        <SummaryCard
          icon="account_balance_wallet"
          icon-color="primary"
          label="Saldo"
          :value="financeStore.monthBalance"
          :full-width="true"
        />
      </div>
    </div>

    <!-- Gráfico de Gastos por Categoria -->
    <div v-if="chartData.length > 0" class="dashboard-section">
      <div class="section-header">
        <span class="section-title">Gastos por Categoria</span>
      </div>
      <div class="chart-card">
        <DonutChart :data="chartData" :size="180" :stroke-width="28" />
        <div class="chart-legend">
          <div
            v-for="item in chartData.slice(0, 5)"
            :key="item.label"
            class="legend-item"
          >
            <span class="legend-dot" :style="{ background: item.color }" />
            <span class="legend-name">{{ item.label }}</span>
            <span class="legend-value">{{ formatCurrency(item.value) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Próximos Eventos -->
    <div class="dashboard-section">
      <div class="section-header">
        <span class="section-title">Próximos Eventos</span>
        <q-btn
          flat
          dense
          size="sm"
          color="primary"
          label="Ver todos"
          @click="$router.push('/agenda')"
        />
      </div>
      <div v-if="agendaStore.upcomingEvents.length === 0" class="empty-state">
        <q-icon name="event_available" size="32px" color="grey-5" />
        <p>Nenhum evento próximo</p>
      </div>
      <div v-else class="events-list">
        <div
          v-for="event in agendaStore.upcomingEvents.slice(0, 3)"
          :key="event.id"
          class="event-item"
        >
          <div class="event-date">
            <span class="event-day">{{ formatDay(event.event_date) }}</span>
            <span class="event-month">{{ formatMonth(event.event_date) }}</span>
          </div>
          <div class="event-info">
            <span class="event-title">{{ event.title }}</span>
            <span v-if="event.event_time" class="event-time">
              {{ event.event_time }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Progresso do Apartamento -->
    <div v-if="financeStore.property" class="dashboard-section">
      <div class="section-header">
        <span class="section-title">Apartamento</span>
        <q-btn
          flat
          dense
          size="sm"
          color="primary"
          label="Detalhes"
          @click="$router.push('/financas/apartamento')"
        />
      </div>
      <div class="property-card">
        <div class="property-progress">
          <q-circular-progress
            :value="propertyProgress"
            size="80px"
            :thickness="0.22"
            color="primary"
            track-color="grey-3"
            class="q-ma-sm"
          >
            <span class="progress-text">{{ propertyProgress }}%</span>
          </q-circular-progress>
          <div class="property-info">
            <span class="property-label">Pago</span>
            <span class="property-value">{{
              formatCurrency(propertyPaid)
            }}</span>
            <span class="property-sub">
              de {{ formatCurrency(financeStore.property.financed_amount) }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Metas de Economia -->
    <div v-if="financeStore.savingsGoals.length > 0" class="dashboard-section">
      <div class="section-header">
        <span class="section-title">Cofrinho</span>
        <q-btn
          flat
          dense
          size="sm"
          color="primary"
          label="Ver todos"
          @click="$router.push('/financas/cofrinho')"
        />
      </div>
      <div class="goals-list">
        <div
          v-for="goal in financeStore.savingsGoals.slice(0, 2)"
          :key="goal.id"
          class="goal-item"
        >
          <div class="goal-header">
            <span class="goal-name">{{ goal.name }}</span>
            <span class="goal-amount">
              {{ formatCurrency(goal.current_amount) }} /
              {{ formatCurrency(goal.target_amount) }}
            </span>
          </div>
          <q-linear-progress
            :value="goal.current_amount / goal.target_amount"
            size="8px"
            rounded
            color="positive"
            track-color="grey-3"
          />
          <span class="goal-percent">
            {{ Math.round((goal.current_amount / goal.target_amount) * 100) }}%
          </span>
        </div>
      </div>
    </div>

    <!-- Ações Rápidas -->
    <div class="dashboard-section">
      <div class="section-header">
        <span class="section-title">Ações Rápidas</span>
      </div>
      <div class="quick-actions">
        <q-btn
          flat
          class="quick-action-btn"
          @click="$router.push('/financas/transacoes')"
        >
          <div class="quick-action-content">
            <q-icon name="add_circle" size="24px" color="primary" />
            <span>Nova Transação</span>
          </div>
        </q-btn>
        <q-btn flat class="quick-action-btn" @click="$router.push('/agenda')">
          <div class="quick-action-content">
            <q-icon name="event" size="24px" color="primary" />
            <span>Novo Evento</span>
          </div>
        </q-btn>
        <q-btn flat class="quick-action-btn" @click="$router.push('/compras')">
          <div class="quick-action-content">
            <q-icon name="shopping_cart" size="24px" color="primary" />
            <span>Lista de Compras</span>
          </div>
        </q-btn>
        <q-btn flat class="quick-action-btn" @click="$router.push('/tarefas')">
          <div class="quick-action-content">
            <q-icon name="checklist" size="24px" color="primary" />
            <span>Tarefas</span>
          </div>
        </q-btn>
      </div>
    </div>

    <!-- Espaço no final para scroll -->
    <div class="page-spacer" />
  </q-page>
</template>

<script setup>
import { computed, onMounted } from "vue";
import { useFinanceStore } from "src/stores/financeStore";
import { useAgendaStore } from "src/stores/agendaStore";
import { useAuthStore } from "src/stores/authStore";
import DashboardHeader from "src/components/DashboardHeader.vue";
import SummaryCard from "src/components/SummaryCard.vue";
import DonutChart from "src/components/charts/DonutChart.vue";

const financeStore = useFinanceStore();
const agendaStore = useAgendaStore();
const authStore = useAuthStore();

async function loadAllDashboardData() {
  if (!authStore.couple?.id) return;
  await Promise.all([
    financeStore.fetchTransactions(),
    financeStore.fetchCategories(),
    financeStore.fetchCreditCards(),
    financeStore.fetchProperty(),
    financeStore.fetchSavingsGoals(),
    agendaStore.fetchEvents(),
  ]);
}

const currentMonthLabel = computed(() => {
  const months = [
    "Janeiro",
    "Fevereiro",
    "Março",
    "Abril",
    "Maio",
    "Junho",
    "Julho",
    "Agosto",
    "Setembro",
    "Outubro",
    "Novembro",
    "Dezembro",
  ];
  return `${months[financeStore.currentMonth - 1]} ${financeStore.currentYear}`;
});

const chartData = computed(() => {
  return financeStore.expensesByCategory.map((item) => ({
    label: item.name,
    value: item.total,
    color: item.color,
  }));
});

const propertyProgress = computed(() => {
  if (!financeStore.property) return 0;
  const total = Number(financeStore.property.financed_amount) || 1;
  const remaining = Number(financeStore.property.remaining_balance) || total;
  const paid = total - remaining;
  return Math.min(100, Math.max(0, Math.round((paid / total) * 100)));
});

const propertyPaid = computed(() => {
  if (!financeStore.property) return 0;
  const total = Number(financeStore.property.financed_amount) || 0;
  const remaining = Number(financeStore.property.remaining_balance) || total;
  return Math.max(0, total - remaining);
});

function formatCurrency(value) {
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
  }).format(value || 0);
}

function formatDay(dateStr) {
  return new Date(dateStr + "T00:00:00").getDate();
}

function formatMonth(dateStr) {
  const months = [
    "JAN",
    "FEV",
    "MAR",
    "ABR",
    "MAI",
    "JUN",
    "JUL",
    "AGO",
    "SET",
    "OUT",
    "NOV",
    "DEZ",
  ];
  return months[new Date(dateStr + "T00:00:00").getMonth()];
}

// Tenta carregar dados no mount (se auth já estiver pronto)
onMounted(async () => {
  if (authStore.couple?.id) {
    await loadAllDashboardData();
  }
});

// Observa mudanças no store Pinia para carregar dados quando couple for definido
authStore.$subscribe(async (mutation, state) => {
  if (state.couple?.id) {
    await loadAllDashboardData();
  }
});
</script>

<style scoped lang="scss">
.dashboard-page {
  padding: 0;
  background: var(--background);
  min-height: 100vh;
}

.dashboard-section {
  padding: 12px 16px;

  & + .dashboard-section {
    border-top: 1px solid var(--separator);
  }
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.section-title {
  font-size: 1rem;
  font-weight: 600;
  color: var(--text-primary);
}

.section-period {
  font-size: 0.75rem;
  color: var(--text-secondary);
  background: rgba(var(--q-primary-rgb), 0.08);
  padding: 2px 8px;
  border-radius: 12px;
}

/* Summary Cards Grid */
.summary-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;

  .summary-card:last-child:nth-child(odd) {
    grid-column: 1 / -1;
  }
}

/* Chart Card */
.chart-card {
  display: flex;
  align-items: center;
  gap: 16px;
  background: var(--surface);
  border: 1px solid var(--separator);
  border-radius: 16px;
  padding: 16px;
}

.chart-legend {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.8125rem;
}

.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.legend-name {
  color: var(--text-primary);
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.legend-value {
  color: var(--text-secondary);
  font-weight: 500;
  font-variant-numeric: tabular-nums;
}

/* Events List */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 24px;
  color: var(--text-muted);
  font-size: 0.875rem;
}

.events-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.event-item {
  display: flex;
  align-items: center;
  gap: 12px;
  background: var(--surface);
  border: 1px solid var(--separator);
  border-radius: 12px;
  padding: 12px;
}

.event-date {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-width: 48px;
  height: 48px;
  background: rgba(var(--q-primary-rgb), 0.08);
  border-radius: 10px;
}

.event-day {
  font-size: 1.125rem;
  font-weight: 700;
  color: var(--q-primary);
  line-height: 1;
}

.event-month {
  font-size: 0.625rem;
  font-weight: 600;
  color: var(--q-primary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.event-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
  flex: 1;
  min-width: 0;
}

.event-title {
  font-size: 0.9375rem;
  font-weight: 500;
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.event-time {
  font-size: 0.75rem;
  color: var(--text-secondary);
}

/* Property Card */
.property-card {
  background: var(--surface);
  border: 1px solid var(--separator);
  border-radius: 16px;
  padding: 16px;
}

.property-progress {
  display: flex;
  align-items: center;
  gap: 16px;
}

.progress-text {
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--text-primary);
}

.property-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.property-label {
  font-size: 0.75rem;
  color: var(--text-secondary);
}

.property-value {
  font-size: 1.125rem;
  font-weight: 700;
  color: var(--text-primary);
}

.property-sub {
  font-size: 0.75rem;
  color: var(--text-muted);
}

/* Goals List */
.goals-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.goal-item {
  background: var(--surface);
  border: 1px solid var(--separator);
  border-radius: 12px;
  padding: 12px;
}

.goal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.goal-name {
  font-size: 0.9375rem;
  font-weight: 500;
  color: var(--text-primary);
}

.goal-amount {
  font-size: 0.8125rem;
  color: var(--text-secondary);
  font-variant-numeric: tabular-nums;
}

.goal-percent {
  display: block;
  text-align: right;
  font-size: 0.75rem;
  color: var(--text-muted);
  margin-top: 4px;
}

/* Quick Actions */
.quick-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.quick-action-btn {
  background: var(--surface);
  border: 1px solid var(--separator);
  border-radius: 12px;
  padding: 0;
  min-height: 72px;

  &::before {
    box-shadow: none;
  }
}

.quick-action-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 12px 8px;

  span {
    font-size: 0.75rem;
    font-weight: 500;
    color: var(--text-primary);
  }
}

.page-spacer {
  height: 24px;
}
</style>
