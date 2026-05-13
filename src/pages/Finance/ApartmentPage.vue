<template>
  <q-page class="apartment-page">
    <!-- Header -->
    <div class="dashboard-section">
      <div class="section-header">
        <q-btn
          flat
          dense
          icon="arrow_back"
          label="Voltar"
          @click="$router.push('/financas')"
        />
        <span class="section-title">Apartamento</span>
        <q-space />
      </div>
    </div>

    <!-- Estado vazio -->
    <div class="empty-state" v-if="!financeStore.property">
      <q-icon name="apartment" size="64px" color="primary" />
      <h5 class="q-mt-md text-weight-bold">Apartamento</h5>
      <p class="text-grey-7">Configure seu financiamento</p>
      <q-btn
        flat
        color="primary"
        label="Configurar"
        @click="showPropertyDialog = true"
        class="q-mt-md"
      />
    </div>

    <template v-else>
      <!-- Navegação de Mês -->
      <div class="dashboard-section">
        <div class="section-header">
          <div class="row items-center">
            <q-btn
              flat
              round
              dense
              icon="chevron_left"
              size="sm"
              @click="financeStore.prevMonth()"
            />
            <span class="section-title q-mx-sm">{{ currentMonthLabel }}</span>
            <q-btn
              flat
              round
              dense
              icon="chevron_right"
              size="sm"
              @click="financeStore.nextMonth()"
            />
          </div>
        </div>
      </div>

      <!-- Resumo do Financiamento -->
      <div class="dashboard-section">
        <div class="section-header">
          <span class="section-title">Resumo do Financiamento</span>
          <q-btn
            flat
            dense
            size="sm"
            color="primary"
            label="Editar"
            @click="openPropertyDialog"
          />
        </div>
        <div class="summary-grid">
          <SummaryCard
            icon="payments"
            icon-color="primary"
            label="Financiado"
            :value="financedAmount"
            variant="primary"
          />
          <SummaryCard
            icon="account_balance"
            icon-color="primary"
            label="Saldo Devedor"
            :value="remainingBalance"
          />
          <SummaryCard
            icon="trending_down"
            icon-color="positive"
            label="Total Pago"
            :value="totalPaid"
            variant="income"
          />
          <SummaryCard
            icon="percent"
            icon-color="primary"
            label="Progresso"
            :value="propertyProgress"
            variant="default"
            :show-sign="false"
          />
        </div>
      </div>

      <!-- Gastos por Categoria (Apartamento) -->
      <div class="dashboard-section">
        <div class="section-header">
          <span class="section-title">Gastos por Categoria</span>
          <span class="section-period">Este mês</span>
        </div>
        <div v-if="propertyCategories.length === 0" class="empty-state">
          <q-icon name="pie_chart" size="32px" color="grey-5" />
          <p>Nenhum gasto do apartamento este mês</p>
        </div>
        <div v-else class="chart-card">
          <DonutChart
            :data="propertyCategories"
            :size="160"
            :stroke-width="24"
          />
          <div class="chart-legend">
            <div
              v-for="item in propertyCategories"
              :key="item.name"
              class="legend-item"
            >
              <span class="legend-dot" :style="{ background: item.color }" />
              <span class="legend-name">{{ item.name }}</span>
              <span class="legend-value">{{ formatCurrency(item.total) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Transações do Apartamento -->
      <div class="dashboard-section">
        <div class="section-header">
          <span class="section-title">Transações</span>
          <q-btn
            flat
            dense
            size="sm"
            color="primary"
            label="Nova"
            @click="openTransactionDialog()"
          />
        </div>
        <div
          v-if="financeStore.propertyTransactions.length === 0"
          class="empty-state"
        >
          <q-icon name="receipt_long" size="32px" color="grey-5" />
          <p>Nenhuma transação do apartamento este mês</p>
        </div>
        <div v-else class="transactions-list">
          <div
            v-for="t in financeStore.propertyTransactions"
            :key="t.id"
            class="transaction-item"
          >
            <div class="transaction-icon icon-expense">
              <q-icon name="arrow_upward" size="16px" />
            </div>
            <div class="transaction-info">
              <span class="transaction-desc">{{
                t.description || "Sem descrição"
              }}</span>
              <span class="transaction-cat"
                >{{ t.categories?.name || "Sem categoria" }} •
                {{ formatDate(t.date) }}</span
              >
            </div>
            <span class="transaction-amount text-negative">
              -{{ formatCurrency(t.amount) }}
            </span>
          </div>
        </div>
      </div>

      <!-- Botão rápido adicionar transação do apartamento -->
      <div class="dashboard-section">
        <q-btn
          outline
          color="info"
          icon="add"
          label="Nova Transação (Apartamento)"
          class="full-width"
          @click="openTransactionDialog()"
        />
      </div>
    </template>

    <!-- Espaço no final -->
    <div class="page-spacer" />

    <!-- Dialog: Configurar Financiamento -->
    <q-dialog v-model="showPropertyDialog">
      <q-card style="min-width: 350px">
        <q-card-section
          ><div class="text-h6">Configurar Financiamento</div></q-card-section
        >
        <q-card-section>
          <q-form @submit.prevent="handleSaveProperty" class="q-gutter-sm">
            <q-input
              v-model="propertyForm.financed_amount"
              label="Valor financiado"
              type="number"
              outlined
              dense
              prefix="R$"
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="propertyForm.interest_rate"
              label="Taxa anual (%)"
              type="number"
              outlined
              dense
              step="0.01"
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="propertyForm.monthly_payment"
              label="Valor da parcela"
              type="number"
              outlined
              dense
              prefix="R$"
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="propertyForm.remaining_balance"
              label="Saldo devedor atual"
              type="number"
              outlined
              dense
              prefix="R$"
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <div class="row q-gutter-sm">
              <q-space />
              <q-btn flat label="Cancelar" color="negative" v-close-popup />
              <q-btn type="submit" label="Salvar" color="primary" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- Dialog: Nova Transação do Apartamento -->
    <q-dialog v-model="showTransactionDialog">
      <q-card style="min-width: 350px; max-width: 500px">
        <q-card-section>
          <div class="text-h6">Nova Transação (Apartamento)</div>
        </q-card-section>
        <q-card-section>
          <q-form @submit.prevent="handleSaveTransaction" class="q-gutter-sm">
            <q-input
              v-model="transactionForm.description"
              label="Descrição"
              outlined
              dense
              :rules="[(val) => !!val || 'Descrição é obrigatória']"
            />
            <q-input
              v-model="transactionForm.amount"
              label="Valor"
              type="number"
              outlined
              dense
              prefix="R$"
              step="0.01"
              :rules="[(val) => !!val || 'Valor é obrigatório']"
            />
            <q-input
              v-model="transactionForm.date"
              label="Data"
              type="date"
              outlined
              dense
            />
            <q-select
              v-model="transactionForm.category_id"
              label="Categoria"
              :options="propertyCategoryOptions"
              outlined
              dense
              emit-value
              map-options
            />
            <div class="row q-gutter-sm">
              <q-space />
              <q-btn flat label="Cancelar" color="negative" v-close-popup />
              <q-btn type="submit" label="Salvar" color="primary" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useFinanceStore } from "src/stores/financeStore";
import { formatCurrency, formatDate } from "src/utils/formatters";
import SummaryCard from "src/components/SummaryCard.vue";
import DonutChart from "src/components/charts/DonutChart.vue";

const financeStore = useFinanceStore();

const showPropertyDialog = ref(false);
const showTransactionDialog = ref(false);

const propertyForm = ref({
  financed_amount: 202055.9,
  interest_rate: 7.66,
  monthly_payment: 1500,
  remaining_balance: 202055.9,
});

const transactionForm = ref({
  description: "",
  amount: "",
  date: new Date().toISOString().split("T")[0],
  category_id: null,
});

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

const financedAmount = computed(
  () => Number(financeStore.property?.financed_amount) || 0,
);
const remainingBalance = computed(
  () => Number(financeStore.property?.remaining_balance) || 0,
);
const totalPaid = computed(() => {
  const total = financedAmount.value;
  const remaining = remainingBalance.value;
  return Math.max(0, total - remaining);
});
const propertyProgress = computed(() => {
  const total = financedAmount.value || 1;
  const paid = totalPaid.value;
  return Math.min(100, Math.max(0, Math.round((paid / total) * 100)));
});

const propertyCategories = computed(
  () => financeStore.propertyExpensesByCategory,
);

const propertyCategoryOptions = computed(() => {
  return financeStore.categories
    .filter(
      (c) =>
        c.scope === "property" &&
        (!c.couple_id || c.couple_id === financeStore.coupleId),
    )
    .map((c) => ({ label: c.name, value: c.id }));
});

function openPropertyDialog() {
  if (financeStore.property) {
    propertyForm.value = {
      financed_amount: financeStore.property.financed_amount,
      interest_rate: financeStore.property.interest_rate,
      monthly_payment: financeStore.property.monthly_payment,
      remaining_balance: financeStore.property.remaining_balance,
    };
  }
  showPropertyDialog.value = true;
}

async function handleSaveProperty() {
  await financeStore.createOrUpdateProperty({
    financed_amount: propertyForm.value.financed_amount,
    interest_rate: propertyForm.value.interest_rate,
    monthly_payment: propertyForm.value.monthly_payment,
    remaining_balance: propertyForm.value.remaining_balance,
  });
  showPropertyDialog.value = false;
}

function openTransactionDialog() {
  showTransactionDialog.value = true;
}

async function handleSaveTransaction() {
  const result = await financeStore.createTransaction({
    type: "expense",
    description: transactionForm.value.description,
    amount: transactionForm.value.amount,
    date: transactionForm.value.date,
    category_id: transactionForm.value.category_id,
    property_related: true,
    property_id: financeStore.property?.id || null,
  });
  if (result.success) {
    showTransactionDialog.value = false;
    transactionForm.value = {
      description: "",
      amount: "",
      date: new Date().toISOString().split("T")[0],
      category_id: null,
    };
  }
}

onMounted(async () => {
  await financeStore.fetchProperty();
  await financeStore.fetchPropertyTransactions();
  await financeStore.fetchCategories();
});
</script>

<style scoped lang="scss">
.apartment-page {
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
  white-space: nowrap;
}

.section-period {
  font-size: 0.75rem;
  color: var(--text-secondary);
  background: rgba(var(--q-primary-rgb), 0.08);
  padding: 2px 8px;
  border-radius: 12px;
}

.summary-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 24px;
  color: var(--text-muted);
  font-size: 0.875rem;
}

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

.transactions-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.transaction-item {
  display: flex;
  align-items: center;
  gap: 12px;
  background: var(--surface);
  border: 1px solid var(--separator);
  border-radius: 12px;
  padding: 12px;
}

.transaction-icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  &.icon-expense {
    background: rgba(239, 68, 68, 0.12);
    color: #dc2626;
  }
}

.transaction-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
  flex: 1;
  min-width: 0;
}

.transaction-desc {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.transaction-cat {
  font-size: 0.75rem;
  color: var(--text-secondary);
}

.transaction-amount {
  font-size: 0.875rem;
  font-weight: 700;
  white-space: nowrap;
  font-variant-numeric: tabular-nums;
}

.page-spacer {
  height: 24px;
}
</style>
