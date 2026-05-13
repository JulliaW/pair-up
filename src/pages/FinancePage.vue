<template>
  <q-page class="finance-page">
    <DashboardHeader />

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
      <div class="summary-grid">
        <SummaryCard
          icon="arrow_upward"
          icon-color="positive"
          label="Receitas"
          :value="monthIncome"
        />
        <SummaryCard
          icon="arrow_downward"
          icon-color="negative"
          label="Despesas"
          :value="monthExpenses"
        />
        <SummaryCard
          icon="account_balance_wallet"
          icon-color="primary"
          label="Saldo"
          :value="monthBalance"
          :full-width="true"
        />
      </div>
    </div>

    <div class="dashboard-section">
      <div class="section-header">
        <span class="section-title">Ações Rápidas</span>
      </div>
      <div class="quick-actions">
        <q-btn
          flat
          class="quick-action-btn"
          @click="openTransactionDialog('income')"
        >
          <div class="quick-action-content">
            <q-icon name="add_circle" size="24px" color="positive" />
            <span>Nova Receita</span>
          </div>
        </q-btn>
        <q-btn
          flat
          class="quick-action-btn"
          @click="openTransactionDialog('expense')"
        >
          <div class="quick-action-content">
            <q-icon name="remove_circle" size="24px" color="negative" />
            <span>Nova Despesa</span>
          </div>
        </q-btn>
      </div>
    </div>

    <div class="dashboard-section">
      <div class="section-header">
        <span class="section-title">Módulos</span>
      </div>
      <div class="modules-grid">
        <q-btn
          v-for="mod in modules"
          :key="mod.route"
          flat
          class="module-btn"
          @click="$router.push(mod.route)"
        >
          <div class="module-content">
            <div
              class="module-icon-wrapper"
              :style="{ background: mod.bgColor }"
            >
              <q-icon :name="mod.icon" size="28px" :color="mod.color" />
            </div>
            <span class="module-label">{{ mod.label }}</span>
          </div>
        </q-btn>
      </div>
    </div>

    <div class="dashboard-section">
      <div class="section-header">
        <span class="section-title">Últimas Transações</span>
        <q-btn
          flat
          dense
          size="sm"
          color="primary"
          label="Ver todas"
          @click="$router.push('/financas/transacoes')"
        />
      </div>
      <div v-if="financeStore.transactions.length === 0" class="empty-state">
        <q-icon name="receipt_long" size="32px" color="grey-5" />
        <p>Nenhuma transação este mês</p>
      </div>
      <div v-else class="transactions-list">
        <div
          v-for="t in recentTransactions"
          :key="t.id"
          class="transaction-item"
        >
          <div
            class="transaction-icon"
            :class="t.type === 'income' ? 'icon-income' : 'icon-expense'"
          >
            <q-icon
              :name="t.type === 'income' ? 'arrow_downward' : 'arrow_upward'"
              size="16px"
            />
          </div>
          <div class="transaction-info">
            <span class="transaction-desc">{{
              t.description || "Sem descrição"
            }}</span>
            <span class="transaction-cat">{{
              t.categories?.name || "Sem categoria"
            }}</span>
          </div>
          <span
            class="transaction-amount"
            :class="t.type === 'income' ? 'text-positive' : 'text-negative'"
          >
            {{ t.type === "income" ? "+" : "-" }}{{ formatCurrency(t.amount) }}
          </span>
        </div>
      </div>
    </div>

    <div class="page-spacer" />

    <q-dialog v-model="showTransactionDialog">
      <q-card style="min-width: 350px; max-width: 500px">
        <q-card-section>
          <div class="text-h6">
            {{ transactionType === "income" ? "Nova Receita" : "Nova Despesa" }}
          </div>
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
              :options="categoryOptions"
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
import { formatCurrency } from "src/utils/formatters";
import DashboardHeader from "src/components/DashboardHeader.vue";
import SummaryCard from "src/components/SummaryCard.vue";

const financeStore = useFinanceStore();

const showTransactionDialog = ref(false);
const transactionType = ref("expense");
const transactionForm = ref({
  description: "",
  amount: "",
  date: new Date().toISOString().split("T")[0],
  category_id: null,
});

const modules = [
  {
    icon: "receipt_long",
    label: "Transações",
    color: "primary",
    bgColor: "rgba(13, 148, 136, 0.1)",
    route: "/financas/transacoes",
  },
  {
    icon: "credit_card",
    label: "Cartões",
    color: "negative",
    bgColor: "rgba(239, 68, 68, 0.1)",
    route: "/financas/cartoes",
  },
  {
    icon: "apartment",
    label: "Apartamento",
    color: "info",
    bgColor: "rgba(59, 130, 246, 0.1)",
    route: "/financas/apartamento",
  },
  {
    icon: "savings",
    label: "Cofrinho",
    color: "positive",
    bgColor: "rgba(16, 185, 129, 0.1)",
    route: "/financas/cofrinho",
  },
];

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
  return months[financeStore.currentMonth - 1] + " " + financeStore.currentYear;
});

const monthIncome = computed(() => financeStore.monthIncome);
const monthExpenses = computed(() => financeStore.monthExpenses);
const monthBalance = computed(() => financeStore.monthBalance);

const recentTransactions = computed(() => {
  return financeStore.transactions.slice(0, 5);
});

const categoryOptions = computed(() => {
  return financeStore.categories
    .filter(
      (c) =>
        c.type === transactionType.value &&
        (!c.couple_id || c.couple_id === financeStore.coupleId) &&
        c.scope !== "property",
    )
    .map((c) => ({ label: c.name, value: c.id }));
});

function openTransactionDialog(type) {
  transactionType.value = type;
  transactionForm.value = {
    description: "",
    amount: "",
    date: new Date().toISOString().split("T")[0],
    category_id: null,
  };
  showTransactionDialog.value = true;
}

async function handleSaveTransaction() {
  const result = await financeStore.createTransaction({
    type: transactionType.value,
    description: transactionForm.value.description,
    amount: transactionForm.value.amount,
    date: transactionForm.value.date,
    category_id: transactionForm.value.category_id,
  });
  if (result.success) {
    showTransactionDialog.value = false;
  }
}

onMounted(() => {
  financeStore.fetchTransactions();
  financeStore.fetchCategories();
});
</script>

<style scoped lang="scss">
.finance-page {
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
.summary-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}
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
.modules-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}
.module-btn {
  background: var(--surface);
  border: 1px solid var(--separator);
  border-radius: 12px;
  padding: 0;
  min-height: 80px;
  &::before {
    box-shadow: none;
  }
  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  }
}
.module-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 14px 8px;
}
.module-icon-wrapper {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.module-label {
  font-size: 0.8125rem;
  font-weight: 500;
  color: var(--text-primary);
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
  &.icon-income {
    background: rgba(16, 185, 129, 0.12);
    color: #059669;
  }
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
