<template>
  <q-layout>
    <q-page-container>
      <q-page class="accept-invite-page flex flex-center bg-grey-1">
        <div class="accept-container">
          <div class="text-center q-mb-xl">
            <q-icon name="vpn_key" color="primary" size="64px" />
            <h5 class="q-mt-md text-weight-bold">Vincular ao Casal</h5>
            <p class="text-grey-7" v-if="authStore.isAuthenticated">
              Insira o código de convite que seu parceiro(a) compartilhou.
            </p>
            <p class="text-grey-7" v-else>
              Você precisa fazer login primeiro para aceitar um convite.
            </p>
          </div>

          <q-card flat bordered class="accept-card">
            <q-card-section>
              <q-form @submit.prevent="handleAcceptInvite" class="q-gutter-md">
                <q-input
                  v-model="inviteCode"
                  label="Código do convite"
                  outlined
                  dense
                  autofocus
                  hint="Código de 6 caracteres (letras e números)"
                  maxlength="6"
                  class="text-center"
                  :rules="[
                    (val) =>
                      (val && val.length === 6) ||
                      'Código deve ter 6 caracteres',
                  ]"
                  :disable="!authStore.isAuthenticated"
                >
                  <template v-slot:prepend>
                    <q-icon name="vpn_key" />
                  </template>
                </q-input>

                <q-btn
                  type="submit"
                  label="Aceitar convite"
                  color="primary"
                  class="full-width"
                  :loading="loading"
                  :disable="!authStore.isAuthenticated"
                />

                <q-btn
                  flat
                  :label="
                    authStore.isAuthenticated
                      ? 'Pular por enquanto'
                      : 'Ir para o login'
                  "
                  :color="authStore.isAuthenticated ? 'grey' : 'primary'"
                  class="full-width"
                  @click="goToLoginOrDashboard"
                />
              </q-form>
            </q-card-section>

            <q-card-section v-if="error" class="bg-negative text-white">
              <q-icon name="error" size="sm" />
              {{ error }}
            </q-card-section>
          </q-card>

          <div class="text-center q-mt-md">
            <p class="text-caption text-grey-7">
              Não tem um código? Peça para seu parceiro(a) gerar um em
              <strong>Menu > Convidar parceiro(a)</strong>
            </p>
          </div>
        </div>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "src/stores/authStore";
import { useQuasar } from "quasar";

const $q = useQuasar();
const router = useRouter();
const authStore = useAuthStore();

const inviteCode = ref("");
const loading = ref(false);
const error = ref("");

// Se não estiver autenticado, redireciona para o login
onMounted(() => {
  if (!authStore.isAuthenticated) {
    router.push("/login");
  }
});

function goToLoginOrDashboard() {
  if (authStore.isAuthenticated) {
    router.push("/");
  } else {
    router.push("/login");
  }
}

async function handleAcceptInvite() {
  error.value = "";

  if (!authStore.isAuthenticated) {
    error.value = "Você precisa fazer login primeiro.";
    return;
  }

  if (!inviteCode.value || inviteCode.value.length !== 6) {
    error.value = "Insira um código de convite válido (6 caracteres)";
    return;
  }

  loading.value = true;
  const result = await authStore.acceptInvite(inviteCode.value.toUpperCase());
  loading.value = false;

  if (result.success) {
    $q.notify({
      type: "positive",
      message: "Agora você faz parte do casal! 🎉",
      position: "top",
    });
    router.push("/");
  } else {
    error.value = result.error || "Erro ao aceitar convite";
  }
}
</script>

<style scoped lang="scss">
.accept-invite-page {
  min-height: 100vh;
}

.accept-container {
  width: 100%;
  max-width: 420px;
  padding: 16px;
}

.accept-card {
  border-radius: 12px;
}
</style>
