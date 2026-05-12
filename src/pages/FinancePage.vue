<template>
  <q-page class="finance-page q-pa-md">
    <!-- Resumo do Mês -->
    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-4">
        <q-card flat bordered class="finance-card">
          <q-card-section class="text-center q-pa-sm">
            <div class="text-caption text-grey-7">Receitas</div>
            <div class="text-positive text-weight-bold">
              {{ formatCurrency(monthIncome) }}
            </div>
          </q-card-section>
        </q-card>
      </div>
      <div class="col-4">
        <q-card flat bordered class="finance-card">
          <q-card-section class="text-center q-pa-sm">
            <div class="text-caption text-grey-7">Despesas</div>
            <div class="text-negative text-weight-bold">
              {{ formatCurrency(monthExpenses) }}
            </div>
          </q-card-section>
        </q-card>
      </div>
      <div class="col-4">
        <q-card flat bordered class="finance-card">
          <q-card-section class="text-center q-pa-sm">
            <div class="text-caption text-grey-7">Saldo</div>
            <div class="text-weight-bold" :class="balanceColor">
              {{ formatCurrency(monthBalance) }}
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Ações Rápidas -->
    <div class="row q-col-gutter-sm q-mb-md">
      <div class="col-6">
        <q-btn
          outline
          color="positive"
          icon="add"
          label="Nova Receita"
          class="full-width"
          @click="openTransactionDialog('income')"
        />
      </div>
      <div class="col-6">
        <q-btn
          outline
          color="negative"
          icon="remove"
          label="Nova Despesa"
          class="full-width"
          @click="openTransactionDialog('expense')"
        />
      </div>
    </div>

    <!-- Menu de Módulos -->
    <div class="text-subtitle1 text-weight-bold q-mb-sm">Módulos</div>
    <div class="row q-col-gutter-sm q-mb-md">
      <div class="col-6" v-for="mod in modules" :key="mod.route">
        <q-card
          flat
          bordered
          class="module-card cursor-pointer"
          @click="$router.push(mod.route)"
        >
          <q-card-section class="text-center q-pa-md">
            <q-icon :name="mod.icon" :color="mod.color" size="32px" />
            <div class="text-weight-medium q-mt-sm">{{ mod.label }}</div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Últimas Transações -->
    <div class="row items-center q-mb-sm">
      <div class="col text-subtitle1 text-weight-bold">Últimas Transações</div>
      <q-btn
        flat
        dense
        icon="chevron_right"
        size="sm"
        @click="$router.push('/financas/transacoes')"
      />
    </div>

    <div
      v-if="financeStore.transactions.length === 0"
      class="text-center text-grey-5 q-py-lg"
    >
      <q-icon name="receipt_long" size="48px" />
      <p class="q-mt-sm">Nenhuma transação este mês</p>
    </div>

    <div v-else class="q-gutter-sm">
      <div
        v-for="t in recentTransactions"
        :key="t.id"
        class="row items-center transaction-row q-pa-sm"
      >
        <div class="col-auto">
          <q-icon
            :name="t.type === 'income' ? 'arrow_downward' : 'arrow_upward'"
            :color="t.type === 'income' ? 'positive' : 'negative'"
            size="sm"
          />
        </div>
        <div class="col q-ml-sm">
          <div class="text-weight-medium">
            {{ t.description || "Sem descrição" }}
          </div>
          <div class="text-caption text-grey-7">
            {{ t.categories?.name || "Sem categoria" }}
          </div>
        </div>
        <div class="col-auto">
          <span
            class="text-weight-bold"
            :class="t.type === 'income' ? 'text-positive' : 'text-negative'"
          >
            {{ t.type === "income" ? "+" : "-" }}{{ formatCurrency(t.amount) }}
          </span>
        </div>
      </div>
    </div>

    <!-- Dialog de Transação -->
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
    route: "/financas/transacoes",
  },
  {
    icon: "credit_card",
    label: "Cartões",
    color: "negative",
    route: "/financas/cartoes",
  },
  {
    icon: "apartment",
    label: "Apartamento",
    color: "info",
    route: "/financas/apartamento",
  },
  {
    icon: "savings",
    label: "Cofrinho",
    color: "positive",
    route: "/financas/cofrinho",
  },
];

const monthIncome = computed(() => financeStore.monthIncome);
const monthExpenses = computed(() => financeStore.monthExpenses);
const monthBalance = computed(() => financeStore.monthBalance);

const balanceColor = computed(() => {
  const b = financeStore.monthBalance;
  if (b > 0) return "text-positive";
  if (b < 0) return "text-negative";
  return "text-grey";
});

const recentTransactions = computed(() => {
  return financeStore.transactions.slice(0, 5);
});

const categoryOptions = computed(() => {
  return financeStore.categories
    .filter(
      (c) =>
        c.type === transactionType.value &&
        (!c.couple_id || c.couple_id === financeStore.coupleId),
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
.finance-card {
  border-radius: 8px;
}

.module-card {
  border-radius: 12px;
  transition: box-shadow 0.2s;
  &:hover {
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  }
}

.transaction-row {
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}
</style>
