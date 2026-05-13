<template>
  <q-page class="q-pa-md">
    <!-- Botão Voltar -->
    <div class="row items-center q-mb-sm">
      <q-btn
        flat
        dense
        icon="arrow_back"
        label="Voltar"
        @click="$router.push('/financas')"
      />
      <q-space />
    </div>

    <!-- Navegação de Mês -->
    <div class="row items-center q-mb-md">
      <q-btn flat round icon="chevron_left" @click="financeStore.prevMonth()" />
      <div class="col text-center text-h6 text-weight-bold">
        {{ getMonthName(financeStore.currentMonth - 1) }}
        {{ financeStore.currentYear }}
      </div>
      <q-btn
        flat
        round
        icon="chevron_right"
        @click="financeStore.nextMonth()"
      />
    </div>

    <!-- Resumo -->
    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-6">
        <q-card flat bordered>
          <q-card-section class="text-center q-pa-sm">
            <div class="text-caption text-grey-7">Receitas</div>
            <div class="text-positive text-weight-bold">
              {{ formatCurrency(monthIncome) }}
            </div>
          </q-card-section>
        </q-card>
      </div>
      <div class="col-6">
        <q-card flat bordered>
          <q-card-section class="text-center q-pa-sm">
            <div class="text-caption text-grey-7">Despesas</div>
            <div class="text-negative text-weight-bold">
              {{ formatCurrency(monthExpenses) }}
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Lista de Transações -->
    <div
      v-if="financeStore.transactions.length === 0"
      class="text-center text-grey-5 q-py-xl"
    >
      <q-icon name="receipt_long" size="48px" />
      <p class="q-mt-sm">Nenhuma transação este mês</p>
    </div>

    <div v-else class="q-gutter-sm">
      <div
        v-for="t in financeStore.transactions"
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
            {{ t.categories?.name || "Sem categoria" }} •
            {{ formatDate(t.date) }}
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
  </q-page>
</template>

<script setup>
import { computed, onMounted } from "vue";
import { useFinanceStore } from "src/stores/financeStore";
import { formatCurrency, formatDate, getMonthName } from "src/utils/formatters";

const financeStore = useFinanceStore();

const monthIncome = computed(() => financeStore.monthIncome);
const monthExpenses = computed(() => financeStore.monthExpenses);

onMounted(() => {
  financeStore.fetchTransactions();
});
</script>

<style scoped>
.transaction-row {
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}
</style>
