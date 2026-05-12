<template>
  <q-page class="q-pa-md">
    <div
      class="text-center q-mt-xl"
      v-if="financeStore.savingsGoals.length === 0"
    >
      <q-icon name="savings" size="64px" color="primary" />
      <h5 class="q-mt-md text-weight-bold">Cofrinho</h5>
      <p class="text-grey-7">Crie metas de economia para o casal</p>
      <q-btn
        flat
        color="primary"
        label="Nova meta"
        @click="showDialog = true"
        class="q-mt-md"
      />
    </div>

    <div v-else class="q-gutter-md">
      <q-card
        v-for="goal in financeStore.savingsGoals"
        :key="goal.id"
        flat
        bordered
      >
        <q-card-section>
          <div class="text-weight-bold">{{ goal.name }}</div>
          <q-linear-progress
            :value="progress(goal)"
            color="primary"
            class="q-mt-sm q-mb-sm"
            size="20px"
          >
            <div class="absolute-full flex flex-center text-white text-caption">
              {{ Math.round(progress(goal) * 100) }}%
            </div>
          </q-linear-progress>
          <div class="row">
            <div class="col text-caption text-grey-7">
              {{ formatCurrency(goal.current_amount) }} /
              {{ formatCurrency(goal.target_amount) }}
            </div>
          </div>
          <div v-if="goal.target_date" class="text-caption text-grey-7 q-mt-xs">
            Meta até {{ formatDate(goal.target_date) }}
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat dense icon="edit" size="sm" @click="editGoal(goal)" />
        </q-card-actions>
      </q-card>

      <q-btn
        outline
        color="primary"
        label="Nova meta"
        class="full-width"
        @click="showDialog = true"
      />
    </div>

    <q-dialog v-model="showDialog">
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">{{ editingGoal ? "Editar" : "Nova" }} Meta</div>
        </q-card-section>
        <q-card-section>
          <q-form @submit.prevent="handleSave" class="q-gutter-sm">
            <q-input
              v-model="form.name"
              label="Nome"
              outlined
              dense
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="form.target_amount"
              label="Valor alvo"
              type="number"
              outlined
              dense
              prefix="R$"
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="form.current_amount"
              label="Valor atual"
              type="number"
              outlined
              dense
              prefix="R$"
            />
            <q-input
              v-model="form.target_date"
              label="Data alvo"
              type="date"
              outlined
              dense
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
import { ref, onMounted } from "vue";
import { useFinanceStore } from "src/stores/financeStore";
import { formatCurrency, formatDate } from "src/utils/formatters";

const financeStore = useFinanceStore();
const showDialog = ref(false);
const editingGoal = ref(null);
const form = ref({
  name: "",
  target_amount: "",
  current_amount: 0,
  target_date: "",
});

function progress(goal) {
  if (!goal.target_amount || goal.target_amount === 0) return 0;
  return Math.min(goal.current_amount / goal.target_amount, 1);
}

function editGoal(goal) {
  editingGoal.value = goal;
  form.value = {
    name: goal.name,
    target_amount: goal.target_amount,
    current_amount: goal.current_amount,
    target_date: goal.target_date || "",
  };
  showDialog.value = true;
}

async function handleSave() {
  if (editingGoal.value) {
    await financeStore.updateSavingsGoal(editingGoal.value.id, form.value);
  } else {
    await financeStore.createSavingsGoal(form.value);
  }
  showDialog.value = false;
  editingGoal.value = null;
  form.value = {
    name: "",
    target_amount: "",
    current_amount: 0,
    target_date: "",
  };
}

onMounted(() => financeStore.fetchSavingsGoals());
</script>
