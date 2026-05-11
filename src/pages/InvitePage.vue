<template>
  <q-page class="invite-page q-pa-md">
    <div class="text-center q-mt-lg">
      <q-icon name="group_add" size="64px" color="primary" />
      <h5 class="q-mt-md text-weight-bold">Convidar Parceiro(a)</h5>
      <p class="text-grey-7">
        Compartilhe o código abaixo com seu parceiro(a) para que ele(a) possa se
        vincular à sua conta.
      </p>
    </div>

    <!-- Código de Convite -->
    <q-card flat bordered class="invite-card q-mt-md">
      <q-card-section class="text-center">
        <div class="text-caption text-grey-7 q-mb-sm">
          Seu código de convite
        </div>
        <div class="invite-code">
          <span class="text-h3 text-weight-bold text-primary letter-spacing">{{
            inviteCode
          }}</span>
        </div>

        <q-btn
          flat
          color="primary"
          icon="content_copy"
          label="Copiar código"
          class="q-mt-md"
          @click="copyInviteCode"
        />
      </q-card-section>
    </q-card>

    <!-- Status do Casal -->
    <q-card flat bordered class="q-mt-md">
      <q-card-section>
        <div class="text-weight-medium q-mb-sm">Status do Casal</div>

        <div class="row items-center q-mb-sm">
          <q-icon name="person" size="sm" color="positive" />
          <span class="q-ml-sm">{{ partner1Name }} (você)</span>
        </div>

        <div class="row items-center">
          <q-icon
            :name="partner2Name ? 'person' : 'person_outline'"
            size="sm"
            :color="partner2Name ? 'positive' : 'grey'"
          />
          <span class="q-ml-sm">
            {{ partner2Name || "Aguardando parceiro(a)..." }}
          </span>
        </div>
      </q-card-section>
    </q-card>

    <!-- Compartilhar -->
    <q-card flat bordered class="q-mt-md">
      <q-card-section>
        <div class="text-weight-medium q-mb-sm">Compartilhar convite</div>

        <p class="text-caption text-grey-7">
          Envie o código acima para seu parceiro(a). Ele(a) deve:
        </p>

        <q-stepper v-model="step" flat color="primary" header-nav ref="stepper">
          <q-step
            :name="1"
            title="Criar conta"
            icon="person_add"
            :done="step > 1"
          >
            Seu parceiro(a) deve se cadastrar no PairUp usando a opção
            "Cadastrar" na tela de login.
          </q-step>

          <q-step
            :name="2"
            title="Aceitar convite"
            icon="vpn_key"
            :done="step > 2"
          >
            Após o cadastro, na tela de login, clicar em "Aceitar Convite" e
            inserir o código:
            <div
              class="text-h6 text-center text-primary q-my-sm text-weight-bold letter-spacing"
            >
              {{ inviteCode }}
            </div>
          </q-step>

          <q-step :name="3" title="Pronto!" icon="celebration">
            Assim que seu parceiro(a) inserir o código, vocês estarão vinculados
            e poderão compartilhar todas as funcionalidades!
          </q-step>
        </q-stepper>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, computed } from "vue";
import { useAuthStore } from "src/stores/authStore";
import { useQuasar } from "quasar";

const $q = useQuasar();
const authStore = useAuthStore();

const step = ref(1);

const inviteCode = computed(() => {
  return authStore.couple?.invite_code || "---";
});

const partner1Name = computed(() => {
  return authStore.couple?.partner1_name || authStore.user?.name || "Você";
});

const partner2Name = computed(() => {
  return authStore.couple?.partner2_name || null;
});

async function copyInviteCode() {
  try {
    await navigator.clipboard.writeText(inviteCode.value);
    $q.notify({
      type: "positive",
      message: "Código copiado!",
      position: "top",
    });
  } catch {
    $q.notify({
      type: "negative",
      message: "Erro ao copiar. Selecione o código manualmente.",
      position: "top",
    });
  }
}
</script>

<style scoped lang="scss">
.invite-page {
  max-width: 600px;
  margin: 0 auto;
}

.invite-card {
  border-radius: 12px;
}

.invite-code {
  padding: 16px;
  border-radius: 8px;
}

.letter-spacing {
  letter-spacing: 8px;
}
</style>
