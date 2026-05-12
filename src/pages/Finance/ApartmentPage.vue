<template>
  <q-page class="q-pa-md">
    <div class="text-center q-mt-xl" v-if="!financeStore.property">
      <q-icon name="apartment" size="64px" color="primary" />
      <h5 class="q-mt-md text-weight-bold">Apartamento</h5>
      <p class="text-grey-7">Configure seu financiamento</p>
      <q-btn
        flat
        color="primary"
        label="Configurar"
        @click="showDialog = true"
        class="q-mt-md"
      />
    </div>

    <div v-else>
      <q-card flat bordered class="q-mb-md">
        <q-card-section>
          <div class="text-h6 text-weight-bold">
            {{ financeStore.property.name }}
          </div>
        </q-card-section>
        <q-card-section class="q-pt-none">
          <div class="row q-col-gutter-md">
            <div class="col-6">
              <div class="text-caption text-grey-7">Saldo Devedor</div>
              <div class="text-weight-bold">
                {{ formatCurrency(financeStore.property.remaining_balance) }}
              </div>
            </div>
            <div class="col-6">
              <div class="text-caption text-grey-7">Parcela Atual</div>
              <div class="text-weight-bold">
                {{ formatCurrency(financeStore.property.monthly_payment) }}
              </div>
            </div>
            <div class="col-6 q-mt-sm">
              <div class="text-caption text-grey-7">Taxa Anual</div>
              <div class="text-weight-bold">
                {{ financeStore.property.interest_rate }}%
              </div>
            </div>
            <div class="col-6 q-mt-sm">
              <div class="text-caption text-grey-7">Total Financiado</div>
              <div class="text-weight-bold">
                {{ formatCurrency(financeStore.property.financed_amount) }}
              </div>
            </div>
          </div>
        </q-card-section>
      </q-card>

      <q-btn
        outline
        color="primary"
        label="Editar configurações"
        class="full-width"
        @click="showDialog = true"
      />
    </div>

    <q-dialog v-model="showDialog">
      <q-card style="min-width: 350px">
        <q-card-section
          ><div class="text-h6">Configurar Financiamento</div></q-card-section
        >
        <q-card-section>
          <q-form @submit.prevent="handleSave" class="q-gutter-sm">
            <q-input
              v-model="form.financed_amount"
              label="Valor financiado"
              type="number"
              outlined
              dense
              prefix="R$"
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="form.interest_rate"
              label="Taxa anual (%)"
              type="number"
              outlined
              dense
              step="0.01"
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="form.monthly_payment"
              label="Valor da parcela"
              type="number"
              outlined
              dense
              prefix="R$"
              :rules="[(v) => !!v || 'Obrigatório']"
            />
            <q-input
              v-model="form.remaining_balance"
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
  </q-page>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useFinanceStore } from "src/stores/financeStore";
import { formatCurrency } from "src/utils/formatters";

const financeStore = useFinanceStore();
const showDialog = ref(false);
const form = ref({
  financed_amount: 202055.9,
  interest_rate: 7.66,
  monthly_payment: 1500,
  remaining_balance: 202055.9,
});

async function handleSave() {
  await financeStore.createOrUpdateProperty({
    financed_amount: form.value.financed_amount,
    interest_rate: form.value.interest_rate,
    monthly_payment: form.value.monthly_payment,
    remaining_balance: form.value.remaining_balance,
  });
  showDialog.value = false;
}

onMounted(() => financeStore.fetchProperty());
</script>
