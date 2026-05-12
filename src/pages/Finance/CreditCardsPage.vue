<template>
  <q-page class="q-pa-md">
    <div
      class="text-center q-mt-xl"
      v-if="financeStore.creditCards.length === 0"
    >
      <q-icon name="credit_card" size="64px" color="primary" />
      <h5 class="q-mt-md text-weight-bold">Cartões de Crédito</h5>
      <p class="text-grey-7">Nenhum cartão cadastrado ainda</p>
      <q-btn
        flat
        color="primary"
        label="Adicionar cartão"
        @click="showDialog = true"
        class="q-mt-md"
      />
    </div>

    <div v-else class="q-gutter-md">
      <q-card
        v-for="card in financeStore.creditCards"
        :key="card.id"
        flat
        bordered
      >
        <q-card-section>
          <div class="text-weight-bold">{{ card.name }}</div>
          <div class="text-caption text-grey-7">
            Limite: {{ formatCurrency(card.card_limit) }}
          </div>
          <div class="text-caption">
            Fecha dia {{ card.closing_day }} | Vence dia {{ card.due_day }}
          </div>
        </q-card-section>
      </q-card>
    </div>

    <q-page-sticky position="bottom-right" :offset="[18, 18]">
      <q-btn fab icon="add" color="primary" @click="showDialog = true" />
    </q-page-sticky>

    <q-dialog v-model="showDialog">
      <q-card style="min-width: 350px">
        <q-card-section><div class="text-h6">Novo Cartão</div></q-card-section>
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
              v-model="form.card_limit"
              label="Limite"
              type="number"
              outlined
              dense
              prefix="R$"
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="form.closing_day"
              label="Dia fechamento"
              type="number"
              outlined
              dense
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="form.due_day"
              label="Dia vencimento"
              type="number"
              outlined
              dense
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
  </q-page>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useFinanceStore } from "src/stores/financeStore";
import { formatCurrency } from "src/utils/formatters";

const financeStore = useFinanceStore();
const showDialog = ref(false);
const form = ref({ name: "", card_limit: "", closing_day: "", due_day: "" });

async function handleSave() {
  await financeStore.createCreditCard({
    name: form.value.name,
    card_limit: form.value.card_limit,
    closing_day: parseInt(form.value.closing_day),
    due_day: parseInt(form.value.due_day),
  });
  showDialog.value = false;
  form.value = { name: "", card_limit: "", closing_day: "", due_day: "" };
}

onMounted(() => financeStore.fetchCreditCards());
</script>
